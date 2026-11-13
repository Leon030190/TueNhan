class_name Crisis
extends RefCounted




const PATHS: = ["phuc_hoi", "chuyen_huong", "truyen_thu", "binh_thuong", "sa_nga"]
const PATH_NAMES: = {
	"phuc_hoi": "Phục hồi con đường cũ", 
	"chuyen_huong": "Chuyển hướng", 
	"truyen_thu": "Truyền thụ", 
	"binh_thuong": "Bình thường hóa", 
	"sa_nga": "Sa ngã", 
}


static func start(w: World, c: Character, lost: Array, r: RandomNumberGenerator, cause: String) -> void :
	var months: = clampi(12 - int(c.y_chi / 10.0) + r.randi_range(-1, 2), 3, 12)
	c.crisis = {"m_left": months, "lost": lost.duplicate(), "bonus": {}, "cause": cause, "start": w.m}
	c.mood = "suy_sup"
	c.mood_m = 0
	c.add_log(w.m, "Rơi vào khủng hoảng sau biến cố (%s), dự kiến %d tháng" % [cause, months])
	w.count("crisis_start")


static func _argmax(a: Array) -> int:
	var b: = 0
	for i in a.size():
		if float(a[i]) > float(a[b]):
			b = i
	return b


static func weights(w: World, c: Character) -> Dictionary:
	var lost: Array = c.crisis.get("lost", [0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
	var main: = _argmax(lost)
	var age: = c.age(w.m)
	var supported: = c.nation_id != "" or c.clan_retainer or c.mentor_m > 0 or c.env != ""
	var env_help: = false
	var e: Dictionary = Defs.ENVS.get(c.env, Defs.ENVS[""])
	for s in e["stats"]:
		if int(s) != main and float(Defs.AFFINITY[main][int(s)]) >= 0.3:
			env_help = true
	var permanent: = false
	for inj in c.injuries:
		if int(inj["months"]) < 0:
			permanent = true
	var wt: = {
		"phuc_hoi": 20.0 + (c.y_chi - 50.0) * 0.4 - (8.0 if permanent else 0.0), 
		"chuyen_huong": 20.0 + (c.ngo - 3) * 8.0 + (15.0 if env_help else 0.0) + (10.0 if c.mentor_m > 0 else 0.0), 
		"truyen_thu": 10.0 + (15.0 if age >= 40 else 0.0) + (10.0 if float(c.real[main]) >= 60.0 else 0.0), 
		"binh_thuong": 25.0 + (50.0 - c.y_chi) * 0.3 + (50.0 - c.tham_vong) * 0.2, 
		"sa_nga": 15.0 + maxf(0.0, 40.0 - c.y_chi) * 0.5 + (0.0 if supported else 10.0), 
	}
	var bonus: Dictionary = c.crisis.get("bonus", {})
	for k in bonus:
		wt[k] = float(wt[k]) + float(bonus[k])
	for k in wt:
		wt[k] = maxf(1.0, float(wt[k]))
	return wt


static func probabilities(w: World, c: Character) -> Dictionary:
	var wt: = weights(w, c)
	var total: = 0.0
	for k in wt:
		total += float(wt[k])
	var p: = {}
	for k in PATHS:
		p[k] = float(wt[k]) / total
	return p


static func tick(w: World) -> void :
	for c: Character in w.living():
		if c.crisis.is_empty():
			continue
		var left: = int(c.crisis["m_left"]) - 1
		c.crisis["m_left"] = left
		if left <= 0:
			resolve(w, c, w.rng(["crisis", c.id]))


static func resolve(w: World, c: Character, r: RandomNumberGenerator) -> void :
	var wt: = weights(w, c)
	var ws: Array = []
	for p in PATHS:
		ws.append(wt[p])
	var path: String = PATHS[Rng.pick_weighted(r, ws)]
	var lost: Array = c.crisis["lost"]
	c.crisis = {}
	w.count("crisis:" + path)
	apply_path(w, c, path, lost, r)




static func convert_potential(c: Character, lost: Array) -> Array:
	var rate: = 0.3 + 0.1 * (c.ngo - 1)
	var gains: Array = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	for s in Defs.N_STATS:
		var amount: = float(lost[s])
		if amount <= 0.0:
			continue
		for t in Defs.N_STATS:
			if t == s or float(lost[t]) > 0.0:
				continue
			gains[t] = float(gains[t]) + amount * float(Defs.AFFINITY[s][t]) * rate
	var cap: = c.pot_cap()
	for t in Defs.N_STATS:
		if float(gains[t]) > 0.0:
			var cur: float = c.pot[t]
			var nv: = maxf(cur, minf(cap, cur + float(gains[t])))
			gains[t] = nv - cur
			c.pot[t] = nv
	return gains


static func apply_path(w: World, c: Character, path: String, lost: Array, r: RandomNumberGenerator) -> void :
	var main: = _argmax(lost)
	match path:
		"phuc_hoi":
			var frac: = 0.25 + maxf(0.0, c.y_chi - 50.0) / 50.0 * 0.15
			for i in Defs.N_STATS:
				if float(lost[i]) > 0.0:
					c.pot[i] = float(c.pot[i]) + float(lost[i]) * frac
			c.set_mood("binh_thuong", 0)
			c.add_log(w.m, "Kiên trì phục hồi con đường cũ: lấy lại %d%% tiềm năng đã mất" % roundi(frac * 100.0))
		"chuyen_huong":
			var gains: = convert_potential(c, lost)
			var parts: Array = []
			for i in Defs.N_STATS:
				if float(gains[i]) >= 0.5:
					parts.append("%s +%.0f" % [Defs.STAT_NAMES[i], float(gains[i])])
			c.add_log(w.m, "Chuyển hướng phát triển. Tiềm năng: " + ", ".join(parts))
			if r.randf() < 0.1 + 0.05 * (c.ngo - 1):
				_awaken(w, c, main, gains, r)
			var order: Array = [0, 1, 2, 3, 4, 5]
			order.sort_custom( func(a: int, b: int) -> bool: return float(gains[a]) > float(gains[b]))
			var f: Array = [int(order[0])]
			if float(gains[order[1]]) > 0.0:
				f.append(int(order[1]))
			if c.office_key == "":
				c.set_profession(_path_profession(int(order[0])))
			c.focus = f
			c.set_mood("phan_chan", 6)
			if c.fame >= 20.0 or c.special != "":
				w.add_news("%s vượt qua nghịch cảnh, chuyển sang con đường %s." % [c.name, Defs.STAT_NAMES[int(order[0])]], [c.id], "bien_co")
		"truyen_thu":
			if c.office_key == "":
				c.set_profession("vo_su" if main == Defs.VO else "thay_day")
			c.fame = minf(100.0, c.fame + 5.0)
			c.set_mood("binh_thuong", 0)
			c.add_log(w.m, "Chọn con đường truyền thụ cho thế hệ sau")
		"binh_thuong":
			if c.office_key == "":
				c.set_profession("dan_thuong")
			c.tham_vong = maxf(0.0, c.tham_vong - 20.0)
			c.set_mood("binh_thuong", 0)
			c.add_log(w.m, "Từ bỏ con đường cũ, sống cuộc đời bình thường")
		"sa_nga":
			c.set_mood("suy_sup", r.randi_range(12, 24))
			var x: = r.randf()
			if x < 0.05:
				Life.die(w, c, "u uất")
			elif x < 0.35:
				if c.office_key != "":
					Appointment.vacate(w, c, "bỏ đi biệt tích")
				c.nation_id = ""
				c.faction_id = ""
				var cids: Array = w.cities.keys()
				c.city_id = str(Rng.pick(r, cids))
				c.concealment = minf(100.0, c.concealment + 30.0)
				c.fame = 0.0
				c.set_profession("an_si")
				c.add_log(w.m, "Sa ngã, mai danh ẩn tích ở %s" % w.city_name(c.city_id))
				w.add_news("%s bỏ đi biệt tích, không ai biết tung tích." % c.name, [c.id], "an")
			else:
				c.add_log(w.m, "Sa ngã, chìm trong u uất")


static func _path_profession(stat: int) -> String:
	match stat:
		Defs.TRI, Defs.QUAN:
			return "muu_si"
		Defs.CHINH:
			return "thu_sinh"
		Defs.SX:
			return "tho_thu_cong"
		Defs.THUONG:
			return "thuong_nhan"
	return "vo_sinh"


static func _awaken(w: World, c: Character, main: int, gains: Array, r: RandomNumberGenerator) -> void :
	if main == Defs.VO and c.has_talent("kiem_dao"):
		Talents.replace(w, c, "kiem_dao", "kiem_tam", "kiếm đạo gãy đổ, tâm kiếm bừng sáng")
		return
	if main == Defs.THUONG and c.has_talent("tai_chinh"):
		Talents.replace(w, c, "tai_chinh", "kinh_the", "từ thương trường bước sang kinh bang tế thế")
		return
	var best: = _argmax(gains)
	var key: String = Defs.STAT_KEYS[best]
	var cands: Array = []
	for tid in GameData.talents():
		var d: Dictionary = GameData.talent(tid)
		if not d.get("spawn", true) or c.has_talent(tid) or int(d["rarity"]) > 1 or d.get("negative", false):
			continue
		var pb: Dictionary = d.get("pot", {})
		var gb: Dictionary = d.get("growth", {})
		if pb.has(key) or gb.has(key) or gb.has("all"):
			cands.append(tid)
	if cands.is_empty():
		return
	var t: String = Rng.pick(r, cands)
	Talents.add(c, t)
	c.add_log(w.m, "Thức tỉnh thiên phú %s" % GameData.talent_name(t))
	w.count("talent_awaken")
