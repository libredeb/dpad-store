/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Juan Pablo Lozano <libredeb@gmail.com>
 */

using Gtk;

namespace DpadStore.Widgets {

    public class MainWindow : Window {

        private ListBox listbox;
        private ProgressBar progress_bar;
        private Label status_label;
        private Backend.AppLoader app_loader;
        private Backend.Installer installer;

        public MainWindow (Gtk.Application app) {
            this.set_application (app);
            this.set_decorated (false);
            this.set_default_size (720, 720);
            //this.fullscreen();
            this.set_keep_above (true);
            this.set_title (Constants.PROGRAM_NAME);
            this.set_icon_name (Constants.APP_ID);

            var pi_apps_dir = Path.build_filename (
                Environment.get_home_dir (), Constants.PI_APPS_DIR
            );
            app_loader = new Backend.AppLoader (pi_apps_dir);
            installer = new Backend.Installer (pi_apps_dir);

            load_css ();
            build_ui ();
            connect_signals ();

            this.show_all ();

            var first = listbox.get_row_at_index (0);
            if (first != null) first.grab_focus ();
        }

        private void load_css () {
            var provider = new CssProvider ();
            provider.load_from_resource (
                "/io/github/libredeb/dpad-store/styles/application.css"
            );
            StyleContext.add_provider_for_screen (
                Gdk.Screen.get_default (),
                provider,
                STYLE_PROVIDER_PRIORITY_APPLICATION
            );
        }

        private void build_ui () {
            var root_box = new Box (Orientation.VERTICAL, 0);

            var header = new Label (Constants.PROGRAM_NAME);
            header.margin = 25;
            root_box.pack_start (header, false, false, 0);

            listbox = new ListBox ();
            listbox.set_selection_mode (SelectionMode.SINGLE);
            populate_list ();

            var scroll = new ScrolledWindow (null, null);
            scroll.set_policy (PolicyType.NEVER, PolicyType.AUTOMATIC);
            scroll.add (listbox);
            root_box.pack_start (scroll, true, true, 0);

            var progress_box = new Box (Orientation.VERTICAL, 8);
            progress_box.margin = 25;

            status_label = new Label (Constants.STATUS_IDLE);
            progress_bar = new ProgressBar ();
            progress_bar.set_size_request (-1, 24);

            progress_box.pack_start (status_label, false, false, 0);
            progress_box.pack_start (progress_bar, false, false, 0);

            root_box.pack_end (progress_box, false, false, 0);

            this.add (root_box);
        }

        private void populate_list () {
            var app_names = app_loader.load_app_names ();
            for (int i = 0; i < app_names.length; i++) {
                var name = app_names[i];
                var path = app_loader.get_app_path (name);
                bool installed = app_loader.is_installed (name);
                listbox.add (new AppListRow (name, path, installed));
            }
        }

        private void connect_signals () {
            this.key_press_event.connect ((e) => {
                if (e.keyval == Gdk.Key.Escape) {
                    this.get_application ().quit ();
                }
                return false;
            });

            listbox.row_activated.connect ((row) => {
                var app_row = row as AppListRow;
                if (app_row != null) {
                    listbox.set_sensitive (false);
                    installer.install (app_row.app_name);
                }
            });

            installer.progress_changed.connect ((app_name, message) => {
                status_label.set_text (Constants.STATUS_PROCESSING.printf (app_name, message));
                progress_bar.pulse ();
                while (Gtk.events_pending ()) Gtk.main_iteration ();
            });

            installer.finished.connect ((app_name) => {
                status_label.set_text (Constants.STATUS_COMPLETE.printf (app_name));
                progress_bar.set_fraction (0);
                listbox.set_sensitive (true);
                update_row_installed_status (app_name);
            });

            installer.failed.connect ((error_message) => {
                status_label.set_text (Constants.STATUS_ERROR.printf (error_message));
                listbox.set_sensitive (true);
            });
        }

        private void update_row_installed_status (string app_name) {
            int i = 0;
            ListBoxRow? row;
            while ((row = listbox.get_row_at_index (i)) != null) {
                var app_row = row as AppListRow;
                if (app_row != null && app_row.app_name == app_name) {
                    if (app_loader.is_installed (app_name)) {
                        app_row.mark_installed ();
                    }
                    break;
                }
                i++;
            }
        }
    }
}
