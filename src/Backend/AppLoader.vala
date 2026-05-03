/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Juan Pablo Lozano <libredeb@gmail.com>
 */

namespace DpadStore.Backend {

    public class AppLoader {

        private string status_path;
        private CatalogService catalog_service;
        public IconService icon_service { get; private set; }

        public AppLoader () {
            var pi_apps_dir = Path.build_filename (
                Environment.get_home_dir (), Constants.PI_APPS_DIR
            );
            this.status_path = Path.build_filename (
                pi_apps_dir,
                Constants.PI_APPS_DATA_SUBDIR,
                Constants.PI_APPS_STATUS_SUBDIR
            );
            this.catalog_service = new CatalogService ();
            this.icon_service = new IconService ();
        }

        public async GenericArray<AppInfo> load_apps () {
            return yield catalog_service.load_catalog ();
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
