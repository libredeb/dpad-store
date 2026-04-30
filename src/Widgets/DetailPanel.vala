/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Juan Pablo Lozano <libredeb@gmail.com>
 */

using Gtk;

namespace DpadStore.Widgets {

    public class DetailPanel : Box {

        public signal void action_requested (string app_name, string action);
        public signal void focus_returned ();

        private Image cover_image;
        private Label status_label;
        private Label size_label;
        private Image status_icon;
        private Box buttons_box;
        private Label description_title;
        private Label description_label;
        private Button[] action_buttons;
        private int focused_button_index;
        private bool has_focus_on_buttons;

        private string? current_app_name;
        private string? current_app_path;
        private bool current_installed;

        public DetailPanel () {
            Object (orientation: Orientation.VERTICAL, spacing: 12);

            get_style_context ().add_class (Constants.CSS_CLASS_DETAIL_PANEL);
            this.valign = Align.START;

            action_buttons = {};
            focused_button_index = 0;
            has_focus_on_buttons = false;
            current_app_name = null;

            build_ui ();
        }

        private void build_ui () {
            cover_image = new Image ();
            cover_image.get_style_context ().add_class (
                Constants.CSS_CLASS_DETAIL_COVER
            );
            cover_image.set_size_request (
                Constants.COVER_IMAGE_SIZE, Constants.COVER_IMAGE_SIZE
            );
            cover_image.halign = Align.CENTER;
            this.pack_start (cover_image, false, false, 0);

            var status_box = new Box (Orientation.HORIZONTAL, 8);
            status_box.margin_top = 4;
            status_box.margin_start = 16;
            status_box.margin_end = 16;

            var status_left = new Box (Orientation.HORIZONTAL, 6);
            status_left.halign = Align.START;
            status_icon = new Image ();
            status_label = new Label ("");
            status_label.get_style_context ().add_class (
                Constants.CSS_CLASS_DETAIL_STATUS
            );
            status_left.pack_start (status_icon, false, false, 0);
            status_left.pack_start (status_label, false, false, 0);

            size_label = new Label ("");
            size_label.get_style_context ().add_class (
                Constants.CSS_CLASS_DETAIL_SIZE
            );
            size_label.halign = Align.END;

            status_box.pack_start (status_left, false, false, 0);
            status_box.pack_end (size_label, false, false, 0);
            this.pack_start (status_box, false, false, 0);

            buttons_box = new Box (Orientation.VERTICAL, 6);
            buttons_box.margin_start = 16;
            buttons_box.margin_end = 16;
            buttons_box.margin_top = 8;
            this.pack_start (buttons_box, false, false, 0);

            description_title = new Label (Constants.LABEL_DESCRIPTION);
            description_title.get_style_context ().add_class (
                Constants.CSS_CLASS_DETAIL_DESCRIPTION_TITLE
            );
            description_title.halign = Align.START;
            description_title.margin_start = 16;
            description_title.margin_top = 12;
            this.pack_start (description_title, false, false, 0);

            description_label = new Label ("");
            description_label.get_style_context ().add_class (
                Constants.CSS_CLASS_DETAIL_DESCRIPTION_TEXT
            );
            description_label.halign = Align.START;
            description_label.set_line_wrap (true);
            description_label.set_line_wrap_mode (Pango.WrapMode.WORD_CHAR);
            description_label.set_lines (Constants.DESCRIPTION_MAX_LINES);
            description_label.set_ellipsize (Pango.EllipsizeMode.END);
            description_label.set_xalign (0);
            description_label.margin_start = 16;
            description_label.margin_end = 16;
            description_label.margin_top = 4;
            this.pack_start (description_label, false, false, 0);
        }

        public void update_for_app (
            string name, string path, bool installed,
            string size, string description
        ) {
            current_app_name = name;
            current_app_path = path;
            current_installed = installed;
            has_focus_on_buttons = false;
            focused_button_index = 0;

            load_cover_image (path);
            update_status (installed, size);
            rebuild_buttons (installed);
            update_description (description);

            this.show_all ();
            if (size == "") {
                size_label.hide ();
            }
            if (description == "") {
                description_title.hide ();
                description_label.hide ();
            }
        }

        public void clear () {
            current_app_name = null;
            cover_image.clear ();
            status_label.set_text ("");
            clear_buttons ();
        }

        private void load_cover_image (string path) {
            string icon_path = Path.build_filename (path, "icon-64.png");
            if (FileUtils.test (icon_path, FileTest.EXISTS)) {
                try {
                    var pixbuf = new Gdk.Pixbuf.from_file_at_scale (
                        icon_path, Constants.COVER_IMAGE_SIZE,
                        Constants.COVER_IMAGE_SIZE, false
                    );
                    cover_image.set_from_pixbuf (pixbuf);
                } catch (Error e) {
                    cover_image.set_from_icon_name (
                        Constants.ICON_FALLBACK, IconSize.DIALOG
                    );
                }
            } else {
                cover_image.set_from_icon_name (
                    Constants.ICON_FALLBACK, IconSize.DIALOG
                );
            }
        }

