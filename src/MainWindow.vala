/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2021 Your Name <you@email.com>
*/

public class MainWindow : Gtk.ApplicationWindow {
    private Gtk.Stack main_stack;

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            default_height: 300,
            default_width: 300,
            icon_name: "applications-development",
            title: _("App Generator")
        );
    }

    static construct {
		weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
		default_theme.add_resource_path ("/io/github/ecommunity/app-generator/");
	}

    construct {
        var dir = Environment.get_user_data_dir ();
        print ("DIR: %s".printf (dir));

        var headerbar = new Gtk.HeaderBar () {
			title_widget = new Gtk.Label (null),
			hexpand = true
		};

        var form_view = new Views.Form ();
        var success_view = new Views.Success ();

        main_stack = new Gtk.Stack () {
            transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT
        };
        main_stack.add_named (form_view, "form");
        main_stack.add_named (success_view, "success");

        var toolbar_view = new Adw.ToolbarView ();
		toolbar_view.add_top_bar (headerbar);
		toolbar_view.content = main_stack;

        child = toolbar_view;

        // We need to hide the title area for the split headerbar
        var null_title = new Gtk.Grid () {
            visible = false
        };
        set_titlebar (null_title);

        // Set default elementary thme
        var gtk_settings = Gtk.Settings.get_default ();
        gtk_settings.gtk_icon_theme_name = "elementary";
        if (!(gtk_settings.gtk_theme_name.has_prefix ("io.elementary.stylesheet"))) {
            gtk_settings.gtk_theme_name = "io.elementary.stylesheet.blueberry";
        }

        form_view.created.connect ((project_naame, location) => {
            success_view.project_location = location + "/" + project_naame;

            main_stack.visible_child_name = "success";
            success_view.animation = true;

            Timeout.add_once (1000, () => {
                success_view.animation = false;
                form_view.reset_form ();
            });
        });

        success_view.back.connect (() => {
            main_stack.visible_child_name = "form";
        });
    }
}
