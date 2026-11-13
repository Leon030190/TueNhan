class_name ProfTree
extends RefCounted







const PATH: = "res://data/prof_tree.json"
const THRESH: = [0, 24, 72, 144]
const RANK_MULT: = [1.0, 1.1, 1.2, 1.2]
const MI: = 6
const MI_MULT: = 1.3
const MASTER_FAME: = 10.0
const HINT_TASK: = 40.0
const HINT_ADVICE: = 60.0

static var _data: Dictionary = {}


static func data() -> Dictionary:
	if _data.is_empty():
		var f: = FileAccess.open(PATH, FileAccess.READ)
		if f != null:
			_data = JSON.parse_string(f.get_as_text())
	return _data


static func has_tree(pid: String) -> bool:
	return data().has(pid)


static func rank(c: Character) -> int:
	return 1 + c.prof_path.size()


static func node(pid: String, id: String) -> Dictionary:
	if not has_tree(pid):
		return {}
	for r in ["r2", "r3", "r4"]:
		for n in data()[pid][r]:
			if str(n["id"]) == id:
				return n
	return {}



static func title(c: Character) -> String:
	if not c.prof_path.is_empty():
		var n: = node(c.profession, str(c.prof_path[-1]))
		if not n.is_empty():
			return str(n["name"])
	return Defs.prof_name(c.profession)



static func path_stats(c: Character) -> Array:
	var res: Array = []
	for id in c.prof_path:
		var n: = node(c.profession, str(id))
		if not n.is_empty() and not res.has(int(n["stat"])):
			res.append(int(n["stat"]))
	return res


static func mi_bonus(c: Character) -> bool:
	return c.prof_on and path_stats(c).has(MI)



static func growth_mult(c: Character, i: int) -> float:
	if not c.prof_on or c.prof_months < 0:
		return 1.0
	var pd: Dictionary = Defs.PROFESSIONS.get(c.profession, {})
	if not (pd.get("focus", []) as Array).has(i) and not path_stats(c).has(i):
		return 1.0
	return float(RANK_MULT[rank(c) - 1])



static func next_options(c: Character) -> Array:
	var r: = rank(c)
	if r >= 4 or not has_tree(c.profession):
		return []
	var lst: Array = data()[c.profession]["r%d" % (r + 1)]
	if r == 1:
		return lst
	var last: = str(c.prof_path[-1])
	return lst.filter( func(n: Dictionary) -> bool: return (n["from"] as Array).has(last))


static func months_to_next(c: Character) -> int:
	var r: = rank(c)
	if r >= 4 or not has_tree(c.profession):
		return -1
	return maxi(0, int(THRESH[r]) - maxi(0, c.prof_months))


static func _stat_score(c: Character, s: int) -> float:
	if s == MI:
		return c.mi_real + c.mi_pot
	return float(c.real[s]) + float(c.pot[s])



static func branch_score(c: Character, n: Dictionary) -> float:
	var s: = int(n["stat"])
	var v: = _stat_score(c, s)
	if (s == 0 or s == 2) and c.has_trait("dung_cam"):
		v += 10.0
	if s == 3 and c.has_trait("tham_vong"):
		v += 8.0
	if s == MI and c.has_trait("kieu_ngao"):
		v -= 8.0
	if c.task_stats.has(s):
		v += HINT_TASK
	if c.prof_hint == str(n["id"]):
		v += HINT_ADVICE
	return v


static func pick(c: Character, opts: Array) -> Dictionary:
	var best: Dictionary = {}
	var bv: = -1.0
	for n: Dictionary in opts:
		var v: = branch_score(c, n)
		if v > bv:
			bv = v
			best = n
	return best



static func tick(c: Character, m: int) -> void :
	if not has_tree(c.profession):
		return
	if c.prof_months < 0:
		_init_quiet(c, m)
		return
	if not c.prof_on:
		return
	c.prof_months += 1
	if rank(c) < 4 and c.prof_months >= int(THRESH[rank(c)]):
		_promote(c, m, false)



static func _init_quiet(c: Character, m: int) -> void :
	c.prof_months = int(maxf(0.0, float(c.age(m) - 16)) * 12.0 * 0.45)
	while rank(c) < 4 and c.prof_months >= int(THRESH[rank(c)]):
		_promote(c, m, true)



static func ensure(w: World) -> void :
	for c: Character in w.living():
		if c.prof_months < 0 and has_tree(c.profession):
			_init_quiet(c, w.m)


static func _promote(c: Character, m: int, quiet: bool) -> void :
	var n: = pick(c, next_options(c))
	if n.is_empty():
		return
	c.prof_path.append(str(n["id"]))
	c.prof_hint = ""
	if not c.clan_retainer:
		c.set_profession(c.profession)
	if quiet:
		return
	if rank(c) == 4:
		c.fame = minf(100.0, c.fame + MASTER_FAME)
		c.add_log(m, "Thành bậc thầy: %s (nghề %s)" % [n["name"], Defs.prof_name(c.profession).to_lower()])
	else:
		c.add_log(m, "Lên bậc nghề: %s" % n["name"])


static func stat_name(s: int) -> String:
	return "Mị lực" if s == MI else Defs.STAT_NAMES[s]
