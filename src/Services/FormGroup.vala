/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2021 Your Name <you@email.com>
*/

public class FormGroup : GLib.Object {
    private Gee.ArrayList<FormControl> controls;

    public signal void value_changed (FormControl control, string new_value);

    public bool valid {
        get {
            foreach (FormControl control in controls) {
                if (!control.valid) {
                    return false;
                }
            }

            return true;
        }
    }

    public FormGroup () {
        controls = new Gee.ArrayList<FormControl>();
    }

    public void add_control (FormControl control) {
        controls.add (control);
        control.value_changed.connect ((new_value) => {
            value_changed (control, new_value);
        });
    }
}
