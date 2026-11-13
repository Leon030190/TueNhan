class_name Serial
extends RefCounted




static func to_dict(o: Object) -> Dictionary:
	var d: = {}
	for p in o.get_property_list():
		if int(p["usage"]) & PROPERTY_USAGE_SCRIPT_VARIABLE:
			var v: Variant = o.get(p["name"])
			if v is Array or v is Dictionary:
				v = v.duplicate(true)
			d[p["name"]] = v
	return d


static func from_dict(o: Object, d: Dictionary) -> void :
	for p in o.get_property_list():
		if not (int(p["usage"]) & PROPERTY_USAGE_SCRIPT_VARIABLE):
			continue
		var n: String = p["name"]
		if not d.has(n):
			continue
		var v: Variant = d[n]
		match int(p["type"]):
			TYPE_INT:
				o.set(n, int(v))
			TYPE_FLOAT:
				o.set(n, float(v))
			TYPE_BOOL:
				o.set(n, bool(v))
			TYPE_STRING:
				o.set(n, str(v))
			_:
				o.set(n, v)
