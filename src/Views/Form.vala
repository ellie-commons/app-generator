/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2024 Alain <alainmh23@gmail.com>
*/

public class Views.Form : Adw.Bin {
    private Granite.ValidatedEntry project_name_entry;
    private Granite.ValidatedEntry identifier_entry;
    private Gtk.Entry application_id_entry;
    private Gtk.Entry location_entry;
    private Granite.Toast toast;

    public signal void back ();
    public signal void created (string project_name, string location);

    public string developer_name { get; set; }
    public string developer_email { get; set; }

    construct {
        Regex? project_name_regex = null;
        Regex? identifier_regex = null;
        try {
            project_name_regex = new Regex ("^[a-z]+[a-z0-9]*$");
            identifier_regex = new Regex ("^[a-z]+\\.[a-z0-9]+(\\.[a-z0-9]+)*$");
        } catch (Error e) {
            critical (e.message);
        }

        project_name_entry = new Granite.ValidatedEntry () {
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

        identifier_entry = new Granite.ValidatedEntry () {
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

        application_id_entry = new Gtk.Entry () {
            margin_top = 6,
            editable = false
        };

        location_entry = new Gtk.Entry () {
            margin_top = 6,
            secondary_icon_name = "folder-symbolic",
            text = GLib.Environment.get_user_special_dir (GLib.UserDirectory.TEMPLATES)
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

        var back_button = new Gtk.Button () {
            child = new Gtk.Image.from_icon_name ("go-previous-symbolic")
        };

        var create_button = new Gtk.Button () {
            child = button_stack,
            hexpand = true,
            sensitive = false
        };
        create_button.add_css_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);

        var buttons_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
            vexpand = true,
            valign = END,
            margin_bottom = 32,
        };
        buttons_box.append (back_button);
        buttons_box.append (create_button);

        var form_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        form_box.append (new Gtk.Label (_("Application")) {
            halign = START,
            css_classes = { Granite.STYLE_CLASS_H1_LABEL }
        });
        form_box.append (new Granite.HeaderLabel (_("Project Name:")));
        form_box.append (project_name_entry);
        //  form_box.append (project_name_description);
        form_box.append (new Granite.HeaderLabel (_("Organization Identifier:")));
        form_box.append (identifier_entry);
        //  form_box.append (identifier_description);
        form_box.append (new Granite.HeaderLabel (_("Application ID:")));
        form_box.append (application_id_entry);
        form_box.append (new Granite.HeaderLabel (_("Location:")));
        form_box.append (location_entry);
        form_box.append (buttons_box);

        var content_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
            margin_start = 24,
            margin_end = 24,
            hexpand = true
        };

        content_box.append (form_box);

        toast = new Granite.Toast ("");

        var overlay = new Gtk.Overlay () {
            child = content_box
        };
        overlay.add_overlay (toast);
        overlay.set_measure_overlay (toast, true);

        child = overlay;

        project_name_entry.changed.connect (() => {
            application_id_entry.text = identifier_entry.text + "." + project_name_entry.text;
            create_button.sensitive = project_name_entry.is_valid && identifier_entry.is_valid && location_entry.text.length > 0;
        });

        identifier_entry.changed.connect (() => {
            application_id_entry.text = identifier_entry.text + "." + project_name_entry.text;
            create_button.sensitive = project_name_entry.is_valid && identifier_entry.is_valid && location_entry.text.length > 0;
        });

        location_entry.changed.connect (() => {
            create_button.sensitive = project_name_entry.is_valid && identifier_entry.is_valid && location_entry.text.length > 0;
        });

        location_entry.icon_release.connect ((icon_pos) => {
            if (icon_pos == Gtk.EntryIconPosition.SECONDARY) {
                var dialog = new Gtk.FileDialog ();
                dialog.select_folder.begin (AppGenerator.instance.main_window, null, (obj, res) => {
                    try {
                        var file = dialog.select_folder.end (res);
                        if (file != null) {
                            location_entry.text = file.get_path ();
                        }
                    } catch (Error e) {
                        debug ("Error during save backup: %s".printf (e.message));
                        toast.title = e.message;
                        toast.send_notification ();
                    }
                });
            }
        });

        back_button.clicked.connect (() => {
            back ();
        });

        create_button.clicked.connect (() => {
            clone_repo_async (location_entry.text, project_name_entry.text, application_id_entry.text, button_stack);
        });
    }

    public void clone_repo_async (string destination_folder, string project_name, string application_id, Gtk.Stack button_stack) {
        button_stack.visible_child_name = "spinner";
        string[] command = { "git", "-C", destination_folder, "clone", "-b", "blank", REPOSITORY_TEMPLATE_URL, project_name };
        GLib.Subprocess process = new GLib.Subprocess.newv (command, SubprocessFlags.STDOUT_PIPE | SubprocessFlags.STDERR_PIPE);

        process.wait_check_async.begin (null, (obj, res) => {
            try {
                process.wait_check_async.end (res);
                set_project_values (destination_folder, project_name, application_id);
            } catch (Error e) {
                string stdout_buf;
                string stderr_buf;
                process.communicate_utf8 (null, null, out stdout_buf, out stderr_buf);
                button_stack.visible_child_name = "button";
                toast.title = stderr_buf;
                toast.send_notification ();
            }
        });
    }

