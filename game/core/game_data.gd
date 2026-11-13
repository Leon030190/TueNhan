class_name GameData
extends RefCounted



static var _cache: Dictionary = {}


static func table(name: String) -> Variant:
	if not _cache.has(name):
		var path: = "res://data/%s.json" % name
		var txt: = FileAccess.get_file_as_string(path)
		if txt == "":
			push_error("Không đọc được " + path)
			_cache[name] = {}
		else:
			_cache[name] = JSON.parse_string(txt)
	return _cache[name]


static func _by_id(name: String) -> Dictionary:
	var k: = "_id_" + name
	if not _cache.has(k):
		var d: = {}
		for e in table(name):
			d[str(e["id"])] = e
		_cache[k] = d
	return _cache[k]


static func world_def() -> Dictionary:
	return table("world")


static func names() -> Dictionary:
	return table("names")


static func talents() -> Dictionary:
	return _by_id("talents")


static func talent(id: String) -> Dictionary:
	return talents().get(id, {})


static func talent_name(id: String) -> String:
	return str(talent(id).get("name", id))


static func traits() -> Dictionary:
	return _by_id("traits")


static func trait_def(id: String) -> Dictionary:
	return traits().get(id, {})


static func trait_name(id: String) -> String:
	return str(trait_def(id).get("name", id))


static func events() -> Dictionary:
	return _by_id("events")


static func event_def(id: String) -> Dictionary:
	return events().get(id, {})


static func event_name(id: String) -> String:
	return str(event_def(id).get("name", id))
