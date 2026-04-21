/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Juan Pablo Lozano <libredeb@gmail.com>
 */

namespace DpadStore.Backend {

    public class Installer : Object {

        private string pi_apps_dir;

        public signal void progress_changed (string app_name, string action, string message);
        public signal void finished (string app_name, string action);
        public signal void failed (string error_message);

        public Installer (string pi_apps_dir) {
            this.pi_apps_dir = pi_apps_dir;
        }

        public void install (string name) {
            run_action (name, Constants.PI_APPS_INSTALL_ACTION);
        }

        public void uninstall (string name) {
            run_action (name, Constants.PI_APPS_UNINSTALL_ACTION);
        }

        public void update (string name) {
            run_action (name, Constants.PI_APPS_UPDATE_ACTION);
        }

        private string strip_ansi_codes (string text) {
            try {
                var regex = new Regex (Constants.ANSI_ESCAPE_PATTERN);
                return regex.replace (text, -1, 0, "");
            } catch (RegexError e) {
                return text;
            }
        }

        private void run_action (string name, string action) {
            string manage_script = Path.build_filename (
                pi_apps_dir, Constants.PI_APPS_MANAGE_SCRIPT
            );
            string[] argv = {
                Constants.SHELL_PATH, manage_script, action, name
            };

            Pid child_pid;
            int standard_output;

            try {
                Process.spawn_async_with_pipes (
                    null, argv, null,
                    SpawnFlags.DO_NOT_REAP_CHILD | SpawnFlags.SEARCH_PATH,
                    null, out child_pid, null, out standard_output, null);

                var channel = new IOChannel.unix_new (standard_output);

                channel.add_watch (IOCondition.IN | IOCondition.HUP, (source, condition) => {
                    if ((condition & IOCondition.HUP) != 0) return false;

                    string line;
                    size_t term_pos;
                    try {
                        if (source.read_line (out line, null, out term_pos) == IOStatus.NORMAL) {
                            string clean = strip_ansi_codes (line.strip ());
                            progress_changed (name, action, clean);
                        }
                    } catch (Error e) {
                        return false;
                    }
                    return true;
                });

                ChildWatch.add (child_pid, (pid, status) => {
                    Process.close_pid (pid);
                    Idle.add (() => {
                        finished (name, action);
                        return false;
                    });
                });

            } catch (Error e) {
                failed (e.message);
            }
        }
    }
}
