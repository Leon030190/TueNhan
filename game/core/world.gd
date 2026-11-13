class_name World
extends RefCounted



const NEWS_CAP: = 800

var world_seed: int = 0
var life: int = 1
var m: int = 0
var next_id: int = 1
var player_id: String = ""
var chars: Dictionary = {}
var cities: Dictionary = {}
var nations: Dictionary = {}
var relations: Dictionary = {}
var rel_base: Dictionary = {}
var pacts: Dictionary = {}
var wars: Array = []
var clan: Dictionary = {}
var news: Array = []
var counters: Dictionary = {}
var notebook: Dictionary = {}
var rivals: Dictionary = {}
var play: Dictionary = {}


func year() -> int:
	return floori(m / 12.0) + 1


func month() -> int:
	return m % 12 + 1


static func date_of(mm: int) -> String:
	return "tháng %d năm %d" % [mm % 12 + 1, floori(mm / 12.0) + 1]


static func date_cap(mm: int) -> String:
	return "Tháng %d năm %d" % [mm % 12 + 1, floori(mm / 12.0) + 1]


func new_id() -> String:
	var s: = "n%04d" % next_id
	next_id += 1
	return s


func ch(id: String) -> Character:
	return chars.get(id) as Character


func player() -> Character:
	return ch(player_id)


func living() -> Array:
	var a: Array = []
	for c: Character in chars.values():
		if c.alive:
			a.append(c)
	return a


func city_name(cid: String) -> String:
	return str(cities[cid]["name"]) if cities.has(cid) else cid


func nation_name(nid: String) -> String:
	return str(nations[nid]["name"]) if nations.has(nid) else "Tự do"



func has_feature(cid: String, f: String) -> bool:
	return cities.has(cid) and (cities[cid].get("features", []) as Array).has(f)



static func is_sea(a: String, b: String) -> bool:
	for pair in GameData.world_def().get("sea_links", []):
		if (str(pair[0]) == a and str(pair[1]) == b) or (str(pair[0]) == b and str(pair[1]) == a):
			return true
	return false


func city_nation(cid: String) -> String:
	return str(cities[cid]["nation"])


func nation_cities(nid: String) -> Array:
	var a: Array = []
	for cid in cities:
		if str(cities[cid]["nation"]) == nid:
			a.append(cid)
	return a



func travel_months(a: String, b: String) -> int:
	if a == b:
		return 0
	var dist: = {a: 0}
	var todo: Array = [a]
	while not todo.is_empty():
		var best: = 0
		for i in todo.size():
			if int(dist[todo[i]]) < int(dist[todo[best]]):
				best = i
		var cur: String = todo[best]
		todo.remove_at(best)
		var links: Dictionary = cities[cur]["links"]
		for nb in links:
			var d: = int(dist[cur]) + int(links[nb])
			if not dist.has(nb) or d < int(dist[nb]):
				dist[nb] = d
				todo.append(nb)
	return int(dist.get(b, -1))


static func rel_key(a: String, b: String) -> String:
	return a + "|" + b if a < b else b + "|" + a


func relation(a: String, b: String) -> float:
	return float(relations.get(rel_key(a, b), 0.0))


func add_rel(a: String, b: String, d: float) -> void :
	var k: = rel_key(a, b)
	relations[k] = clampf(float(relations.get(k, 0.0)) + d, -100.0, 100.0)



func add_news(text: String, ids: Array = [], kind: String = "") -> void :
	news.append({"m": m, "t": text, "ids": ids, "k": kind})
	if news.size() > NEWS_CAP:
		news.pop_front()


func count(k: String, n: int = 1) -> void :
	counters[k] = int(counters.get(k, 0)) + n



func rng(parts: Array) -> RandomNumberGenerator:
	return Rng.make([world_seed, life, m] + parts)



func fate_rng(parts: Array) -> RandomNumberGenerator:
	return Rng.make([world_seed] + parts)


func office_holder(nid: String, key: String) -> Character:
	var offices: Dictionary = nations[nid]["offices"]
	if not offices.has(key):
		return null
	var hid: String = offices[key]["holder"]
	return null if hid == "" else ch(hid)


func to_dict() -> Dictionary:
	var cd: = {}
	for id in chars:
		cd[id] = (chars[id] as Character).to_dict()
	return {
		"v": 1, "world_seed": world_seed, "life": life, "m": m, "next_id": next_id, "player_id": player_id, 
		"chars": cd, "cities": cities.duplicate(true), "nations": nations.duplicate(true), 
		"relations": relations.duplicate(true), "rel_base": rel_base.duplicate(true), "pacts": pacts.duplicate(true), 
		"wars": wars.duplicate(true), "clan": clan.duplicate(true), "news": news.duplicate(true), 
		"counters": counters.duplicate(true), "notebook": notebook.duplicate(true), "play": play.duplicate(true), 
		"rivals": rivals.duplicate(true), 
	}


static func from_dict(d: Dictionary) -> World:
	var w: = World.new()
	w.world_seed = int(d["world_seed"])
	w.life = int(d["life"])
	w.m = int(d["m"])
	w.next_id = int(d["next_id"])
	w.player_id = str(d["player_id"])
	for id in d["chars"]:
		w.chars[id] = Character.from_dict(d["chars"][id])
	w.cities = d["cities"]
	w.nations = d["nations"]
	w.relations = d["relations"]
	w.rel_base = d.get("rel_base", {})
	w.pacts = d.get("pacts", {})
	w.wars = d.get("wars", [])
	w.clan = d["clan"]
	w.news = d["news"]
	w.counters = d["counters"]
	w.notebook = d.get("notebook", {})
	for c: Character in w.chars.values():
		if not c.is_player and c.mi_pot <= 0.0:
			WorldGen.roll_mi(w, c, c.age(w.m))
	w.play = d.get("play", {})
	w.rivals = d.get("rivals", {})
	return w




func to_bytes() -> PackedByteArray:
	return var_to_bytes(to_dict())


static func from_bytes(b: PackedByteArray) -> World:
	return from_dict(bytes_to_var(b))


func save_file(path: String) -> Error:
	var f: = FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return FileAccess.get_open_error()
	f.store_buffer(to_bytes())
	return OK


static func load_file(path: String) -> World:
	if not FileAccess.file_exists(path):
		return null
	return from_bytes(FileAccess.get_file_as_bytes(path))




func to_json() -> String:
	return JSON.stringify(to_dict(), "", false, true)


static func from_json(s: String) -> World:
	return from_dict(JSON.parse_string(s))
