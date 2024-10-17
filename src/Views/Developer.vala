/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2024 Alain <alainmh23@gmail.com>
*/

public class Views.Developer : Adw.Bin {
    private Granite.ValidatedEntry name_entry;
    private Granite.ValidatedEntry email_entry;
    private Gtk.Button next_button;

    public signal void next (string name, string email);

    public bool is_valid {
        get {
            return name_entry.is_valid && email_entry.is_valid;
        }
    }

    construct {
        Regex? email_regex = null;
        try {
            email_regex = new Regex ("^\\S+@\\S+\\.\\S+$");
        } catch (Error e) {
            critical (e.message);
        }

        name_entry = new Granite.ValidatedEntry () {
            text = GLib.Environment.get_real_name ()
        };

        var name_invalid = new Widgets.InvalidLabel () {
            text = _("This field is required")
        };

        var name_box = new Gtk.Box (VERTICAL, 6);
        name_box.append (new Granite.HeaderLabel (_("Name")) {
            mnemonic_widget = name_entry
        });
        name_box.append (name_entry);
        name_box.append (name_invalid);

        email_entry = new Granite.ValidatedEntry () {
            regex = email_regex,
        };

        var email_invalid = new Widgets.InvalidLabel () {
            text = _("The email is invalid")
        };

        var email_box = new Gtk.Box (VERTICAL, 6);
        email_box.append (new Granite.HeaderLabel (_("Email")) {
            mnemonic_widget = email_entry
        });
        email_box.append (email_entry);
        email_box.append (email_invalid);

        next_button = new Gtk.Button.with_label (_("Next")) {
            margin_bottom = 32,
            sensitive = false,
            vexpand = true,
            valign = END
        };
        next_button.add_css_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);

        var form_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 24);
        form_box.append (new Gtk.Label (_("Developer")) {
            halign = START,
            css_classes = { Granite.STYLE_CLASS_H1_LABEL }
        });
        form_box.append (name_box);
        form_box.append (email_box);
        form_box.append (next_button);

        var content_box = new Adw.Bin () {
            margin_start = 24,
            margin_end = 24,
            hexpand = true,
            child = form_box
        };

        child = content_box;

        name_entry.changed.connect (() => {
            check_valid ();
            name_invalid.reveal_child = !name_entry.is_valid;
        });

        email_entry.changed.connect (() => {
            check_valid ();
            email_invalid.reveal_child = !email_entry.is_valid;
        });

        name_entry.activate.connect (go_next);
        email_entry.activate.connect (go_next);
        next_button.clicked.connect (go_next);
    }

    private void go_next () {
        if (is_valid) {
            next (name_entry.text, email_entry.text);
        }
    }

    private void check_valid () {
        next_button.sensitive = is_valid;
    }

    public void reset_form () {
        name_entry.text = "";
        email_entry.text = "";
    }
}
