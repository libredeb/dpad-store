/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Juan Pablo Lozano <libredeb@gmail.com>
 */

using Gtk;

namespace DpadStore.Widgets {

    public class MainWindow : Window {

        private ListBox listbox;
        private DetailPanel detail_panel;
        private ConsoleOutput console_output;
        private Backend.AppLoader app_loader;
        private Backend.Installer installer;
        private Backend.GamepadManager gamepad;

        private bool focus_on_detail;

        public MainWindow (Gtk.Application app) {
            //this.fullscreen ();
            this.set_application (app);
            this.set_decorated (false);
            this.set_default_size (720, 720);
            this.set_keep_above (true);
            this.set_title (Constants.PROGRAM_NAME);
            this.set_icon_name (Constants.APP_ID);

            focus_on_detail = false;

            var pi_apps_dir = Path.build_filename (
                Environment.get_home_dir (), Constants.PI_APPS_DIR
            );
            app_loader = new Backend.AppLoader (pi_apps_dir);
            installer = new Backend.Installer (pi_apps_dir);

            load_css ();
            build_ui ();
            connect_signals ();

            gamepad = new Backend.GamepadManager ();
            connect_gamepad_signals ();

            this.show_all ();
            console_output.hide ();
            hide_mouse_cursor ();

            var first = listbox.get_row_at_index (0);
            if (first != null) {
                listbox.select_row (first);
                first.grab_focus ();
                update_detail_for_row (first);
            }
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

            root_box.pack_start (build_header (), false, false, 0);

            var content_box = new Box (Orientation.HORIZONTAL, 12);
            content_box.get_style_context ().add_class (
                Constants.CSS_CLASS_CONTENT_BOX
            );

            listbox = new ListBox ();
            listbox.set_selection_mode (SelectionMode.SINGLE);
            populate_list ();

            var list_scroll = new ScrolledWindow (null, null);
            list_scroll.set_policy (PolicyType.NEVER, PolicyType.AUTOMATIC);
            list_scroll.get_style_context ().add_class (
                Constants.CSS_CLASS_APP_LIST_PANEL
            );
            list_scroll.add (listbox);

            detail_panel = new DetailPanel ();

            var detail_scroll = new ScrolledWindow (null, null);
            detail_scroll.set_policy (PolicyType.NEVER, PolicyType.AUTOMATIC);
            detail_scroll.get_style_context ().add_class (
                Constants.CSS_CLASS_DETAIL_PANEL_CONTAINER
            );
            detail_scroll.add (detail_panel);

            int detail_width = (int) (720 * Constants.DETAIL_PANEL_RATIO);
            int list_width = 720 - detail_width;
            list_scroll.set_size_request (list_width, -1);
            detail_scroll.set_size_request (detail_width, -1);

            content_box.pack_start (list_scroll, false, true, 0);
            content_box.pack_start (detail_scroll, true, true, 0);

            root_box.pack_start (content_box, true, true, 0);

            console_output = new ConsoleOutput ();
            root_box.pack_end (build_footer (), false, false, 0);
            root_box.pack_end (console_output, false, false, 0);

            this.add (root_box);
        }

        private Box build_header () {
            var header_box = new Box (Orientation.HORIZONTAL, 12);
            header_box.halign = Align.START;
            header_box.margin = 20;
            header_box.get_style_context ().add_class (
                Constants.CSS_CLASS_HEADER_BOX
            );

            string icon_path = Constants.get_gfx_path (
                Constants.GFX_DPAD_ICON
            );
            if (FileUtils.test (icon_path, FileTest.EXISTS)) {
                try {
                    var pixbuf = new Gdk.Pixbuf.from_file_at_scale (
                        icon_path, Constants.HEADER_ICON_SIZE,
                        Constants.HEADER_ICON_SIZE, true
                    );
                    var icon = new Image.from_pixbuf (pixbuf);
                    icon.get_style_context ().add_class (
                        Constants.CSS_CLASS_HEADER_ICON
                    );
                    header_box.pack_start (icon, false, false, 0);
                } catch (Error e) {
                    stderr.printf ("Header icon error: %s\n", e.message);
                }
            }

            var title_label = new Label ("Gamercard Store");
            title_label.get_style_context ().add_class (
                Constants.CSS_CLASS_HEADER_TITLE
            );
            header_box.pack_start (title_label, false, false, 0);

            return header_box;
        }

