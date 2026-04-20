/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Juan Pablo Lozano <libredeb@gmail.com>
 */

using Gtk;

namespace DpadStore.Widgets {

    public class AppTile : FlowBoxChild {

        public string app_name { get; private set; }
        public bool is_installed { get { return installed_label != null; } }
        private Label? installed_label;
        private Box content_box;

        public AppTile (string name, string path, bool installed) {
            this.app_name = name;

            get_style_context ().add_class (Constants.CSS_CLASS_APP_TILE);

            content_box = new Box (Orientation.VERTICAL, 8);
            content_box.halign = Align.CENTER;
            content_box.valign = Align.CENTER;
            content_box.margin = 12;

            string icon_path = Path.build_filename (path, "icon-64.png");
            Gdk.Pixbuf? icon_pixbuf = null;
            Image img;

            if (FileUtils.test (icon_path, FileTest.EXISTS)) {
                try {
                    icon_pixbuf = new Gdk.Pixbuf.from_file_at_scale (
                        icon_path, Constants.TILE_ICON_SIZE,
                        Constants.TILE_ICON_SIZE, true
                    );
                    img = new Image.from_pixbuf (icon_pixbuf);
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

            var label = new Label (name);
            label.set_line_wrap (true);
            label.set_max_width_chars (14);
            label.set_justify (Justification.CENTER);
            label.halign = Align.CENTER;

            content_box.pack_start (img, false, false, 0);
            content_box.pack_start (label, false, false, 0);

            if (installed) {
                installed_label = new Label (Constants.LABEL_INSTALLED);
                installed_label.get_style_context ().add_class (
                    Constants.CSS_CLASS_INSTALLED_BADGE
                );
                content_box.pack_start (installed_label, false, false, 0);
            }

            this.add (content_box);

            if (icon_pixbuf != null) {
                apply_pastel_background (icon_pixbuf);
            }
        }

        public void mark_installed () {
            if (installed_label != null) return;
            installed_label = new Label (Constants.LABEL_INSTALLED);
            installed_label.get_style_context ().add_class (
                Constants.CSS_CLASS_INSTALLED_BADGE
            );
            content_box.pack_start (installed_label, false, false, 0);
            installed_label.show ();
        }

        public void mark_uninstalled () {
            if (installed_label == null) return;
            installed_label.destroy ();
            installed_label = null;
        }

        private void apply_pastel_background (Gdk.Pixbuf pixbuf) {
            int r_avg, g_avg, b_avg;
            extract_dominant_color (pixbuf, out r_avg, out g_avg, out b_avg);

            double blend = Constants.PASTEL_BLEND_FACTOR;
            int pr = (int) ((r_avg + 255 * blend) / (1.0 + blend));
            int pg = (int) ((g_avg + 255 * blend) / (1.0 + blend));
            int pb = (int) ((b_avg + 255 * blend) / (1.0 + blend));

            var css_str = ".app-tile { background-color: rgba(%d, %d, %d, 0.45); }".printf (
                pr, pg, pb
            );

            var provider = new CssProvider ();
            try {
                provider.load_from_data (css_str, css_str.length);
                get_style_context ().add_provider (
                    provider, STYLE_PROVIDER_PRIORITY_APPLICATION + 1
                );
            } catch (Error e) {
                stderr.printf ("CSS error: %s\n", e.message);
            }
        }

        private void extract_dominant_color (
            Gdk.Pixbuf pixbuf, out int r, out int g, out int b
        ) {
            unowned uint8[] pixels = pixbuf.get_pixels ();
            int n_channels = pixbuf.get_n_channels ();
            int rowstride = pixbuf.get_rowstride ();
            int width = pixbuf.get_width ();
            int height = pixbuf.get_height ();
            bool has_alpha = pixbuf.get_has_alpha ();

            long sum_r = 0, sum_g = 0, sum_b = 0;
            long count = 0;

            for (int y = 0; y < height; y++) {
                for (int x = 0; x < width; x++) {
                    int offset = y * rowstride + x * n_channels;
                    uint8 pr = pixels[offset];
                    uint8 pg = pixels[offset + 1];
                    uint8 pb = pixels[offset + 2];

                    if (has_alpha && n_channels >= 4) {
                        uint8 pa = pixels[offset + 3];
                        if (pa < 128) continue;
                    }

                    if (pr < 15 && pg < 15 && pb < 15) continue;
                    if (pr > 240 && pg > 240 && pb > 240) continue;

                    sum_r += pr;
                    sum_g += pg;
                    sum_b += pb;
                    count++;
                }
            }

            if (count > 0) {
                r = (int) (sum_r / count);
                g = (int) (sum_g / count);
                b = (int) (sum_b / count);
            } else {
                r = 100; g = 100; b = 100;
            }
        }
    }
}
