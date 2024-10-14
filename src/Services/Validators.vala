public class Validator : GLib.Object {
	public virtual bool validate (string value) {
		return false;
	}
}

public class Validators.Required : Validator {
	public override bool validate (string value) {
		return value.strip ().length > 0;
	}
}

public class Validators.Regex : Validator {
	public GLib.Regex regex;

	public Regex (string regex_arg) {
		try {
			regex = new GLib.Regex (regex_arg);
		} catch (Error e) {
			critical (e.message);
		}
	}

	public override bool validate (string value) {
		if (regex == null) {
			return true;
		}

		return regex.match (value);
	}
}
