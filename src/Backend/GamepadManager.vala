/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Juan Pablo Lozano <libredeb@gmail.com>
 */

namespace DpadStore.Backend {

    public enum GamepadDirection {
        UP,
        DOWN,
        LEFT,
        RIGHT
    }

    public class GamepadManager : Object {

        public signal void direction_pressed (GamepadDirection direction);
        public signal void button_a_pressed ();
        public signal void button_b_pressed ();

        private SDL.Input.GameController? controller = null;
        private uint poll_source_id = 0;
        private bool axis_x_held = false;
        private bool axis_y_held = false;

        public GamepadManager () {
            load_controller_db ();

            if (SDL.init (SDL.InitFlag.GAMECONTROLLER) < 0) {
                stderr.printf (
                    Constants.ERROR_SDL_INIT,
                    SDL.get_error ()
                );
                return;
            }

            try_open_controller ();
            start_polling ();
        }

        ~GamepadManager () {
            stop_polling ();
            controller = null;
            SDL.quit ();
        }

        private void load_controller_db () {
            string db_path = Path.build_filename (
                Config.PACKAGE_SHAREDIR,
                Constants.GFX_INSTALL_SLUG,
                Constants.GAMECONTROLLER_DB_FILE
            );
            if (FileUtils.test (db_path, FileTest.EXISTS)) {
                SDL.Hint.set_hint (
                    SDL.Hint.SDL_HINT_GAMECONTROLLERCONFIG_FILE,
                    db_path
                );
            }
        }

        private void try_open_controller () {
            int num_controllers = SDL.Input.GameController.count ();
            if (
                (num_controllers < 1) ||
                (!SDL.Input.GameController.is_game_controller (0))
            ) {
                warning (num_controllers < 1
                    ? Constants.WARN_NO_CONTROLLER
                    : Constants.WARN_INCOMPATIBLE_CONTROLLER
                );
                return;
            }

            controller = new SDL.Input.GameController (0);
            if (controller == null) {
                warning (
                    Constants.WARN_UNABLE_OPEN_CONTROLLER,
                    SDL.get_error ()
                );
            }
        }

        private void start_polling () {
            poll_source_id = GLib.Timeout.add (
                Constants.GAMEPAD_POLL_INTERVAL_MS, poll_events
            );
        }

        private void stop_polling () {
            if (poll_source_id != 0) {
                GLib.Source.remove (poll_source_id);
                poll_source_id = 0;
            }
        }

        private bool poll_events () {
            SDL.Event event;
            while (SDL.Event.poll (out event) != 0) {
                switch (event.type) {
                    case SDL.EventType.CONTROLLERDEVICEADDED:
                        if (controller == null) {
                            try_open_controller ();
                        }
                        break;

                    case SDL.EventType.CONTROLLERDEVICEREMOVED:
                        controller = null;
                        break;

                    case SDL.EventType.CONTROLLERBUTTONDOWN:
                        handle_button_down (event.cbutton);
                        break;

                    case SDL.EventType.CONTROLLERAXISMOTION:
                        handle_axis_motion (event.caxis);
                        break;

                    default:
                        break;
                }
            }
            return GLib.Source.CONTINUE;
        }

        private void handle_button_down (SDL.ControllerButtonEvent ev) {
            var button = (SDL.Input.GameController.Button) ev.button;

            switch (button) {
                case SDL.Input.GameController.Button.A:
                    button_a_pressed ();
                    break;

                case SDL.Input.GameController.Button.B:
                    button_b_pressed ();
                    break;

                case SDL.Input.GameController.Button.DPAD_UP:
                    direction_pressed (GamepadDirection.UP);
                    break;

                case SDL.Input.GameController.Button.DPAD_DOWN:
                    direction_pressed (GamepadDirection.DOWN);
                    break;

                case SDL.Input.GameController.Button.DPAD_LEFT:
                    direction_pressed (GamepadDirection.LEFT);
                    break;

                case SDL.Input.GameController.Button.DPAD_RIGHT:
                    direction_pressed (GamepadDirection.RIGHT);
                    break;

                default:
                    break;
            }
        }

        private void handle_axis_motion (SDL.ControllerAxisEvent ev) {
            int16 threshold = Constants.GAMEPAD_AXIS_THRESHOLD;
            int16 val = ev.value;
            var axis = (SDL.Input.GameController.Axis) ev.axis;

            if (axis == SDL.Input.GameController.Axis.LEFTX) {
                if (val < -threshold && !axis_x_held) {
                    axis_x_held = true;
                    direction_pressed (GamepadDirection.LEFT);
                } else if (val > threshold && !axis_x_held) {
                    axis_x_held = true;
                    direction_pressed (GamepadDirection.RIGHT);
                } else if (val > -threshold && val < threshold) {
                    axis_x_held = false;
                }
            } else if (axis == SDL.Input.GameController.Axis.LEFTY) {
                if (val < -threshold && !axis_y_held) {
                    axis_y_held = true;
                    direction_pressed (GamepadDirection.UP);
                } else if (val > threshold && !axis_y_held) {
                    axis_y_held = true;
                    direction_pressed (GamepadDirection.DOWN);
                } else if (val > -threshold && val < threshold) {
                    axis_y_held = false;
                }
            }
        }
    }
}