        private Box build_footer () {
            var footer_box = new Box (Orientation.HORIZONTAL, 0);
            footer_box.get_style_context ().add_class (
                Constants.CSS_CLASS_FOOTER_BOX
            );
            footer_box.margin_top = 8;

            var left_box = new Box (Orientation.HORIZONTAL, 0);
            left_box.halign = Align.START;
            left_box.pack_start (
                build_footer_item (
                    Constants.GFX_CONTROL_A, Constants.FOOTER_LABEL_INSTALL
                ), false, false, 32
            );
            left_box.pack_start (
                build_footer_item (
                    Constants.GFX_CONTROL_B, Constants.FOOTER_LABEL_BACK
                ), false, false, 32
            );

            footer_box.pack_start (left_box, false, false, 0);

            return footer_box;
        }

        private Box build_footer_item (string icon_filename, string text) {
            var item_box = new Box (Orientation.HORIZONTAL, 8);
            item_box.valign = Align.CENTER;

            string icon_path = Constants.get_gfx_path (icon_filename);
            if (FileUtils.test (icon_path, FileTest.EXISTS)) {
                try {
                    var pixbuf = new Gdk.Pixbuf.from_file_at_scale (
                        icon_path, Constants.FOOTER_ICON_SIZE,
                        Constants.FOOTER_ICON_SIZE, true
                    );
                    var icon = new Image.from_pixbuf (pixbuf);
                    item_box.pack_start (icon, false, false, 0);
                } catch (Error e) {
                    stderr.printf ("Footer icon error: %s\n", e.message);
                }
            }

            var label = new Label (text);
            label.get_style_context ().add_class (
                Constants.CSS_CLASS_FOOTER_LABEL
            );
            item_box.pack_start (label, false, false, 0);

            return item_box;
        }

        private void populate_list () {
            var app_names = app_loader.load_app_names ();
            for (int i = 0; i < app_names.length; i++) {
                var name = app_names[i];
                var path = app_loader.get_app_path (name);
                var genre = app_loader.get_app_genre (name);
                bool installed = app_loader.is_installed (name);
                listbox.add (new AppTile (name, path, genre, installed));
            }
        }

        private void update_detail_for_row (ListBoxRow row) {
            var tile = row as AppTile;
            if (tile == null) return;
            detail_panel.update_for_app (
                tile.app_name, tile.app_path, tile.is_installed
            );
        }

        private void connect_signals () {
            this.key_press_event.connect ((e) => {
                if (e.keyval == Gdk.Key.Escape) {
                    this.get_application ().quit ();
                }
                return false;
            });

            listbox.row_selected.connect ((row) => {
                if (row != null) {
                    update_detail_for_row (row);
                }
            });

            detail_panel.action_requested.connect ((app_name, action) => {
                handle_action (app_name, action);
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
                console_output.update_status (status);
                console_output.append_output (message);
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
                console_output.finish_operation (message);
                listbox.set_sensitive (true);
                update_tile_status (app_name);

                var selected = listbox.get_selected_row ();
                if (selected != null) {
                    update_detail_for_row (selected);
                }

                return_focus_to_list ();
            });

            installer.failed.connect ((error_message) => {
                console_output.show_error (
                    Constants.STATUS_ERROR.printf (error_message)
                );
                listbox.set_sensitive (true);
                return_focus_to_list ();
            });
        }

        private void handle_action (string app_name, string action) {
            if (action == Constants.PI_APPS_PLAY_ACTION) {
                launch_app (app_name);
                return;
            }

            listbox.set_sensitive (false);
            console_output.start_operation (app_name);
            detail_panel.set_installing_status ();

            if (action == Constants.PI_APPS_UNINSTALL_ACTION) {
                installer.uninstall (app_name);
            } else if (action == Constants.PI_APPS_UPDATE_ACTION) {
                installer.update (app_name);
            } else {
                installer.install (app_name);
            }
        }

