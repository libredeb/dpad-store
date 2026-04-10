/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Juan Pablo Lozano <libredeb@gmail.com>
 */

using Gtk;
using GLib;

namespace DpadStore {

    public class App : Gtk.Application {

        public Widgets.MainWindow main_window;

        public void build_and_run () {
            this.main_window = new Widgets.MainWindow (this);
        }

        public App () {
            Object (
                application_id: Constants.APP_ID,
                flags: GLib.ApplicationFlags.HANDLES_OPEN
            );
            Intl.setlocale (LocaleCategory.ALL, "");
            Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
            Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
            Intl.textdomain (GETTEXT_PACKAGE);
        }

        private static App app;
        public static App get_instance () {
            if (app == null)
                app = new App ();
            return app;
        }

        protected override void activate () {
            if (this.main_window == null)
                build_and_run ();

            this.main_window.present ();
        }
    }
}
