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
    public const string PI_APPS_PLAY_ACTION = "play";
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
    public const string APP_CATEGORY = "Games";
    public const string GENRE_UNKNOWN = "Unknown";

    // UI labels - Detail panel status
    public const string LABEL_INSTALLED = "INSTALLED";
    public const string LABEL_NOT_INSTALLED = "NOT INSTALLED";
    public const string LABEL_INSTALLING = "INSTALLING";

    // UI labels - Detail panel description
    public const string LABEL_DESCRIPTION = "Description";
    public const int DESCRIPTION_MAX_LINES = 3;

    // UI labels - Detail panel action buttons
    public const string BTN_INSTALL = "INSTALL";
    public const string BTN_PLAY = "PLAY";
    public const string BTN_UPDATE = "UPDATE";
    public const string BTN_UNINSTALL = "UNINSTALL";

    // UI labels - Console output
    public const string CONSOLE_STARTING = "Starting...";

    // Error messages
    public const string ERROR_LOADING_APPS = "Error loading applications: %s\n";
    public const string ERROR_READING_CATEGORIES = "Error reading categories from %s: %s\n";
    public const string ERROR_DESKTOP_NOT_FOUND = "No .desktop file found for %s";
    public const string ERROR_LAUNCH_FAILED = "Failed to launch %s: %s";

    // GFX asset paths
    public const string GFX_INSTALL_SLUG = "dpad-store";
    public const string GFX_SUBDIR = "gfx";
    public const string GFX_DPAD_ICON = "d-pad.svg";
    public const string GFX_CONTROL_A = "control_A.png";
    public const string GFX_CONTROL_B = "controls_B.png";

    // UI labels - Footer
    public const string FOOTER_LABEL_INSTALL = "Select";
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

    // Tile configuration
    public const int TILE_ICON_SIZE = 64;
    public const int HEADER_ICON_SIZE = 40;
    public const int FOOTER_ICON_SIZE = 48;

    // Detail panel configuration
    public const int COVER_IMAGE_SIZE = 200;
    public const int DETAIL_BUTTON_ICON_SIZE = 20;
    public const double DETAIL_PANEL_RATIO = 0.55;

    // Console output configuration
    public const int CONSOLE_MAX_LINES = 500;
    public const uint CONSOLE_HIDE_DELAY_MS = 3000;
    public const int CONSOLE_EXPANDED_HEIGHT = 180;

    // CSS classes - Header
    public const string CSS_CLASS_HEADER_BOX = "header-box";
    public const string CSS_CLASS_HEADER_ICON = "header-icon";
    public const string CSS_CLASS_HEADER_TITLE = "header-title";

    // CSS classes - App list tile
    public const string CSS_CLASS_APP_TILE = "app-tile";
    public const string CSS_CLASS_TILE_NAME = "tile-name";
    public const string CSS_CLASS_TILE_CATEGORY = "tile-category";

    // CSS classes - Detail panel
    public const string CSS_CLASS_DETAIL_PANEL = "detail-panel";
    public const string CSS_CLASS_DETAIL_COVER = "detail-cover";
    public const string CSS_CLASS_DETAIL_STATUS = "detail-status";
    public const string CSS_CLASS_DETAIL_STATUS_INSTALLED = "detail-status-installed";
    public const string CSS_CLASS_DETAIL_STATUS_NOT_INSTALLED = "detail-status-not-installed";
    public const string CSS_CLASS_DETAIL_STATUS_INSTALLING = "detail-status-installing";
    public const string CSS_CLASS_DETAIL_SIZE = "detail-size";
    public const string CSS_CLASS_DETAIL_DESCRIPTION_TITLE = "detail-description-title";
    public const string CSS_CLASS_DETAIL_DESCRIPTION_TEXT = "detail-description-text";
    public const string CSS_CLASS_ACTION_BUTTON = "action-button";
    public const string CSS_CLASS_ACTION_BUTTON_PRIMARY = "action-button-primary";
    public const string CSS_CLASS_ACTION_BUTTON_DANGER = "action-button-danger";

    // CSS classes - Console output
    public const string CSS_CLASS_CONSOLE_BOX = "console-box";
    public const string CSS_CLASS_CONSOLE_HEADER = "console-header";
    public const string CSS_CLASS_CONSOLE_TEXT = "console-text";
    public const string CSS_CLASS_CONSOLE_TOGGLE = "console-toggle";

    // CSS classes - Layout containers
    public const string CSS_CLASS_CONTENT_BOX = "content-box";
    public const string CSS_CLASS_APP_LIST_PANEL = "app-list-panel";
    public const string CSS_CLASS_DETAIL_PANEL_CONTAINER = "detail-panel-container";

    // CSS classes - Footer
    public const string CSS_CLASS_FOOTER_BOX = "footer-box";
    public const string CSS_CLASS_FOOTER_LABEL = "footer-label";

    // Icon names
    public const string ICON_FALLBACK = "package-x-generic";
    public const string ICON_INSTALL = "emblem-downloads-symbolic";
    public const string ICON_PLAY = "media-playback-start-symbolic";
    public const string ICON_UPDATE = "view-refresh-symbolic";
    public const string ICON_UNINSTALL = "user-trash-symbolic";
    public const string ICON_CONSOLE_EXPAND = "pan-down-symbolic";
    public const string ICON_CONSOLE_COLLAPSE = "pan-up-symbolic";

    public static string get_gfx_path (string filename) {
        return Path.build_filename (
            Config.PACKAGE_SHAREDIR, GFX_INSTALL_SLUG, GFX_SUBDIR, filename
        );
    }
}
