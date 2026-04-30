/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Juan Pablo Lozano <libredeb@gmail.com>
 */

using Gtk;

namespace DpadStore.Widgets {

    public class AppTile : ListBoxRow {

        public string app_name { get; private set; }
        public string app_path { get; private set; }
        public string app_genre { get; private set; }
        public bool is_installed { get; private set; }

        public AppTile (string name, string path, string genre, bool installed) {
            this.app_name = name;
            this.app_path = path;
            this.app_genre = genre;
            this.is_installed = installed;

            get_style_context ().add_class (Constants.CSS_CLASS_APP_TILE);

            var content_box = new Box (Orientation.HORIZONTAL, 12);
            content_box.margin = 8;
            content_box.margin_start = 12;
            content_box.margin_end = 12;

            string icon_path = Path.build_filename (path, "icon-64.png");
            Image img;

            if (FileUtils.test (icon_path, FileTest.EXISTS)) {
                try {
                    var pixbuf = new Gdk.Pixbuf.from_file_at_scale (
                        icon_path, Constants.TILE_ICON_SIZE,
                        Constants.TILE_ICON_SIZE, true
                    );
                    img = new Image.from_pixbuf (pixbuf);
                } catch (Error e) {
                    img = new Image.from_icon_name (
                        Constants.ICON_FALLBACK, IconSize.DND
                    );
                }
            } else {
                img = new Image.from_icon_name (
                    Constants.ICON_FALLBACK, IconSize.DND
                );
            }

            var text_box = new Box (Orientation.VERTICAL, 2);
            text_box.valign = Align.CENTER;

            var name_label = new Label (name);
            name_label.get_style_context ().add_class (
                Constants.CSS_CLASS_TILE_NAME
            );
            name_label.halign = Align.START;
            name_label.set_ellipsize (Pango.EllipsizeMode.END);
            name_label.set_max_width_chars (20);

            var genre_label = new Label (genre);
            genre_label.get_style_context ().add_class (
                Constants.CSS_CLASS_TILE_CATEGORY
            );
            genre_label.halign = Align.START;
            genre_label.set_ellipsize (Pango.EllipsizeMode.END);
            genre_label.set_max_width_chars (30);

            text_box.pack_start (name_label, false, false, 0);
            text_box.pack_start (genre_label, false, false, 0);

            content_box.pack_start (img, false, false, 0);
            content_box.pack_start (text_box, true, true, 0);

            this.add (content_box);
        }

        public void mark_installed () {
            is_installed = true;
        }

        public void mark_uninstalled () {
            is_installed = false;
        }
    }
}
