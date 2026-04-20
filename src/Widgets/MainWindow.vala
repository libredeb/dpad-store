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
            status_label.set_max_width_chars (65);
            status_label.set_ellipsize (Pango.EllipsizeMode.END);
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
                if (app_row == null) return;

                if (app_row.is_installed) {
                    show_installed_app_dialog (app_row);
                } else {
                    listbox.set_sensitive (false);
                    installer.install (app_row.app_name);
                }
            });

            installer.progress_changed.connect ((app_name, action, message) => {
                string status;
                if (action == Constants.PI_APPS_UNINSTALL_ACTION) {
                    status = Constants.STATUS_UNINSTALLING.printf (
                        app_name, message
                    );
                } else if (action == Constants.PI_APPS_UPDATE_ACTION) {
                    status = Constants.STATUS_UPDATING.printf (
                        app_name, message
                    );
                } else {
                    status = Constants.STATUS_INSTALLING.printf (
                        app_name, message
                    );
                }
                status_label.set_text (status);
                progress_bar.pulse ();
                while (Gtk.events_pending ()) Gtk.main_iteration ();
            });

            installer.finished.connect ((app_name, action) => {
                string message;
                if (action == Constants.PI_APPS_UNINSTALL_ACTION) {
                    message = Constants.STATUS_UNINSTALL_COMPLETE.printf (
                        app_name
                    );
                } else if (action == Constants.PI_APPS_UPDATE_ACTION) {
                    message = Constants.STATUS_UPDATE_COMPLETE.printf (
                        app_name
                    );
                } else {
                    message = Constants.STATUS_INSTALL_COMPLETE.printf (
                        app_name
                    );
                }
                status_label.set_text (message);
                progress_bar.set_fraction (0);
                listbox.set_sensitive (true);
                update_row_status (app_name);
            });

            installer.failed.connect ((error_message) => {
                status_label.set_text (
                    Constants.STATUS_ERROR.printf (error_message)
                );
                listbox.set_sensitive (true);
            });
        }

        private void show_installed_app_dialog (AppListRow app_row) {
            var dialog = new Dialog ();
            dialog.set_transient_for (this);
            dialog.set_modal (true);
            dialog.set_decorated (false);
            dialog.get_style_context ().add_class (
                Constants.CSS_CLASS_APP_DIALOG
            );

            var content = dialog.get_content_area ();
            content.set_spacing (16);
            content.margin = 24;

            var title = new Label (
                Constants.DIALOG_TITLE.printf (app_row.app_name)
            );
            title.get_style_context ().add_class (
                Constants.CSS_CLASS_DIALOG_TITLE
            );
            content.pack_start (title, false, false, 8);

            var action_area = dialog.get_action_area () as ButtonBox;
            if (action_area != null) {
                action_area.set_orientation (Orientation.VERTICAL);
                action_area.set_layout (ButtonBoxStyle.EXPAND);
                action_area.set_spacing (8);
                action_area.margin = 16;
            }

            var update_btn = dialog.add_button (
                Constants.DIALOG_BTN_UPDATE,
                Constants.DIALOG_RESPONSE_UPDATE
            );
            update_btn.get_style_context ().add_class (
                Constants.CSS_CLASS_DIALOG_BUTTON
            );

            var uninstall_btn = dialog.add_button (
                Constants.DIALOG_BTN_UNINSTALL,
                Constants.DIALOG_RESPONSE_UNINSTALL
            );
            uninstall_btn.get_style_context ().add_class (
                Constants.CSS_CLASS_DIALOG_BUTTON
            );
            uninstall_btn.get_style_context ().add_class (
                Constants.CSS_CLASS_DIALOG_BUTTON_DANGER
            );

            var cancel_btn = dialog.add_button (
                Constants.DIALOG_BTN_CANCEL,
                ResponseType.CANCEL
            );
            cancel_btn.get_style_context ().add_class (
                Constants.CSS_CLASS_DIALOG_BUTTON
            );

            dialog.show_all ();
            cancel_btn.grab_focus ();
            int response = dialog.run ();
            dialog.destroy ();

            switch (response) {
                case Constants.DIALOG_RESPONSE_UNINSTALL:
                    listbox.set_sensitive (false);
                    installer.uninstall (app_row.app_name);
                    break;
                case Constants.DIALOG_RESPONSE_UPDATE:
                    listbox.set_sensitive (false);
                    installer.update (app_row.app_name);
                    break;
                default:
                    break;
            }
        }

        private void update_row_status (string app_name) {
            int i = 0;
            ListBoxRow? row;
            while ((row = listbox.get_row_at_index (i)) != null) {
                var app_row = row as AppListRow;
                if (app_row != null && app_row.app_name == app_name) {
                    if (app_loader.is_installed (app_name)) {
                        app_row.mark_installed ();
                    } else {
                        app_row.mark_uninstalled ();
                    }
                    break;
                }
                i++;
            }
        }
    }
}
