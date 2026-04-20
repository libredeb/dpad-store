/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Juan Pablo Lozano <libredeb@gmail.com>
 */

using Gtk;

namespace DpadStore.Widgets {

    public class AppListRow : ListBoxRow {

        public string app_name { get; private set; }
        public bool is_installed { get { return installed_label != null; } }
        private Label? installed_label;

        public AppListRow (string name, string path, bool installed) {
            this.app_name = name;

            var box = new Box (Orientation.HORIZONTAL, 20);

            string icon_path = Path.build_filename (path, "icon-64.png");
            Image img;
            if (FileUtils.test (icon_path, FileTest.EXISTS)) {
                img = new Image.from_file (icon_path);
            } else {
                img = new Image.from_icon_name (Constants.ICON_FALLBACK, IconSize.DND);
            }

            var label = new Label (name);

            box.pack_start (img, false, false, 0);
            box.pack_start (label, false, false, 0);

            if (installed) {
                installed_label = new Label (Constants.LABEL_INSTALLED);
                installed_label.get_style_context ().add_class (Constants.CSS_CLASS_INSTALLED_BADGE);
                box.pack_end (installed_label, false, false, 0);
            }

            this.add (box);
        }

        public void mark_installed () {
            if (installed_label != null) return;
            var box = this.get_child () as Box;
            if (box == null) return;
            installed_label = new Label (Constants.LABEL_INSTALLED);
            installed_label.get_style_context ().add_class (Constants.CSS_CLASS_INSTALLED_BADGE);
            box.pack_end (installed_label, false, false, 0);
            installed_label.show ();
        }

        public void mark_uninstalled () {
            if (installed_label == null) return;
            installed_label.destroy ();
            installed_label = null;
        }
    }
}
