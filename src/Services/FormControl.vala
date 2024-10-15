public class FormControl : GLib.Object {
    public Gtk.Widget control { get; construct; }
    public Gee.ArrayList<Validator> validators = new Gee.ArrayList<Validator> ();

    public signal void value_changed (string new_value);

    public bool valid {
        get {
            string? value = get_value_from_control (control);
            if (value == null) {
                return false;
            }

            foreach (Validator validator in validators) {
                if (!validator.validate (value)) {
                    return false;
                }
            }

            return true;
        }
    }

    public FormControl (Gtk.Widget control) {
        Object (
            control: control
        );
    }

    construct {
        connect_value_change_signal ();
    }

    public void add_validator (Validator validator) {
        validators.add (validator);
    }

    private void connect_value_change_signal () {
        if (control is Gtk.Entry) {
            (control as Gtk.Entry).changed.connect (() => {
                string new_value = (control as Gtk.Entry).get_text ();
                value_changed (new_value);
            });
        }
    }

    private string? get_value_from_control (Gtk.Widget control) {
        if (control is Gtk.Entry) {
            return (control as Gtk.Entry).get_text ();
        }

        return null;
    }
}
