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
    public const string PI_APPS_INSTALLED_STATUS = "installed";
    public const string SHELL_PATH = "/bin/bash";

    // UI labels
    public const string STATUS_IDLE = "Select an application to install...";
    public const string STATUS_PROCESSING = "Processing %s: %s";
    public const string STATUS_COMPLETE = "Installation of %s complete.";
    public const string STATUS_ERROR = "Error: %s";
    public const string LABEL_INSTALLED = "Installed";
    public const string APP_CATEGORY = "Games";

    // Error messages
    public const string ERROR_LOADING_APPS = "Error loading applications: %s\n";
    public const string ERROR_READING_CATEGORIES = "Error reading categories from %s: %s\n";

    // CSS classes and icon names
    public const string CSS_CLASS_INSTALLED_BADGE = "installed-badge";
    public const string ICON_FALLBACK = "package-x-generic";
}
