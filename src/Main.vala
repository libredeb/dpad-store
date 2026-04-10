/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Juan Pablo Lozano <libredeb@gmail.com>
 */

int main (string[] args) {
    var app = DpadStore.App.get_instance ();
    return app.run (args);
}
