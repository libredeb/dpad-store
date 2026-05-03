/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Juan Pablo Lozano <libredeb@gmail.com>
 */

using Gtk;

namespace DpadStore.Widgets {

    public class AppTile : ListBoxRow {

        public Backend.AppInfo app_info { get; private set; }
        public bool is_installed { get; private set; }

        private Image icon_image;
        private Backend.IconService icon_service;

        public AppTile (
            Backend.AppInfo info,
            Backend.IconService icon_svc,
            bool installed
        ) {
            this.app_info = info;
            this.icon_service = icon_svc;
            this.is_installed = installed;

            get_style_context ().add_class (Constants.CSS_CLASS_APP_TILE);

            var content_box = new Box (Orientation.HORIZONTAL, 12);
            content_box.margin = 8;
            content_box.margin_start = 12;
            content_box.margin_end = 12;

            icon_image = new Image.from_icon_name (
                Constants.ICON_FALLBACK, IconSize.DND
            );

            var text_box = new Box (Orientation.VERTICAL, 2);
            text_box.valign = Align.CENTER;

            var name_label = new Label (info.name);
            name_label.get_style_context ().add_class (
                Constants.CSS_CLASS_TILE_NAME
            );
            name_label.halign = Align.START;
            name_label.set_ellipsize (Pango.EllipsizeMode.END);
            name_label.set_max_width_chars (20);

            var genre_label = new Label (info.genre);
            genre_label.get_style_context ().add_class (
                Constants.CSS_CLASS_TILE_CATEGORY
            );
            genre_label.halign = Align.START;
            genre_label.set_ellipsize (Pango.EllipsizeMode.END);
            genre_label.set_max_width_chars (30);

            text_box.pack_start (name_label, false, false, 0);
            text_box.pack_start (genre_label, false, false, 0);

            content_box.pack_start (icon_image, false, false, 0);
            content_box.pack_start (text_box, true, true, 0);

            this.add (content_box);

            load_icon_async.begin ();
        }

        private async void load_icon_async () {
            string? path = yield icon_service.ensure_icon (
                app_info.id, app_info.icon_url
            );
            if (path != null) {
                try {
                    var pixbuf = new Gdk.Pixbuf.from_file_at_scale (
                        path, Constants.TILE_ICON_SIZE,
                        Constants.TILE_ICON_SIZE, true
                    );
                    icon_image.set_from_pixbuf (pixbuf);
                } catch (Error e) {
                    // Keep fallback icon
                }
            }
        }

        public void mark_installed () {
            is_installed = true;
        }

        public void mark_uninstalled () {
            is_installed = false;
        }
    }
}
