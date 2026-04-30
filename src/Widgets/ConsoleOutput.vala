/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Juan Pablo Lozano <libredeb@gmail.com>
 */

using Gtk;

namespace DpadStore.Widgets {

    public class ConsoleOutput : Box {

        private ProgressBar progress_bar;
        private Label status_label;
        private ScrolledWindow console_scroll;
        private TextView console_view;
        private TextBuffer console_buffer;
        private Button toggle_button;
        private Image toggle_icon;
        private bool expanded;
        private uint pulse_timer_id;
        private uint hide_timer_id;

        public ConsoleOutput () {
            Object (orientation: Orientation.VERTICAL, spacing: 4);

            get_style_context ().add_class (Constants.CSS_CLASS_CONSOLE_BOX);
            this.margin_start = 16;
            this.margin_end = 16;
            this.margin_top = 8;
            this.margin_bottom = 8;

            expanded = false;
            pulse_timer_id = 0;
            hide_timer_id = 0;

            build_ui ();
        }

        private void build_ui () {
            var header_box = new Box (Orientation.HORIZONTAL, 8);
            header_box.get_style_context ().add_class (
                Constants.CSS_CLASS_CONSOLE_HEADER
            );

            status_label = new Label ("");
            status_label.halign = Align.START;
            status_label.hexpand = true;
            status_label.set_ellipsize (Pango.EllipsizeMode.END);
            status_label.set_max_width_chars (50);

            toggle_icon = new Image.from_icon_name (
                Constants.ICON_CONSOLE_EXPAND, IconSize.MENU
            );
            toggle_button = new Button ();
            toggle_button.add (toggle_icon);
            toggle_button.get_style_context ().add_class (
                Constants.CSS_CLASS_CONSOLE_TOGGLE
            );
            toggle_button.clicked.connect (toggle_console);

            header_box.pack_start (status_label, true, true, 0);
            header_box.pack_end (toggle_button, false, false, 0);
            this.pack_start (header_box, false, false, 0);

            progress_bar = new ProgressBar ();
            progress_bar.set_size_request (-1, 20);
            this.pack_start (progress_bar, false, false, 0);

            console_buffer = new TextBuffer (null);
            console_view = new TextView.with_buffer (console_buffer);
            console_view.set_editable (false);
            console_view.set_cursor_visible (false);
            console_view.set_wrap_mode (WrapMode.WORD_CHAR);
            console_view.get_style_context ().add_class (
                Constants.CSS_CLASS_CONSOLE_TEXT
            );

            console_scroll = new ScrolledWindow (null, null);
            console_scroll.set_policy (
                PolicyType.NEVER, PolicyType.AUTOMATIC
            );
            console_scroll.add (console_view);
            console_scroll.set_size_request (
                -1, Constants.CONSOLE_EXPANDED_HEIGHT
            );
            this.pack_start (console_scroll, false, false, 0);
        }

        public void start_operation (string app_name) {
            cancel_hide_timer ();

            status_label.set_text (Constants.CONSOLE_STARTING);
            console_buffer.set_text ("", 0);
            progress_bar.set_fraction (0);

            start_pulse_animation ();
            this.show_all ();

            if (!expanded) {
                console_scroll.hide ();
            }
        }

        public void append_output (string text) {
            TextIter end_iter;
            console_buffer.get_end_iter (out end_iter);
            console_buffer.insert (ref end_iter, text + "\n", -1);

            int line_count = console_buffer.get_line_count ();
            if (line_count > Constants.CONSOLE_MAX_LINES) {
                TextIter start;
                TextIter trim_end;
                console_buffer.get_start_iter (out start);
                console_buffer.get_iter_at_line (
                    out trim_end,
                    line_count - Constants.CONSOLE_MAX_LINES
                );
                console_buffer.delete (ref start, ref trim_end);
            }

            scroll_to_bottom ();
        }

        public void update_status (string message) {
            status_label.set_text (message);
            progress_bar.pulse ();
        }

        public void finish_operation (string message) {
            stop_pulse_animation ();
            status_label.set_text (message);
            progress_bar.set_fraction (1.0);

            hide_timer_id = GLib.Timeout.add (
                Constants.CONSOLE_HIDE_DELAY_MS, () => {
                    this.hide ();
                    progress_bar.set_fraction (0);
                    hide_timer_id = 0;
                    return GLib.Source.REMOVE;
                }
            );
        }

        public void show_error (string message) {
            stop_pulse_animation ();
            status_label.set_text (message);
            progress_bar.set_fraction (0);
        }

        public void focus_toggle_button () {
            toggle_button.grab_focus ();
        }

        public void activate_toggle () {
            toggle_console ();
        }

        private void toggle_console () {
            expanded = !expanded;
            if (expanded) {
                console_scroll.show ();
                toggle_icon.set_from_icon_name (
                    Constants.ICON_CONSOLE_COLLAPSE, IconSize.MENU
                );
                scroll_to_bottom ();
            } else {
                console_scroll.hide ();
                toggle_icon.set_from_icon_name (
                    Constants.ICON_CONSOLE_EXPAND, IconSize.MENU
                );
            }
        }

        private void scroll_to_bottom () {
            var adj = console_scroll.get_vadjustment ();
            adj.set_value (adj.get_upper () - adj.get_page_size ());
        }

        private void start_pulse_animation () {
            stop_pulse_animation ();
            pulse_timer_id = GLib.Timeout.add (100, () => {
                progress_bar.pulse ();
                return GLib.Source.CONTINUE;
            });
        }

        private void stop_pulse_animation () {
            if (pulse_timer_id != 0) {
                GLib.Source.remove (pulse_timer_id);
                pulse_timer_id = 0;
            }
        }

        private void cancel_hide_timer () {
            if (hide_timer_id != 0) {
                GLib.Source.remove (hide_timer_id);
                hide_timer_id = 0;
            }
        }
    }
}
