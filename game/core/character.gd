class_name Character
extends RefCounted



var id: String = ""
var name: String = ""
var female: bool = false
var birth_m: int = 0
var city_id: String = ""
var profession: String = "dan_thuong"
var real: Array = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
var pot: Array = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
var ngo: int = 3
var talents: Array = []
var traits: Array = []
var y_chi: float = 50.0
var tham_vong: float = 50.0
var health: float = 100.0
var lifespan_m: int = 780
var injuries: Array = []
var mood: String = "binh_thuong"
var mood_m: int = 0
var loyalty: float = 50.0
var fame: float = 0.0
var concealment: float = 0.0
var disguise_mul: Array = []
var disguise_add: Array = []
var focus: Array = []
var env: String = ""
var mentor_m: int = 0
var mentor_stat: int = -1
var mentor_mult: float = 1.6
var nation_id: String = ""
var faction_id: String = ""
var patron: String = ""
var clan_retainer: bool = false
var office_key: String = ""
var office_months: int = 0
var crisis: Dictionary = {}
var fate: Array = []
var merit_m: float = 0.0
var merit_y: float = 0.0
var merit_total: float = 0.0
var recommender: String = ""
var favor: float = 0.0
var battles: int = 0
var history: Array = []
var alive: bool = true
var death_m: int = -1
var death_cause: String = ""
var is_player: bool = false
var mi_real: float = 0.0
var mi_pot: float = 0.0
var destiny: String = ""
var env_bonus: float = 1.0
var portrait: String = ""
var gear: Dictionary = {}
var purse: float = 0.0
var purse_last: Dictionary = {}
var skim: float = 0.0
var skimmed: float = 0.0
var prof_months: int = -1
var prof_path: Array = []
var prof_hint: String = ""
var prof_on: bool = true
var task_stats: Array = []
var idle_until: int = -1
var shame_until: int = -1
var hates_player: bool = false
var career_try: Dictionary = {}
var special: String = ""


func age(m: int) -> int:
	return floori((m - birth_m) / 12.0)


func age_months(m: int) -> int:
	return m - birth_m


func has_talent(t: String) -> bool:
	return talents.has(t)


func has_trait(t: String) -> bool:
	return traits.has(t)


func in_focus(i: int) -> bool:
	for f in focus:
		if int(f) == i:
			return true
	return false


func top_pot() -> int:
	var b: = 0
	for i in Defs.N_STATS:
		if float(pot[i]) > float(pot[b]):
			b = i
	return b


func top_real() -> int:
	var b: = 0
	for i in Defs.N_STATS:
		if float(real[i]) > float(real[b]):
			b = i
	return b


func max_pot() -> float:
	return float(pot[top_pot()])


func max_real() -> float:
	return float(real[top_real()])


func pot_cap() -> float:
	return Defs.POT_HARD_CAP if has_talent("thien_menh") else Defs.POT_CAP


func max_health() -> float:
	return 100.0


func has_disguise() -> bool:
	return not disguise_mul.is_empty()


func shown_real(i: int) -> float:
	if not has_disguise():
		return float(real[i])
	return clampf(float(real[i]) * float(disguise_mul[i]) + float(disguise_add[i]), 0.0, 99.0)


func shown_pot(i: int) -> float:
	if not has_disguise():
		return float(pot[i])
	return clampf(float(pot[i]) * float(disguise_mul[i]) + float(disguise_add[i]), 0.0, 99.0)



func role_score(role: String, vals: Array = []) -> float:
	var v: Array = real if vals.is_empty() else vals
	var wts: Array = Defs.ROLES[role]["w"]
	var s: = 0.0
	for i in Defs.N_STATS:
		s += float(v[i]) * float(wts[i])
	var rd: Dictionary = Defs.ROLES[role]
	if rd.has("mi"):
		s += (float(v[Defs.N_STATS]) if v.size() > Defs.N_STATS else mi_real) * float(rd["mi"])
	return s



func office_score(office_id: String) -> float:
	var best: = 0.0
	for role in Defs.OFFICES[office_id]["roles"]:
		best = maxf(best, role_score(role) + Talents.role_bonus(self, role))
	return best


func best_role() -> String:
	var best: = ""
	var bs: = -1.0
	for role in Defs.ROLE_ORDER:
		var s: = role_score(role) + Talents.role_bonus(self, role)
		if s > bs:
			bs = s
			best = role
	return best


func set_mood(m: String, months: int) -> void :
	mood = m
	mood_m = months


func set_profession(pid: String) -> void :
	var pd: Dictionary = Defs.PROFESSIONS.get(pid, Defs.PROFESSIONS["dan_thuong"])
	if pid != profession:
		prof_path = []
		prof_hint = ""
		if prof_months >= 0:
			prof_months = 0
	profession = pid
	var f: Array = []
	for x in pd["focus"]:
		f.append(int(x))
	for s in ProfTree.path_stats(self):
		if int(s) < Defs.N_STATS and not f.has(int(s)):
			f.append(int(s))
	focus = f
	if office_key == "":
		env = str(pd["env"])


func add_log(m: int, text: String) -> void :
	history.append({"m": m, "t": text})
	if history.size() > 80:
		history.pop_front()


func to_dict() -> Dictionary:
	return Serial.to_dict(self)


static func from_dict(d: Dictionary) -> Character:
	var c: = Character.new()
	Serial.from_dict(c, d)
	var f: Array = []
	for x in c.focus:
		f.append(int(x))
	c.focus = f
	return c
