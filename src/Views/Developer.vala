/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2024 Alain <alainmh23@gmail.com>
*/

public class Views.Developer : Adw.Bin {
    private Granite.ValidatedEntry name_entry;
    private Granite.ValidatedEntry email_entry;
    private Gtk.Button next_button;

    public signal void next (string name, string email);

    construct {
        Regex? email_regex = null;
        try {
            email_regex = new Regex ("^\\S+@\\S+\\.\\S+$");
        } catch (Error e) {
            critical (e.message);
        }

        name_entry = new Granite.ValidatedEntry () {
            margin_top = 6,
            text = GLib.Environment.get_real_name ()
        };

        email_entry = new Granite.ValidatedEntry () {
            regex = email_regex,
            margin_top = 6
        };

        next_button = new Gtk.Button.with_label (_("Next")) {
            margin_bottom = 32,
            sensitive = false,
            vexpand = true,
            valign = END
        };
        next_button.add_css_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);

        var form_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        form_box.append (new Gtk.Label (_("Developer")) {
            halign = START,
            css_classes = { Granite.STYLE_CLASS_H1_LABEL }
        });
        form_box.append (new Granite.HeaderLabel (_("Name:")));
        form_box.append (name_entry);
        form_box.append (new Granite.HeaderLabel (_("Email:")));
        form_box.append (email_entry);
        form_box.append (next_button);

        var content_box = new Adw.Bin () {
            margin_start = 24,
            margin_end = 24,
            hexpand = true,
            child = form_box
        };

        child = content_box;

        name_entry.changed.connect (check_valid);
        email_entry.changed.connect (check_valid);

        next_button.clicked.connect (() => {
            next (name_entry.text, email_entry.text);
        });
    }

    private void check_valid () {
        next_button.sensitive = name_entry.is_valid && email_entry.is_valid;
    }

    public void reset_form () {
        name_entry.text = "";
        email_entry.text = "";
    }
}