        private void update_status (bool installed, string size = "") {
            var ctx = status_label.get_style_context ();
            ctx.remove_class (Constants.CSS_CLASS_DETAIL_STATUS_INSTALLED);
            ctx.remove_class (Constants.CSS_CLASS_DETAIL_STATUS_NOT_INSTALLED);
            ctx.remove_class (Constants.CSS_CLASS_DETAIL_STATUS_INSTALLING);

            if (installed) {
                status_label.set_text (Constants.LABEL_INSTALLED);
                ctx.add_class (Constants.CSS_CLASS_DETAIL_STATUS_INSTALLED);
                status_icon.set_from_icon_name (
                    Constants.ICON_STATUS_INSTALLED, IconSize.MENU
                );
                size_label.set_text (size);
            } else {
                status_label.set_text (Constants.LABEL_NOT_INSTALLED);
                ctx.add_class (Constants.CSS_CLASS_DETAIL_STATUS_NOT_INSTALLED);
                status_icon.set_from_icon_name (
                    Constants.ICON_STATUS_DOWNLOAD, IconSize.MENU
                );
                size_label.set_text (size);
            }
        }

        private void update_description (string description) {
            description_label.set_text (description);
        }

        public void set_installing_status () {
            var ctx = status_label.get_style_context ();
            ctx.remove_class (Constants.CSS_CLASS_DETAIL_STATUS_INSTALLED);
            ctx.remove_class (Constants.CSS_CLASS_DETAIL_STATUS_NOT_INSTALLED);
            ctx.add_class (Constants.CSS_CLASS_DETAIL_STATUS_INSTALLING);

            status_label.set_text (Constants.LABEL_INSTALLING);
            status_icon.set_from_icon_name (
                Constants.ICON_STATUS_DOWNLOAD, IconSize.MENU
            );
            size_label.hide ();
        }

        private void clear_buttons () {
            buttons_box.get_children ().foreach ((child) => {
                child.destroy ();
            });
            action_buttons = {};
            focused_button_index = 0;
        }

        private void rebuild_buttons (bool installed) {
            clear_buttons ();

            if (installed) {
                add_action_button (
                    Constants.ICON_PLAY,
                    Constants.BTN_PLAY,
                    Constants.CSS_CLASS_ACTION_BUTTON_PRIMARY,
                    Constants.PI_APPS_PLAY_ACTION
                );
                add_action_button (
                    Constants.ICON_UPDATE,
                    Constants.BTN_UPDATE,
                    Constants.CSS_CLASS_ACTION_BUTTON,
                    Constants.PI_APPS_UPDATE_ACTION
                );
                add_action_button (
                    Constants.ICON_UNINSTALL,
                    Constants.BTN_UNINSTALL,
                    Constants.CSS_CLASS_ACTION_BUTTON_DANGER,
                    Constants.PI_APPS_UNINSTALL_ACTION
                );
            } else {
                add_action_button (
                    Constants.ICON_INSTALL,
                    Constants.BTN_INSTALL,
                    Constants.CSS_CLASS_ACTION_BUTTON_PRIMARY,
                    Constants.PI_APPS_INSTALL_ACTION
                );
            }
        }

        private void add_action_button (
            string icon_name, string label_text,
            string css_class, string action
        ) {
            var btn = new Button ();
            var btn_box = new Box (Orientation.HORIZONTAL, 10);
            btn_box.halign = Align.START;

            var icon = new Image.from_icon_name (
                icon_name, IconSize.SMALL_TOOLBAR
            );
            var label = new Label (label_text);

            btn_box.pack_start (icon, false, false, 0);
            btn_box.pack_start (label, false, false, 0);
            btn.add (btn_box);

            btn.get_style_context ().add_class (
                Constants.CSS_CLASS_ACTION_BUTTON
            );
            if (css_class != Constants.CSS_CLASS_ACTION_BUTTON) {
                btn.get_style_context ().add_class (css_class);
            }

            btn.clicked.connect (() => {
                if (current_app_name != null) {
                    action_requested (current_app_name, action);
                }
            });

            buttons_box.pack_start (btn, false, false, 0);
            action_buttons += btn;
        }

        public void set_focus_on_buttons () {
            if (action_buttons.length == 0) return;
            has_focus_on_buttons = true;
            focused_button_index = 0;
            action_buttons[0].grab_focus ();
        }

        public void release_button_focus () {
            has_focus_on_buttons = false;
        }

        public bool get_has_focus_on_buttons () {
            return has_focus_on_buttons;
        }

        public void navigate_buttons (Backend.GamepadDirection direction) {
            if (action_buttons.length == 0) return;

            int count = action_buttons.length;
            switch (direction) {
                case Backend.GamepadDirection.UP:
                    focused_button_index =
                        (focused_button_index - 1 + count) % count;
                    break;
                case Backend.GamepadDirection.DOWN:
                    focused_button_index =
                        (focused_button_index + 1) % count;
                    break;
                default:
                    return;
            }
            action_buttons[focused_button_index].grab_focus ();
        }

        public void activate_focused_button () {
            if (action_buttons.length == 0) return;
            action_buttons[focused_button_index].clicked ();
        }

        public void refresh_for_state (bool installed) {
            current_installed = installed;
            update_status (installed);
            rebuild_buttons (installed);
            this.show_all ();
        }
    }
}
