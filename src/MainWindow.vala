/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2021 Your Name <you@email.com>
*/

public class MainWindow : Gtk.ApplicationWindow {
    string REPOSITORY_TEMPLATE_URL = "https://github.com/elementary-community/elementary-app-template.git";

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
		default_theme.add_resource_path ("/io/github/elementary-community/app-generator/");
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
            hexpand = true,
            margin_start = 24,
            margin_end = 24,
            margin_bottom = 24
        };
        left_box.append (project_icon);
        left_box.append (title_label);
        left_box.append (description_label);

        Regex? project_name_regex = null;
        Regex? identifier_regex = null;
        try {
            project_name_regex = new Regex ("^[a-z]+[a-z0-9]*$");
            identifier_regex = new Regex ("^[a-z]+\\.[a-z0-9]+(\\.[a-z0-9]+)*$");
        } catch (Error e) {
            critical (e.message);
        }

        var project_name_entry = new Granite.ValidatedEntry () {
            regex = project_name_regex,
            margin_top = 6
        };

        var project_name_description = new Gtk.Label (_("A unique name that is used for the project folder and other resources. The name should be in lower case without spaces and should not start with a number.")) {
            wrap = true,
            xalign = 0,
            margin_top = 3
        };
        project_name_description.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);
        project_name_description.add_css_class (Granite.STYLE_CLASS_SMALL_LABEL);

        var identifier_entry = new Granite.ValidatedEntry () {
            regex = identifier_regex,
            margin_top = 6
        };

        var identifier_description = new Gtk.Label (_("A reverse domain-name identifier used to identify the application, such as 'io.github.username'. It may not contain dashes.")) {
            wrap = true,
            xalign = 0,
            margin_top = 3
        };
        identifier_description.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);
        identifier_description.add_css_class (Granite.STYLE_CLASS_SMALL_LABEL);

        var aplication_id_entry = new Gtk.Entry () {
            margin_top = 6,
            editable = false
        };

        var location_entry = new Gtk.Entry () {
            margin_top = 6,
            secondary_icon_name = "folder-symbolic"
        };

        var spinner = new Gtk.Spinner () {
            valign = Gtk.Align.CENTER,
            halign = Gtk.Align.CENTER,
            spinning = true
        };

        var button_stack = new Gtk.Stack () {
            transition_type = Gtk.StackTransitionType.CROSSFADE,
            valign = Gtk.Align.CENTER
        };

        button_stack.add_named (new Gtk.Label (_("Create Project")), "button");
        button_stack.add_named (spinner, "spinner");

        var create_button = new Gtk.Button () {
            child = button_stack,
            margin_top = 24,
            sensitive = false
        };
        create_button.add_css_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);

        var right_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
            margin_start = 24,
            margin_end = 24,
            hexpand = true
        };
        right_box.append (new Granite.HeaderLabel (_("Project Name:")));
        right_box.append (project_name_entry);
        right_box.append (project_name_description);
        right_box.append (new Granite.HeaderLabel (_("Organization Identifier:")));
        right_box.append (identifier_entry);
        right_box.append (identifier_description);
        right_box.append (new Granite.HeaderLabel (_("Aplication ID:")));
        right_box.append (aplication_id_entry);
        right_box.append (new Granite.HeaderLabel (_("Location:")));
        right_box.append (location_entry);
        right_box.append (create_button);

        var main_box = new Gtk.CenterBox () {
            hexpand = true,
            vexpand = true
        };

        main_box.start_widget = left_box;
        main_box.center_widget = new Gtk.Separator (Gtk.Orientation.VERTICAL) {
            margin_bottom = 32
        };
        main_box.end_widget = right_box;

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

        project_name_entry.changed.connect (() => {
            aplication_id_entry.text = identifier_entry.text + "." + project_name_entry.text;
            create_button.sensitive = project_name_entry.is_valid && identifier_entry.is_valid && location_entry.text.length > 0;
        });

        identifier_entry.changed.connect (() => {
            aplication_id_entry.text = identifier_entry.text + "." + project_name_entry.text;
            create_button.sensitive = project_name_entry.is_valid && identifier_entry.is_valid && location_entry.text.length > 0;
        });

        location_entry.changed.connect (() => {
            create_button.sensitive = project_name_entry.is_valid && identifier_entry.is_valid && location_entry.text.length > 0;
        });

        location_entry.icon_release.connect ((icon_pos) => {
            if (icon_pos == Gtk.EntryIconPosition.SECONDARY) {
                var dialog = new Gtk.FileDialog ();
                dialog.select_folder.begin (this, null, (obj, res) => {
                    try {
                        var file = dialog.select_folder.end (res);
                        if (file != null) {
                            location_entry.text = file.get_path ();
                        }
                    } catch (Error e) {
                        debug ("Error during save backup: %s".printf (e.message));
                    }
                });
            }
        });

        create_button.clicked.connect (() => {
            clone_repo_async (location_entry.text, project_name_entry.text, aplication_id_entry.text, button_stack);
        });
    }

    public void clone_repo_async (string destination_folder, string project_name, string aplication_id, Gtk.Stack button_stack) {
        button_stack.visible_child_name = "spinner";
        string command = "git -C %s clone -b blank %s %s".printf (destination_folder, REPOSITORY_TEMPLATE_URL, project_name);

        Timeout.add (250, () => {
            try {
                string? stdout = null;
                string? stderr = null;
                int exit_status;
    
                Process.spawn_command_line_sync (command, out stdout, out stderr, out exit_status);
    
                if (exit_status == 0) {
                    set_project_values (destination_folder, project_name, aplication_id);
                } else {
                    print("Error al clonar el repositorio: %s\n", stderr);
                }
    
                button_stack.visible_child_name = "button";
            } catch (Error e) {
                print("Ocurrió un error: %s\n", e.message);
                button_stack.visible_child_name = "button";
            }
			return GLib.Source.REMOVE;
		});
    }

    private void set_project_values (string destination_folder, string project_name, string aplication_id) {
        string project_folder = destination_folder + "/" + project_name;

        string readme_file = project_folder + "/" + "README.md";
        string meson_file = project_folder + "/" + "meson.build";

        set_file_content (readme_file, "{{APPLICATION_ID}}", aplication_id);
        set_file_content (meson_file, "{{APPLICATION_ID}}", aplication_id);
        set_file_content (meson_file, "{{PROJECT_NAME}}", project_name);
    }

    private void set_file_content (string filename, string key, string value) {
        try {
            string content;
            FileUtils.get_contents (filename, out content);
    
            string new_content = content.replace (key, value);
    
            FileUtils.set_contents (filename, new_content, -1);    
        } catch (Error e) {
            print("Error al leer o modificar el archivo: %s\n", e.message);
        }
    }
}
