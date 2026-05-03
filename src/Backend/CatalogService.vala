/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Juan Pablo Lozano <libredeb@gmail.com>
 */

namespace DpadStore.Backend {

    public class CatalogService : Object {

        private Soup.Session session;
        private int64 catalog_version;
        private string cache_dir;
        private string cache_path;

        public CatalogService () {
            session = new Soup.Session ();
            catalog_version = 0;
            cache_dir = Path.build_filename (
                Environment.get_user_cache_dir (), Constants.CACHE_DIR_NAME
            );
            cache_path = Path.build_filename (
                cache_dir, Constants.CACHE_CATALOG_FILE
            );
        }

        public async GenericArray<AppInfo> load_catalog () {
            string? remote_data = yield fetch_remote ();

            if (remote_data != null) {
                int64 remote_version = extract_version (remote_data);

                if (remote_version != catalog_version) {
                    catalog_version = remote_version;
                    save_cache (remote_data);
                }

                var apps = parse_catalog (remote_data);
                info (
                    Constants.INFO_CATALOG_LOADED,
                    apps.length,
                    catalog_version
                );
                return apps;
            }

            string? cached_data = load_from_cache ();
            if (cached_data != null) {
                info (Constants.INFO_USING_CACHE);
                catalog_version = extract_version (cached_data);
                return parse_catalog (cached_data);
            }

            warning (Constants.ERROR_NO_CATALOG);
            return new GenericArray<AppInfo> ();
        }

        private async string? fetch_remote () {
            var message = new Soup.Message (
                "GET", Constants.CATALOG_URL
            );

            SourceFunc callback = fetch_remote.callback;
            session.queue_message (message, () => {
                Idle.add ((owned) callback);
            });
            yield;

            if (message.status_code != 200) {
                warning (
                    Constants.ERROR_FETCHING_CATALOG,
                    "HTTP %u".printf (message.status_code)
                );
                return null;
            }

            return (string) message.response_body.flatten ().data;
        }

        private int64 extract_version (string json_data) {
            try {
                var parser = new Json.Parser ();
                parser.load_from_data (json_data);
                var root = parser.get_root ().get_object ();
                if (root.has_member ("version")) {
                    return root.get_int_member ("version");
                }
            } catch (Error e) {
                warning (Constants.ERROR_PARSING_CATALOG, e.message);
            }
            return 0;
        }

        private GenericArray<AppInfo> parse_catalog (string json_data) {
            var apps = new GenericArray<AppInfo> ();
            try {
                var parser = new Json.Parser ();
                parser.load_from_data (json_data);
                var root = parser.get_root ().get_object ();

                if (!root.has_member ("games")) {
                    return apps;
                }

                var games_array = root.get_array_member ("games");
                for (uint i = 0; i < games_array.get_length (); i++) {
                    var game_obj = games_array.get_object_element (i);
                    if (game_obj != null && game_obj.has_member ("id")) {
                        apps.add (new AppInfo.from_json (game_obj));
                    }
                }
            } catch (Error e) {
                warning (Constants.ERROR_PARSING_CATALOG, e.message);
            }
            return apps;
        }

        private string? load_from_cache () {
            if (!FileUtils.test (cache_path, FileTest.EXISTS)) {
                return null;
            }
            try {
                string contents;
                FileUtils.get_contents (cache_path, out contents);
                return contents;
            } catch (FileError e) {
                warning (Constants.ERROR_FETCHING_CATALOG, e.message);
                return null;
            }
        }

        private void save_cache (string data) {
            try {
                DirUtils.create_with_parents (cache_dir, 0755);
                FileUtils.set_contents (cache_path, data);
            } catch (FileError e) {
                warning (Constants.ERROR_SAVING_CACHE, e.message);
            }
        }
    }
}
