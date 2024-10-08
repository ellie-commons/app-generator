/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2024 Alain <alainmh23@gmail.com>
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
        var headerbar = new Gtk.HeaderBar () {
			title_widget = new Gtk.Label (null),
			hexpand = true
		};

        var project_icon = new Gtk.Image.from_icon_name ("applications-development") {
            pixel_size = 96
        };

        var title_label = new Gtk.Label (_("App Generator"));
        title_label.add_css_class (Granite.STYLE_CLASS_H1_LABEL);

        var description_label = new Gtk.Label (_("Create an elementary OS app using one of the pre-made app templates")) {
            wrap = true,
            justify = CENTER
        };
        description_label.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);

        var left_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
            valign = CENTER,
            margin_start = 64,
            margin_end = 64,
            margin_bottom = 32
        };
        left_box.append (project_icon);
        left_box.append (title_label);
        left_box.append (description_label);

        var stepper = new Widgets.Stepper () {
            margin_start = 24,
            margin_end = 24,
            margin_bottom = 24
        };
        stepper.add_step (_("Developer"));
        stepper.add_step (_("Application"));
        stepper.add_step (_("Finalized"));

        var developer_view = new Views.Developer ();
        var form_view = new Views.Form ();
        var success_view = new Views.Success ();

        main_stack = new Gtk.Stack () {
            transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT
        };
        main_stack.add_named (developer_view, "developer");
        main_stack.add_named (form_view, "form");
        main_stack.add_named (success_view, "success");

        var form_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        form_box.append (stepper);
        form_box.append (main_stack);

        var main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            hexpand = true,
            vexpand = true
        };

        main_box.append (left_box);
        main_box.append (new Gtk.Separator (Gtk.Orientation.VERTICAL) {
            margin_bottom = 32
        });
        main_box.append (form_box);

        var toolbar_view = new Adw.ToolbarView ();
		toolbar_view.add_top_bar (headerbar);
		toolbar_view.content = main_box;

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

            stepper.active_index = 2;
            main_stack.visible_child_name = "success";
            success_view.animation = true;

            Timeout.add_once (1000, () => {
                success_view.animation = false;
            });
        });

        form_view.back.connect (() => {
            main_stack.visible_child_name = "developer";
        });

        developer_view.next.connect ((name, email) => {
            stepper.active_index = 1;
            main_stack.visible_child_name = "form";

            form_view.developer_name = name;
            form_view.developer_email = email;
        });

        success_view.back.connect (() => {
            stepper.active_index = 0;
            main_stack.visible_child_name = "developer";

            developer_view.reset_form ();
            form_view.reset_form ();
        });
    }
}
