/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Juan Pablo Lozano <libredeb@gmail.com>
 */

namespace DpadStore.Backend {

    public class IconService : Object {

        private Soup.Session session;
        private string icons_dir;

        public IconService () {
            session = new Soup.Session ();
            icons_dir = Path.build_filename (
                Environment.get_user_cache_dir (),
                Constants.CACHE_DIR_NAME,
                Constants.CACHE_ICONS_DIR
            );
            DirUtils.create_with_parents (icons_dir, 0755);
        }

        public string get_cached_path (string app_id) {
            return Path.build_filename (
                icons_dir,
                app_id + Constants.CACHE_ICON_EXTENSION
            );
        }

        public async string? ensure_icon (string app_id, string icon_url) {
            string local_path = get_cached_path (app_id);

            if (FileUtils.test (local_path, FileTest.EXISTS)) {
                return local_path;
            }

            if (icon_url == "") {
                return null;
            }

            return yield download_icon (app_id, icon_url, local_path);
        }

        private async string? download_icon (
            string app_id, string icon_url, string local_path
        ) {
            var message = new Soup.Message ("GET", icon_url);

            SourceFunc callback = download_icon.callback;
            session.queue_message (message, () => {
                Idle.add ((owned) callback);
            });
            yield;

            if (message.status_code != 200) {
                warning (
                    Constants.ERROR_DOWNLOADING_ICON,
                    app_id,
                    "HTTP %u".printf (message.status_code)
                );
                return null;
            }

            try {
                unowned uint8[] data = message.response_body.flatten ().data;
                FileUtils.set_data (local_path, data);
                return local_path;
            } catch (Error e) {
                warning (
                    Constants.ERROR_DOWNLOADING_ICON, app_id, e.message
                );
                return null;
            }
        }
    }
}
