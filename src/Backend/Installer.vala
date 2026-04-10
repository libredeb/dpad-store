/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Juan Pablo Lozano <libredeb@gmail.com>
 */

namespace DpadStore.Backend {

    public class Installer : Object {

        private string pi_apps_dir;

        public signal void progress_changed (string app_name, string message);
        public signal void finished (string app_name);
        public signal void failed (string error_message);

        public Installer (string pi_apps_dir) {
            this.pi_apps_dir = pi_apps_dir;
        }

        public void install (string name) {
            string manage_script = Path.build_filename (
                pi_apps_dir, Constants.PI_APPS_MANAGE_SCRIPT
            );
            string[] argv = {
                Constants.SHELL_PATH, manage_script,
                Constants.PI_APPS_INSTALL_ACTION, name
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
                            progress_changed (name, line.strip ());
                        }
                    } catch (Error e) {
                        return false;
                    }
                    return true;
                });

                ChildWatch.add (child_pid, (pid, status) => {
                    Process.close_pid (pid);
                    Idle.add (() => {
                        finished (name);
                        return false;
                    });
                });

            } catch (Error e) {
                failed (e.message);
            }
        }
    }
}
