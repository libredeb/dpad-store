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
    public const string ANSI_ESCAPE_PATTERN = "\\x1b\\[[0-9;]*[a-zA-Z]";

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

    // Gamepad configuration
    public const string GAMECONTROLLER_DB_FILE = "gamecontrollerdb.txt";
    public const uint GAMEPAD_POLL_INTERVAL_MS = 16;
    public const int16 GAMEPAD_AXIS_THRESHOLD = 16000;

    // Error/warning messages - SDL & Gamepad
    public const string ERROR_SDL_INIT = "Failed to initialize SDL: %s\n";
    public const string WARN_NO_CONTROLLER = "No game controller detected";
    public const string WARN_INCOMPATIBLE_CONTROLLER = "Game controller is not compatible";
    public const string WARN_UNABLE_OPEN_CONTROLLER = "Unable to open game controller: %s";

    // Dialog configuration
    public const int DIALOG_WIDTH = 420;

    // Tile configuration
    public const int TILE_ICON_SIZE = 48;
    public const int HEADER_ICON_SIZE = 40;
    public const int FOOTER_ICON_SIZE = 24;
    public const double PASTEL_DARK_FACTOR = 0.55;
    public const double PASTEL_DARKER_FACTOR = 0.3;

    // Dithering configuration
    public const int DITHER_TILE_SIZE = 64;
    public const int DITHER_NOISE_ALPHA = 6;
    public const double TILE_CORNER_RADIUS = 12.0;
    public const double GRADIENT_ALPHA = 0.95;
    public const string CSS_TILE_TRANSPARENT_BG =
        ".%s:selected { background-image: none; background-color: transparent; }";

    // CSS classes and icon names
    public const string CSS_CLASS_INSTALLED_BADGE = "installed-badge";
    public const string CSS_CLASS_DIALOG_BACKDROP = "dialog-backdrop";
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
    public const string ICON_DIALOG_UPDATE = "view-refresh-symbolic";
    public const string ICON_DIALOG_UNINSTALL = "user-trash-symbolic";
    public const string ICON_DIALOG_CANCEL = "window-close-symbolic";

    public static string get_gfx_path (string filename) {
        return Path.build_filename (
            Config.PACKAGE_SHAREDIR, GFX_INSTALL_SLUG, GFX_SUBDIR, filename
        );
    }
}