    private void set_project_values (string destination_folder, string project_name, string application_id) {
        string project_folder = GLib.Path.build_filename (destination_folder, project_name);
        string application_id_schema = application_id.replace (".", "/");

        // Readme File
        string readme_file = GLib.Path.build_filename (project_folder, "README.md");
        set_file_content (readme_file, "{{APPLICATION_ID}}", application_id);

        // Meson File
        string meson_file = GLib.Path.build_filename (project_folder, "meson.build");
        set_file_content (meson_file, "{{APPLICATION_ID}}", application_id);
        set_file_content (meson_file, "{{PROJECT_NAME}}", project_name);

        // Flatpak File
        string flatpak_file = GLib.Path.build_filename (project_folder, "{{APPLICATION_ID}}.yml");
        string new_flatpak_file = GLib.Path.build_filename (project_folder, application_id + ".yml");
        rename_file (flatpak_file, new_flatpak_file);
        set_file_content (new_flatpak_file, "{{APPLICATION_ID}}", application_id);
        set_file_content (new_flatpak_file, "{{PROJECT_NAME}}", project_name);

        // AppData Files
        string appdata_file = GLib.Path.build_filename (project_folder, "data", "{{PROJECT_NAME}}.appdata.xml.in");
        string new_appdata_file = GLib.Path.build_filename (project_folder, "data", project_name + ".appdata.xml.in");
        rename_file (appdata_file, new_appdata_file);
        set_file_content (new_appdata_file, "{{APPLICATION_ID}}", application_id);
        set_file_content (new_appdata_file, "{{PROJECT_NAME}}", project_name);
        set_file_content (new_appdata_file, "{{DEVELOPER_NAME}}", developer_name);
        set_file_content (new_appdata_file, "{{DEVELOPER_EMAIL}}", developer_email);

        // Desltop Files
        string desktop_file = GLib.Path.build_filename (project_folder, "data", "{{PROJECT_NAME}}.desktop.in");
        string new_desktop_file = GLib.Path.build_filename (project_folder, "data", project_name + ".desktop.in");
        rename_file (desktop_file, new_desktop_file);
        set_file_content (new_desktop_file, "{{APPLICATION_ID}}", application_id);
        set_file_content (new_desktop_file, "{{PROJECT_NAME}}", project_name);

        // Gresource Files
        string gresource_file = GLib.Path.build_filename (project_folder, "data", "{{PROJECT_NAME}}.gresource.xml");
        string new_gresource_file = GLib.Path.build_filename (project_folder, "data", project_name + ".gresource.xml");
        rename_file (gresource_file, new_gresource_file);
        set_file_content (new_gresource_file, "{{APPLICATION_ID_GSCHEMA}}", application_id_schema);

        // Gschema Files
        string gschema_file = GLib.Path.build_filename (project_folder, "data", "{{PROJECT_NAME}}.gschema.xml");
        string new_gschema_file = GLib.Path.build_filename (project_folder, "data", project_name + ".gschema.xml");
        rename_file (gschema_file, new_gschema_file);
        set_file_content (new_gschema_file, "{{APPLICATION_ID_GSCHEMA}}", application_id_schema);
        set_file_content (new_gschema_file, "{{APPLICATION_ID}}", application_id);

        // data meson
        string data_meson_file = GLib.Path.build_filename (project_folder, "data", "meson.build");
        set_file_content (data_meson_file, "{{PROJECT_NAME}}", project_name);

        // src app
        string src_application_file = GLib.Path.build_filename (project_folder, "src", "Application.vala");
        set_file_content (src_application_file, "{{APPLICATION_ID_GSCHEMA}}", application_id_schema);
        set_file_content (src_application_file, "{{APPLICATION_ID}}", application_id);
        set_file_content (new_appdata_file, "{{DEVELOPER_NAME}}", developer_name);
        set_file_content (new_appdata_file, "{{DEVELOPER_EMAIL}}", developer_email);

        // src window
        string src_window_file = GLib.Path.build_filename (project_folder, "src", "MainWindow.vala");
        set_file_content (src_window_file, "{{APPLICATION_ID_GSCHEMA}}", application_id_schema);
        set_file_content (src_window_file, "{{APPLICATION_ID}}", application_id);
        set_file_content (new_appdata_file, "{{DEVELOPER_NAME}}", developer_name);
        set_file_content (new_appdata_file, "{{DEVELOPER_EMAIL}}", developer_email);

        created (project_name_entry.text, location_entry.text);
    }

    public void reset_form () {
        project_name_entry.text = "";
        identifier_entry.text = "";
        application_id_entry.text = "";
    }

    private void set_file_content (string filename, string key, string value) {
        try {
            string content;
            FileUtils.get_contents (filename, out content);

            string new_content = content.replace (key, value);

            FileUtils.set_contents (filename, new_content, -1);
        } catch (Error e) {
            debug (e.message);
        }
    }

    void rename_file (string old_name, string new_name) {
        try {
            GLib.File old_file = GLib.File.new_for_path (old_name);
            GLib.File new_file = GLib.File.new_for_path (new_name);
            old_file.move (new_file, GLib.FileCopyFlags.NONE);
        } catch (GLib.Error e) {
            debug (e.message);
        }
    }
}