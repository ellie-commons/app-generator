/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2024 Alain <alainmh23@gmail.com>
*/

public class Widgets.InvalidLabel : Gtk.Grid {
    private Gtk.Label text_label;
    private Gtk.Revealer label_revealer;

    public string text {
        set {
            text_label.label = value;
        }

        get {
            return text_label.label;
        }
    }

    public bool reveal_child {
        set {
            label_revealer.reveal_child = value;
        }

        get {
            return label_revealer.reveal_child;
        }
    }

    construct {
        text_label = new Gtk.Label (null) {
            xalign = 0,
            wrap = true
        };
        text_label.add_css_class ("error");
        text_label.add_css_class (Granite.STYLE_CLASS_SMALL_LABEL);

        label_revealer = new Gtk.Revealer () {
            child = text_label
        };

        attach (label_revealer, 0, 0, 1, 1);
    }
}
