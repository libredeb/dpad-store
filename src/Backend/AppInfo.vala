/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Juan Pablo Lozano <libredeb@gmail.com>
 */

namespace DpadStore.Backend {

    public class AppInfo : Object {

        public string id { get; set; default = ""; }
        public string name { get; set; default = ""; }
        public string version { get; set; default = ""; }
        public string genre { get; set; default = ""; }
        public string size { get; set; default = ""; }
        public string description { get; set; default = ""; }
        public string icon_url { get; set; default = ""; }
        public string deb_url { get; set; default = ""; }

        public AppInfo () {}

        public AppInfo.from_json (Json.Object obj) {
            this.id = obj.has_member ("id") ? obj.get_string_member ("id") : "";
            this.name = obj.has_member ("name") ? obj.get_string_member ("name") : "";
            this.version = obj.has_member ("version") ? obj.get_string_member ("version") : "";
            this.genre = obj.has_member ("genre") ? obj.get_string_member ("genre") : "";
            this.size = obj.has_member ("size") ? obj.get_string_member ("size") : "";
            this.description = obj.has_member ("description") ? obj.get_string_member ("description") : "";
            this.icon_url = obj.has_member ("icon") ? obj.get_string_member ("icon") : "";
            this.deb_url = obj.has_member ("deb") ? obj.get_string_member ("deb") : "";
        }
    }
}
