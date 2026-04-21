/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Juan Pablo Lozano <libredeb@gmail.com>
 */

using Gtk;

namespace DpadStore.Widgets {

    public class MainWindow : Window {

        private FlowBox flowbox;
        private ProgressBar progress_bar;
        private Label status_label;
        private Backend.AppLoader app_loader;
        private Backend.Installer installer;
        private Backend.GamepadManager gamepad;

        private Overlay overlay;
        private Box dialog_backdrop;
        private Label dialog_title_label;
        private Button[] dialog_buttons;
        private int dialog_focused_index;
        private bool dialog_active;
        private AppTile? dialog_tile;

        public MainWindow (Gtk.Application app) {
            this.fullscreen ();
            this.set_application (app);
            this.set_decorated (false);
            this.set_default_size (720, 720);
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

            gamepad = new Backend.GamepadManager ();
            connect_gamepad_signals ();

            this.show_all ();
            hide_mouse_cursor ();
            dialog_backdrop.hide ();

            var first = flowbox.get_child_at_index (0);
            if (first != null) {
                flowbox.select_child (first);
                first.grab_focus ();
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

            flowbox = new FlowBox ();
            flowbox.set_min_children_per_line (2);
            flowbox.set_max_children_per_line (2);
            flowbox.set_homogeneous (true);
            flowbox.set_selection_mode (SelectionMode.SINGLE);
            flowbox.set_row_spacing (0);
            flowbox.set_column_spacing (0);
            flowbox.margin_start = 4;
            flowbox.margin_end = 4;
            populate_grid ();

            var scroll = new ScrolledWindow (null, null);
            scroll.set_policy (PolicyType.NEVER, PolicyType.AUTOMATIC);
            scroll.add (flowbox);
            root_box.pack_start (scroll, true, true, 0);

            var progress_box = new Box (Orientation.VERTICAL, 8);
            progress_box.margin_start = 25;
            progress_box.margin_end = 25;
            progress_box.margin_top = 12;
            progress_box.margin_bottom = 8;

            status_label = new Label (Constants.STATUS_IDLE);
            status_label.set_max_width_chars (65);
            status_label.set_ellipsize (Pango.EllipsizeMode.END);
            progress_bar = new ProgressBar ();
            progress_bar.set_size_request (-1, 24);

            progress_box.pack_start (status_label, false, false, 0);
            progress_box.pack_start (progress_bar, false, false, 0);

            root_box.pack_end (build_footer (), false, false, 0);
            root_box.pack_end (progress_box, false, false, 0);

            overlay = new Overlay ();
            overlay.add (root_box);
            build_dialog_overlay ();
            this.add (overlay);
        }

        private Box build_header () {
            var header_box = new Box (Orientation.HORIZONTAL, 12);
            header_box.halign = Align.CENTER;
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

            var title_label = new Label (Constants.PROGRAM_NAME);
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
            footer_box.margin_bottom = 16;
            footer_box.margin_top = 8;

            var left_box = new Box (Orientation.HORIZONTAL, 0);
            left_box.halign = Align.START;
            left_box.pack_start (
                build_footer_item (
                    Constants.GFX_CONTROL_A, Constants.FOOTER_LABEL_INSTALL
                ), false, false, 24
            );
            left_box.pack_start (
                build_footer_item (
                    Constants.GFX_CONTROL_B, Constants.FOOTER_LABEL_BACK
                ), false, false, 24
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

        private Button build_dialog_button (string icon_name, string text) {
            var btn = new Button ();
            var btn_box = new Box (Orientation.HORIZONTAL, 10);
            btn_box.halign = Align.CENTER;

            var icon = new Image.from_icon_name (
                icon_name, IconSize.LARGE_TOOLBAR
            );
            var label = new Label (text);

            btn_box.pack_start (icon, false, false, 0);
            btn_box.pack_start (label, false, false, 0);
            btn.add (btn_box);

            return btn;
        }

        private void build_dialog_overlay () {
            dialog_backdrop = new Box (Orientation.VERTICAL, 0);
            dialog_backdrop.get_style_context ().add_class (
                Constants.CSS_CLASS_DIALOG_BACKDROP
            );
            dialog_backdrop.set_halign (Align.FILL);
            dialog_backdrop.set_valign (Align.FILL);
            dialog_backdrop.set_hexpand (true);
            dialog_backdrop.set_vexpand (true);
            var dialog_panel = new Box (Orientation.VERTICAL, 16);
            dialog_panel.get_style_context ().add_class (
                Constants.CSS_CLASS_APP_DIALOG
            );
            dialog_panel.set_halign (Align.CENTER);
            dialog_panel.set_valign (Align.CENTER);
            dialog_panel.set_size_request (Constants.DIALOG_WIDTH, -1);

            dialog_title_label = new Label ("");
            dialog_title_label.get_style_context ().add_class (
                Constants.CSS_CLASS_DIALOG_TITLE
            );
            dialog_panel.pack_start (dialog_title_label, false, false, 16);

            var buttons_box = new Box (Orientation.VERTICAL, 8);
            buttons_box.margin_start = 24;
            buttons_box.margin_end = 24;
            buttons_box.margin_bottom = 24;

            var update_btn = build_dialog_button (
                Constants.ICON_DIALOG_UPDATE,
                Constants.DIALOG_BTN_UPDATE
            );
            update_btn.get_style_context ().add_class (
                Constants.CSS_CLASS_DIALOG_BUTTON
            );
            update_btn.clicked.connect (() => {
                handle_dialog_response (Constants.DIALOG_RESPONSE_UPDATE);
            });

            var uninstall_btn = build_dialog_button (
                Constants.ICON_DIALOG_UNINSTALL,
                Constants.DIALOG_BTN_UNINSTALL
            );
            uninstall_btn.get_style_context ().add_class (
                Constants.CSS_CLASS_DIALOG_BUTTON
            );
            uninstall_btn.get_style_context ().add_class (
                Constants.CSS_CLASS_DIALOG_BUTTON_DANGER
            );
            uninstall_btn.clicked.connect (() => {
                handle_dialog_response (Constants.DIALOG_RESPONSE_UNINSTALL);
            });

            var cancel_btn = build_dialog_button (
                Constants.ICON_DIALOG_CANCEL,
                Constants.DIALOG_BTN_CANCEL
            );
            cancel_btn.get_style_context ().add_class (
                Constants.CSS_CLASS_DIALOG_BUTTON
            );
            cancel_btn.clicked.connect (() => {
                hide_dialog_overlay ();
            });

            buttons_box.pack_start (update_btn, false, false, 0);
            buttons_box.pack_start (uninstall_btn, false, false, 0);
            buttons_box.pack_start (cancel_btn, false, false, 0);

            dialog_panel.pack_start (buttons_box, false, false, 0);

            dialog_buttons = { update_btn, uninstall_btn, cancel_btn };

            dialog_backdrop.set_center_widget (dialog_panel);
            overlay.add_overlay (dialog_backdrop);
        }

        private void populate_grid () {
            var app_names = app_loader.load_app_names ();
            for (int i = 0; i < app_names.length; i++) {
                var name = app_names[i];
                var path = app_loader.get_app_path (name);
                bool installed = app_loader.is_installed (name);
                flowbox.add (new AppTile (name, path, installed));
            }
        }

        private void connect_signals () {
            this.key_press_event.connect ((e) => {
                if (e.keyval == Gdk.Key.Escape) {
                    this.get_application ().quit ();
                }
                return false;
            });

            flowbox.child_activated.connect ((child) => {
                var tile = child as AppTile;
                if (tile == null) return;

                if (tile.is_installed) {
                    show_installed_app_dialog (tile);
                } else {
                    flowbox.set_sensitive (false);
                    installer.install (tile.app_name);
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
                flowbox.set_sensitive (true);
                update_tile_status (app_name);
            });

            installer.failed.connect ((error_message) => {
                status_label.set_text (
                    Constants.STATUS_ERROR.printf (error_message)
                );
                flowbox.set_sensitive (true);
            });
        }

        private void connect_gamepad_signals () {
            gamepad.direction_pressed.connect ((direction) => {
                if (dialog_active) {
                    navigate_dialog (direction);
                } else {
                    navigate_flowbox (direction);
                }
            });

            gamepad.button_a_pressed.connect (() => {
                if (dialog_active) {
                    activate_dialog_button ();
                } else {
                    activate_selected_tile ();
                }
            });

            gamepad.button_b_pressed.connect (() => {
                if (dialog_active) {
                    hide_dialog_overlay ();
                } else {
                    this.get_application ().quit ();
                }
            });
        }

        private void navigate_flowbox (Backend.GamepadDirection direction) {
            var selected = flowbox.get_selected_children ();
            if (selected == null || selected.length () == 0) {
                var first = flowbox.get_child_at_index (0);
                if (first != null) {
                    flowbox.select_child (first);
                    first.grab_focus ();
                }
                return;
            }

            var current = selected.data;
            int index = current.get_index ();
            int columns = (int) flowbox.get_max_children_per_line ();
            int total = count_flowbox_children ();
            int next_index = index;

            switch (direction) {
                case Backend.GamepadDirection.UP:
                    next_index = index - columns;
                    break;
                case Backend.GamepadDirection.DOWN:
                    next_index = index + columns;
                    break;
                case Backend.GamepadDirection.LEFT:
                    next_index = index - 1;
                    break;
                case Backend.GamepadDirection.RIGHT:
                    next_index = index + 1;
                    break;
            }

            if (next_index < 0 || next_index >= total) return;

            var next_child = flowbox.get_child_at_index (next_index);
            if (next_child != null) {
                flowbox.select_child (next_child);
                next_child.grab_focus ();
            }
        }

        private void activate_selected_tile () {
            var selected = flowbox.get_selected_children ();
            if (selected == null || selected.length () == 0) return;
            flowbox.child_activated (selected.data);
        }

        private int count_flowbox_children () {
            int count = 0;
            while (flowbox.get_child_at_index (count) != null) {
                count++;
            }
            return count;
        }

        private void show_installed_app_dialog (AppTile tile) {
            dialog_tile = tile;
            dialog_title_label.set_text (
                Constants.DIALOG_TITLE.printf (tile.app_name)
            );
            dialog_focused_index = dialog_buttons.length - 1;
            dialog_active = true;
            dialog_backdrop.show_all ();
            dialog_buttons[dialog_focused_index].grab_focus ();
        }

        private void navigate_dialog (Backend.GamepadDirection direction) {
            int count = dialog_buttons.length;
            switch (direction) {
                case Backend.GamepadDirection.UP:
                    dialog_focused_index =
                        (dialog_focused_index - 1 + count) % count;
                    break;
                case Backend.GamepadDirection.DOWN:
                    dialog_focused_index =
                        (dialog_focused_index + 1) % count;
                    break;
                default:
                    return;
            }
            dialog_buttons[dialog_focused_index].grab_focus ();
        }

        private void activate_dialog_button () {
            switch (dialog_focused_index) {
                case 0:
                    handle_dialog_response (
                        Constants.DIALOG_RESPONSE_UPDATE
                    );
                    break;
                case 1:
                    handle_dialog_response (
                        Constants.DIALOG_RESPONSE_UNINSTALL
                    );
                    break;
                default:
                    hide_dialog_overlay ();
                    break;
            }
        }

        private void hide_dialog_overlay () {
            dialog_active = false;
            dialog_backdrop.hide ();
            dialog_tile = null;
            var selected = flowbox.get_selected_children ();
            if (selected != null && selected.length () > 0) {
                selected.data.grab_focus ();
            }
        }

        private void handle_dialog_response (int response) {
            if (dialog_tile == null) return;
            var tile = dialog_tile;
            hide_dialog_overlay ();

            switch (response) {
                case Constants.DIALOG_RESPONSE_UNINSTALL:
                    flowbox.set_sensitive (false);
                    installer.uninstall (tile.app_name);
                    break;
                case Constants.DIALOG_RESPONSE_UPDATE:
                    flowbox.set_sensitive (false);
                    installer.update (tile.app_name);
                    break;
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
            FlowBoxChild? child;
            while ((child = flowbox.get_child_at_index (i)) != null) {
                var tile = child as AppTile;
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
