/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Juan Pablo Lozano <libredeb@gmail.com>
 */

namespace DpadStore.Constants {
    public const string APP_ID = "io.github.libredeb.dpad-store";
    public const string PROGRAM_NAME = "D-Pad Store";

    // Pi-Apps paths and values
    public const string PI_APPS_DIR = "pi-apps";
    public const string PI_APPS_APPS_SUBDIR = "apps";
    public const string PI_APPS_DATA_SUBDIR = "data";
    public const string PI_APPS_STATUS_SUBDIR = "status";
    public const string PI_APPS_ETC_SUBDIR = "etc";
    public const string PI_APPS_CATEGORIES_FILE = "categories";
    public const string PI_APPS_CATEGORY_OVERRIDES_FILE = "category-overrides";
    public const string PI_APPS_MANAGE_SCRIPT = "manage";
    public const string PI_APPS_INSTALL_ACTION = "install";
    public const string PI_APPS_UNINSTALL_ACTION = "uninstall";
    public const string PI_APPS_UPDATE_ACTION = "update";
    public const string PI_APPS_INSTALLED_STATUS = "installed";
    public const string SHELL_PATH = "/bin/bash";

    // UI labels - Status
    public const string STATUS_IDLE = "Select an application to install...";
    public const string STATUS_INSTALLING = "Installing %s: %s";
    public const string STATUS_UNINSTALLING = "Uninstalling %s: %s";
    public const string STATUS_UPDATING = "Updating %s: %s";
    public const string STATUS_INSTALL_COMPLETE = "Installation of %s complete.";
    public const string STATUS_UNINSTALL_COMPLETE = "%s has been uninstalled.";
    public const string STATUS_UPDATE_COMPLETE = "%s has been updated.";
    public const string STATUS_ERROR = "Error: %s";
    public const string LABEL_INSTALLED = "Installed";
    public const string APP_CATEGORY = "Games";

    // UI labels - Dialog
    public const string DIALOG_TITLE = "%s is already installed";
    public const string DIALOG_BTN_UNINSTALL = "Uninstall";
    public const string DIALOG_BTN_UPDATE = "Update";
    public const string DIALOG_BTN_CANCEL = "Cancel";

    // Dialog response IDs
    public const int DIALOG_RESPONSE_UNINSTALL = 1;
    public const int DIALOG_RESPONSE_UPDATE = 2;

    // Error messages
    public const string ERROR_LOADING_APPS = "Error loading applications: %s\n";
    public const string ERROR_READING_CATEGORIES = "Error reading categories from %s: %s\n";

    // GFX asset paths
    public const string GFX_INSTALL_SLUG = "dpad-store";
    public const string GFX_SUBDIR = "gfx";
    public const string GFX_DPAD_ICON = "d-pad.svg";
    public const string GFX_CONTROL_A = "control_A.png";
    public const string GFX_CONTROL_B = "controls_B.png";

    // UI labels - Footer
    public const string FOOTER_LABEL_INSTALL = "Install";
    public const string FOOTER_LABEL_BACK = "Back";

    // Tile configuration
    public const int TILE_ICON_SIZE = 48;
    public const int HEADER_ICON_SIZE = 40;
    public const int FOOTER_ICON_SIZE = 24;
    public const double PASTEL_BLEND_FACTOR = 1.2;

    // CSS classes and icon names
    public const string CSS_CLASS_INSTALLED_BADGE = "installed-badge";
    public const string CSS_CLASS_APP_DIALOG = "app-dialog";
    public const string CSS_CLASS_DIALOG_TITLE = "dialog-title";
    public const string CSS_CLASS_DIALOG_BUTTON = "dialog-button";
    public const string CSS_CLASS_DIALOG_BUTTON_DANGER = "dialog-button-danger";
    public const string CSS_CLASS_HEADER_BOX = "header-box";
    public const string CSS_CLASS_HEADER_ICON = "header-icon";
    public const string CSS_CLASS_HEADER_TITLE = "header-title";
    public const string CSS_CLASS_APP_TILE = "app-tile";
    public const string CSS_CLASS_FOOTER_BOX = "footer-box";
    public const string CSS_CLASS_FOOTER_LABEL = "footer-label";
    public const string ICON_FALLBACK = "package-x-generic";

    public static string get_gfx_path (string filename) {
        return Path.build_filename (
            Config.PACKAGE_SHAREDIR, GFX_INSTALL_SLUG, GFX_SUBDIR, filename
        );
    }
}