        private void launch_app (string app_name) {
            string? desktop_id = find_desktop_file (app_name);
            if (desktop_id == null) {
                console_output.show_error (
                    Constants.ERROR_DESKTOP_NOT_FOUND.printf (app_name)
                );
                console_output.show ();
                return;
            }

            var app_info = new GLib.DesktopAppInfo (desktop_id);
            if (app_info == null) {
                console_output.show_error (
                    Constants.ERROR_DESKTOP_NOT_FOUND.printf (app_name)
                );
                console_output.show ();
                return;
            }

            try {
                app_info.launch (null, null);
                this.get_application ().quit ();
            } catch (Error e) {
                console_output.show_error (
                    Constants.ERROR_LAUNCH_FAILED.printf (app_name, e.message)
                );
                console_output.show ();
            }
        }

        private string? find_desktop_file (string app_name) {
            string lower_name = app_name.down ();
            string[] search_dirs = {
                Constants.DESKTOP_FILES_SYSTEM_PATH,
                Path.build_filename (
                    Environment.get_home_dir (),
                    Constants.DESKTOP_FILES_USER_SUBDIR
                )
            };

            foreach (string dir_path in search_dirs) {
                try {
                    var dir = Dir.open (dir_path, 0);
                    string? filename;
                    while ((filename = dir.read_name ()) != null) {
                        if (!filename.has_suffix (
                            Constants.DESKTOP_FILE_EXTENSION
                        )) {
                            continue;
                        }
                        if (filename.down ().contains (lower_name)) {
                            return filename;
                        }
                    }
                } catch (FileError e) {
                    continue;
                }
            }
            return null;
        }

        private void connect_gamepad_signals () {
            gamepad.direction_pressed.connect ((direction) => {
                if (focus_on_detail) {
                    detail_panel.navigate_buttons (direction);
                } else {
                    navigate_listbox (direction);
                }
            });

            gamepad.button_a_pressed.connect (() => {
                if (focus_on_detail) {
                    detail_panel.activate_focused_button ();
                } else {
                    focus_on_detail = true;
                    detail_panel.set_focus_on_buttons ();
                }
            });

            gamepad.button_b_pressed.connect (() => {
                if (focus_on_detail) {
                    return_focus_to_list ();
                } else {
                    this.get_application ().quit ();
                }
            });
        }

        private void navigate_listbox (Backend.GamepadDirection direction) {
            var selected = listbox.get_selected_row ();
            if (selected == null) {
                var first = listbox.get_row_at_index (0);
                if (first != null) {
                    listbox.select_row (first);
                    first.grab_focus ();
                }
                return;
            }

            int index = selected.get_index ();
            int next_index = index;

            switch (direction) {
                case Backend.GamepadDirection.UP:
                    next_index = index - 1;
                    break;
                case Backend.GamepadDirection.DOWN:
                    next_index = index + 1;
                    break;
                default:
                    return;
            }

            if (next_index < 0) return;

            var next_row = listbox.get_row_at_index (next_index);
            if (next_row != null) {
                listbox.select_row (next_row);
                next_row.grab_focus ();
            }
        }

        private void return_focus_to_list () {
            focus_on_detail = false;
            detail_panel.release_button_focus ();
            var selected = listbox.get_selected_row ();
            if (selected != null) {
                selected.grab_focus ();
            }
        }

        private void hide_mouse_cursor () {
            var gdk_window = this.get_window ();
            if (gdk_window != null) {
                var blank_cursor = new Gdk.Cursor.for_display (
                    this.get_display (), Gdk.CursorType.BLANK_CURSOR
                );
                gdk_window.set_cursor (blank_cursor);
            }
        }

        private void update_tile_status (string app_name) {
            int i = 0;
            ListBoxRow? row;
            while ((row = listbox.get_row_at_index (i)) != null) {
                var tile = row as AppTile;
                if (tile != null && tile.app_name == app_name) {
                    if (app_loader.is_installed (app_name)) {
                        tile.mark_installed ();
                    } else {
                        tile.mark_uninstalled ();
                    }
                    break;
                }
                i++;
            }
        }
    }
}
