/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2024 Alain <alainmh23@gmail.com>
*/

public class Widgets.Stepper : Gtk.Grid {
    private Gtk.Box main_box;

    public int index { get; set; default = 0; }

    int _active_index = 0;
    public int active_index {
        get {
            return _active_index;
        }

        set {
            foreach (Gtk.Button button in stepper_map.values) {
                button.remove_css_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);
            }

            if (stepper_map.has_key (value)) {
                stepper_map.get (value).add_css_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);
            }

            _active_index = value;
            activeStepChange ();
        }
    }

    public signal void activeStepChange ();

    private Gee.HashMap<int, Gtk.Button> stepper_map = new Gee.HashMap<int, Gtk.Button> ();

    construct {
        main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        attach (main_box, 0, 0);
    }

    public void add_step (string name) {
        var number_button = new Gtk.Button.with_label ((index + 1).to_string ()) {
            width_request = 24
        };
        number_button.set_data ("index", index);

        if (index <= 0) {
            number_button.add_css_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);
        }

        //  number_button.clicked.connect (() => {
        //      active_index = number_button.get_data ("index");
        //  });

        var name_label = new Gtk.Label (name);
        name_label.add_css_class ("fw-500");

        var button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        button_box.append (number_button);
        button_box.append (name_label);

        if (index > 0) {
            main_box.append (new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
                width_request = 24,
                valign = CENTER,
                margin_start = 12,
                margin_end = 12
            });
        }

        main_box.append (button_box);

        stepper_map[index] = number_button;
        index++;
    }
}
