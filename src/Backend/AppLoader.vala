/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Juan Pablo Lozano <libredeb@gmail.com>
 */

namespace DpadStore.Backend {

    public class AppLoader {

        private string apps_path;
        private string status_path;
        private string pi_apps_dir;

        public AppLoader (string pi_apps_dir) {
            this.pi_apps_dir = pi_apps_dir;
            this.apps_path = Path.build_filename (
                pi_apps_dir, Constants.PI_APPS_APPS_SUBDIR
            );
            this.status_path = Path.build_filename (
                pi_apps_dir, Constants.PI_APPS_DATA_SUBDIR, Constants.PI_APPS_STATUS_SUBDIR
            );
        }

        public GenericArray<string> load_app_names () {
            var category_map = load_categories ();
            var names = new GenericArray<string> ();
            try {
                var dir = Dir.open (apps_path, 0);
                string? name;
                while ((name = dir.read_name ()) != null) {
                    string full_path = Path.build_filename (apps_path, name);
                    if (!FileUtils.test (full_path, FileTest.IS_DIR)) {
                        continue;
                    }
                    string? category = category_map.lookup (name);
                    if (category == Constants.APP_CATEGORY) {
                        names.add (name);
                    }
                }
            } catch (Error e) {
                stderr.printf (Constants.ERROR_LOADING_APPS, e.message);
            }
            return names;
        }

        private HashTable<string, string> load_categories () {
            var map = new HashTable<string, string> (str_hash, str_equal);

            // Pi-Apps merges: user overrides first, then defaults. First match wins.
            string[] sources = {
                Path.build_filename (
                    pi_apps_dir, Constants.PI_APPS_DATA_SUBDIR,
                    Constants.PI_APPS_CATEGORY_OVERRIDES_FILE
                ),
                Path.build_filename (
                    pi_apps_dir, Constants.PI_APPS_ETC_SUBDIR,
                    Constants.PI_APPS_CATEGORIES_FILE
                )
            };

            foreach (string path in sources) {
                parse_category_file (path, map);
            }

            return map;
        }

        private void parse_category_file (string path, HashTable<string, string> map) {
            if (!FileUtils.test (path, FileTest.EXISTS)) {
                return;
            }
            try {
                string contents;
                FileUtils.get_contents (path, out contents);
                foreach (string line in contents.split ("\n")) {
                    string stripped = line.strip ();
                    if (stripped == "" || !stripped.contains ("|")) {
                        continue;
                    }
                    string[] parts = stripped.split ("|", 2);
                    string app_name = parts[0].strip ();
                    string category = parts[1].strip ();
                    if (app_name != "" && !map.contains (app_name)) {
                        map.insert (app_name, category);
                    }
                }
            } catch (FileError e) {
                stderr.printf (Constants.ERROR_READING_CATEGORIES, path, e.message);
            }
        }

        public string get_app_path (string app_name) {
            return Path.build_filename (apps_path, app_name);
        }

        public bool is_installed (string app_name) {
            string file_path = Path.build_filename (status_path, app_name);
            if (!FileUtils.test (file_path, FileTest.EXISTS)) {
                return false;
            }
            try {
                string contents;
                FileUtils.get_contents (file_path, out contents);
                return contents.strip () == Constants.PI_APPS_INSTALLED_STATUS;
            } catch (FileError e) {
                return false;
            }
        }
    }
}
