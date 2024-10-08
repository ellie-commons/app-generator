/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2024 Alain <alainmh23@gmail.com>
*/

public class Views.Success : Adw.Bin {
    private Gtk.Image success_icon;

    public bool animation {
        set {
            if (value) {
                success_icon.add_css_class ("animation");
            } else {
                success_icon.remove_css_class ("animation");
            }
            
        }
    }

    public string project_location { get; set; }

    public signal void back ();

    construct {
        success_icon = new Gtk.Image.from_icon_name ("emblem-default") {
            pixel_size = 64,
            css_classes = { "fancy-turn" }
        };

        var success_label = new Gtk.Label (_("The project was created successfully")) {
            wrap = true,
            justify = CENTER
        };

        success_label.add_css_class (Granite.STYLE_CLASS_H1_LABEL);

        var option_listbox = new Gtk.ListBox () {
            margin_top = 24
        };
        option_listbox.add_css_class ("boxed-list");
        option_listbox.add_css_class ("rich-list");
        option_listbox.add_css_class ("separators");

        option_listbox.append (create_row (_("Open in the File Browser"), "folder"));
        //  option_listbox.append (create_row (_("Open in Terminal"), "utilities-terminal"));
        option_listbox.append (create_row (_("Create New Project"), "window-new"));

        var success_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12) {
            vexpand = true,
            valign = CENTER,
            halign = CENTER,
            margin_start = 24,
            margin_end = 24
        };

        success_box.append (success_icon);
        success_box.append (success_label);
        success_box.append (option_listbox);

        child = success_box;

        option_listbox.row_activated.connect ((row) => {
            if (row.get_index () == 0) {
                open_file_browser ();
            } else {
                back ();
            }
        });
    }

    private void open_file_browser () {
        GLib.File file = File.new_for_path (project_location);
        string uri_string = file.get_uri ();

        try {
            AppInfo.launch_default_for_uri (uri_string, null);
        } catch (Error e) {
            message (e.message);
        }
    }

    private void open_terminal () {
        string command = "io.elementary.terminal --working-directory=%s".printf (project_location);

        try {
            Process.spawn_command_line_async (command);
        } catch (Error e) {
            message (e.message);
        }
    }

    private Gtk.ListBoxRow create_row (string title, string icon) {
        var row_icon = new Gtk.Image.from_icon_name (icon) {
            pixel_size = 24
        };

        var row_label = new Gtk.Label (title);
        
        var row_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        row_box.append (row_icon);
        row_box.append (row_label);
        row_box.append (new Gtk.Image.from_icon_name ("pan-end-symbolic") {
            hexpand = true,
            halign = END
        });

        var row = new Gtk.ListBoxRow () {
            child = row_box
        };

        return row;
    }
}