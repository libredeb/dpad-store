/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Juan Pablo Lozano <libredeb@gmail.com>
 */

using Gtk;

namespace DpadStore.Widgets {

    public class AppTile : FlowBoxChild {

        public string app_name { get; private set; }
        public bool is_installed { get; private set; }
        private Label badge_label;
        private Box content_box;

        private bool has_gradient = false;
        private double grad_r1;
        private double grad_g1;
        private double grad_b1;
        private double grad_r2;
        private double grad_g2;
        private double grad_b2;
        private static Cairo.Pattern? dither_pattern = null;

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

            this.is_installed = installed;
            badge_label = new Label (Constants.LABEL_INSTALLED);
            badge_label.get_style_context ().add_class (
                Constants.CSS_CLASS_INSTALLED_BADGE
            );
            badge_label.set_opacity (installed ? 1.0 : 0.0);
            content_box.pack_start (badge_label, false, false, 0);

            this.add (content_box);

            if (icon_pixbuf != null) {
                apply_focus_gradient (icon_pixbuf);
            }
        }

        public void mark_installed () {
            is_installed = true;
            badge_label.set_opacity (1.0);
        }

        public void mark_uninstalled () {
            is_installed = false;
            badge_label.set_opacity (0.0);
        }

        private static void ensure_dither_pattern () {
            if (dither_pattern != null) return;

            int size = Constants.DITHER_TILE_SIZE;
            var surface = new Cairo.ImageSurface (
                Cairo.Format.ARGB32, size, size
            );
            unowned uint8[] data = surface.get_data ();
            int stride = surface.get_stride ();
            uint8 alpha = (uint8) Constants.DITHER_NOISE_ALPHA;

            uint32 seed = 42;
            for (int y = 0; y < size; y++) {
                for (int x = 0; x < size; x++) {
                    seed = seed * 1664525 + 1013904223;
                    bool bright = ((seed >> 16) & 1) == 0;
                    int off = y * stride + x * 4;
                    if (bright) {
                        data[off + 0] = alpha;
                        data[off + 1] = alpha;
                        data[off + 2] = alpha;
                        data[off + 3] = alpha;
                    } else {
                        data[off + 0] = 0;
                        data[off + 1] = 0;
                        data[off + 2] = 0;
                        data[off + 3] = alpha;
                    }
                }
            }
            surface.mark_dirty ();

            dither_pattern = new Cairo.Pattern.for_surface (surface);
            dither_pattern.set_extend (Cairo.Extend.REPEAT);
        }

        private void apply_focus_gradient (Gdk.Pixbuf pixbuf) {
            int r_avg, g_avg, b_avg;
            extract_dominant_color (pixbuf, out r_avg, out g_avg, out b_avg);

            double dark = Constants.PASTEL_DARK_FACTOR;
            grad_r1 = r_avg * dark / 255.0;
            grad_g1 = g_avg * dark / 255.0;
            grad_b1 = b_avg * dark / 255.0;

            double darker = Constants.PASTEL_DARKER_FACTOR;
            grad_r2 = r_avg * darker / 255.0;
            grad_g2 = g_avg * darker / 255.0;
            grad_b2 = b_avg * darker / 255.0;

            has_gradient = true;
            ensure_dither_pattern ();

            var css_str = Constants.CSS_TILE_TRANSPARENT_BG.printf (
                Constants.CSS_CLASS_APP_TILE
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

        public override bool draw (Cairo.Context cr) {
            if (has_gradient && this.is_selected ()) {
                cr.save ();

                int w = get_allocated_width ();
                int h = get_allocated_height ();
                double radius = Constants.TILE_CORNER_RADIUS;

                cr.new_path ();
                cr.arc (w - radius, radius, radius,
                    -Math.PI / 2.0, 0);
                cr.arc (w - radius, h - radius, radius,
                    0, Math.PI / 2.0);
                cr.arc (radius, h - radius, radius,
                    Math.PI / 2.0, Math.PI);
                cr.arc (radius, radius, radius,
                    Math.PI, 3.0 * Math.PI / 2.0);
                cr.close_path ();
                cr.clip ();

                var gradient = new Cairo.Pattern.linear (0, 0, 0, h);
                gradient.add_color_stop_rgba (
                    0.0, grad_r1, grad_g1, grad_b1,
                    Constants.GRADIENT_ALPHA
                );
                gradient.add_color_stop_rgba (
                    1.0, grad_r2, grad_g2, grad_b2,
                    Constants.GRADIENT_ALPHA
                );
                cr.set_source (gradient);
                cr.paint ();

                cr.set_source (dither_pattern);
                cr.paint ();

                cr.restore ();
            }

            return base.draw (cr);
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
