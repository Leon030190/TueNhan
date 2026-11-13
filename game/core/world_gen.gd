class_name WorldGen
extends RefCounted



const STAT_PROFS: = [
	["binh_si", "vo_sinh", "kiem_khach", "tho_ren"], 
	["thu_sinh", "thay_thuoc"], 
	["binh_si", "vo_sinh"], 
	["lai_vien", "thu_sinh"], 
	["nong_dan", "tho_thu_cong", "tho_ren"], 
	["tieu_thuong", "thuong_nhan"], 
]
const CITY_STAT: = ["quan_su", "giao_duc", "quan_su", "giao_duc", "sx", "kinh_te"]


static func generate(world_seed: int, destiny_idx: int = 0, life: int = 1, n_destiny: int = 3, reroll: int = 0) -> World:
	var w: = World.new()
	w.world_seed = world_seed
	w.life = life
	var def: Dictionary = GameData.world_def()
	for cd in def["cities"]:
		var city: Dictionary = (cd as Dictionary).duplicate(true)
		city["phon_vinh"] = (float(city["kinh_te"]) + float(city["sx"]) + float(city["an_ninh"])) / 3.0
		city["base"] = {"kinh_te": float(city["kinh_te"]), "sx": float(city["sx"]), "an_ninh": float(city["an_ninh"])}
		w.cities[city["id"]] = city
	for nd in def["nations"]:
		var nat: Dictionary = (nd as Dictionary).duplicate(true)
		nat["offices"] = _make_offices(w, nat)
		nat["last_income"] = 0.0
		nat["last_food"] = 0.0
		nat["shortage"] = false
		w.nations[nat["id"]] = nat
	for rel in def["relations"]:
		var rk: = World.rel_key(rel[0], rel[1])
		w.relations[rk] = float(rel[2])
		w.rel_base[rk] = float(rel[3]) if (rel as Array).size() > 3 else 0.0
	for sd in def.get("special_npcs", []):
		_make_special(w, sd)
	for nid in w.nations:
		var offices: Dictionary = w.nations[nid]["offices"]
		for key in offices:
			var c: = new_official(w, nid, key)
			Appointment.appoint(w, nid, key, c, true)
	for cid in w.cities:
		for k in int(w.cities[cid]["npc"]):
			var age: = 14 + int(pow(Rng.make([world_seed, "age", cid, k]).randf(), 1.4) * 34.0)
			new_commoner(w, cid, age)
	_pick_tuc_tue(w)
	_make_player(w, destiny_idx, n_destiny, reroll)
	PlayerOps.init_play(w)
	Rivals.generate(w)
	return w



static func _pick_tuc_tue(w: World) -> void :
	var cands: Array = []
	for c: Character in w.chars.values():
		if c.max_pot() >= 70.0 and c.special == "":
			cands.append(c)
	var r: = Rng.make([w.world_seed, "tuctue_pick"])
	for k in 3:
		if cands.is_empty():
			return
		var i: = r.randi_range(0, cands.size() - 1)
		Talents.add(cands[i], "tuc_tue", false)
		cands.remove_at(i)


static func _make_offices(w: World, nat: Dictionary) -> Dictionary:
	var offices: = {}
	for oid in Defs.OFFICE_ORDER:
		var od: Dictionary = Defs.OFFICES[oid]
		if bool(od.get("per_city", false)):
			for cid in w.nation_cities(nat["id"]):
				offices[oid + "#" + cid] = {"office": oid, "city": cid, "holder": ""}
		else:
			for k in int(od["count"]):
				offices["%s#%d" % [oid, k]] = {"office": oid, "city": nat["capital"], "holder": ""}
	return offices




static func _base(w: World, city_id: String, age: int) -> Character:
	var c: = Character.new()
	c.id = w.new_id()
	c.city_id = city_id
	var r: = Rng.make([w.world_seed, "gen", c.id])
	c.female = r.randf() < 0.35
	c.name = _name(w, r, w.city_nation(city_id), c.female)
	c.birth_m = w.m - age * 12 - r.randi_range(0, 11)
	c.ngo = Rng.pick_weighted(r, Defs.NGO_WEIGHTS)
	w.chars[c.id] = c
	return c


static func new_commoner(w: World, city_id: String, age: int) -> Character:
	var c: = _base(w, city_id, age)
	var r: = Rng.make([w.world_seed, "gen2", c.id])
	_roll_potential(w, c, r)
	_roll_traits(c, r)
	_roll_talents(c, r)
	_roll_profession(w, c, r)
	_roll_real(c, r, age)
	roll_mi(w, c, age)
	c.fame = clampf((c.max_real() - 30.0) * 0.6 + r.randf_range(-5.0, 10.0), 0.0, 50.0)
	if c.has_trait("an_dat"):
		c.fame = 0.0
	_roll_hidden(c, r, 0.03, 0.03)
	_roll_fate(w, c)
	return c


static func new_official(w: World, nid: String, key: String) -> Character:
	var nat: Dictionary = w.nations[nid]
	var slot: Dictionary = nat["offices"][key]
	var oid: String = slot["office"]
	var age: = Rng.make([w.world_seed, "off_age", nid, key]).randi_range(30, 62)
	var c: = _base(w, str(slot["city"]), age)
	var r: = Rng.make([w.world_seed, "gen2", c.id])
	_roll_potential(w, c, r)
	var main: = Appointment.office_focus(oid)
	c.pot[main[0]] = maxf(float(c.pot[main[0]]), r.randf_range(48.0, 88.0))
	c.pot[main[1]] = maxf(float(c.pot[main[1]]), r.randf_range(40.0, 75.0))
	_roll_traits(c, r)
	_roll_talents(c, r)
	for i in Defs.N_STATS:
		var is_main: = i == int(main[0]) or i == int(main[1])
		var frac: = r.randf_range(0.75, 0.97) if is_main else r.randf_range(0.35, 0.65)
		c.real[i] = maxf(3.0, float(c.pot[i]) * frac)
	roll_mi(w, c, age)
	if Defs.ROLES[Defs.OFFICES[oid]["roles"][0]].has("mi"):
		c.mi_pot = maxf(c.mi_pot, r.randf_range(60.0, 88.0))
		c.mi_real = c.mi_pot * r.randf_range(0.8, 0.95)
	c.fame = r.randf_range(30.0, 70.0)
	_roll_hidden(c, r, 0.0, 0.08)
	_roll_fate(w, c)
	return c


static func _name_used(w: World, n: String) -> bool:
	for c: Character in w.chars.values():
		if c.name == n:
			return true
	return false


static func _name(w: World, r: RandomNumberGenerator, nid: String, female: bool) -> String:
	var all: Dictionary = GameData.names()
	var nd: Dictionary = all.get(nid, all["dai_ha"])
	var n: = ""
	for tries in 8:
		n = "%s %s" % [Rng.pick(r, nd["ho"]), Rng.pick(r, nd["nu" if female else "nam"])]
		if not _name_used(w, n):
			return n
	return n



static func roll_mi(w: World, c: Character, age: int) -> void :
	var r: = Rng.make([w.world_seed, "gen_mi", c.id])
	var pot: = r.randf_range(5.0, 60.0) + r.randf_range(5.0, 35.0)
	if c.has_talent("bien_tai"):
		pot += 15.0
	if c.has_trait("kieu_ngao"):
		pot -= 5.0
	c.mi_pot = clampf(pot, 5.0, 95.0)
	c.mi_real = maxf(3.0, c.mi_pot * clampf(0.35 + (age - 14) * 0.012 + r.randf_range(-0.08, 0.08), 0.3, 0.9))



static func _stat_bias(w: World, city_id: String) -> Array:
	var city: Dictionary = w.cities[city_id]
	var nat: Dictionary = w.nations[city["nation"]]
	var bias_keys: Array = nat["bias"]
	var b: Array = []
	for i in Defs.N_STATS:
		var v: = clampf((float(city[CITY_STAT[i]]) - 50.0) / 10.0, -5.0, 5.0)
		if bias_keys.has(Defs.STAT_KEYS[i]):
			v += 3.0
		for f in city.get("features", []):
			v += float(Defs.FEATURE_BIAS.get(f, {}).get("stats", {}).get(i, 0.0))
		b.append(v)
	return b



static func _roll_potential(w: World, c: Character, r: RandomNumberGenerator) -> void :
	var bias: = _stat_bias(w, c.city_id)
	var x: = r.randf()
	var top: float
	if x < 0.6:
		top = r.randf_range(35.0, 59.9)
	elif x < 0.88:
		top = r.randf_range(60.0, 74.9)
	elif x < 0.98:
		top = r.randf_range(75.0, 89.9)
	else:
		top = r.randf_range(90.0, 99.0)
	var wts: Array = []
	for i in Defs.N_STATS:
		wts.append(10.0 + float(bias[i]) * 1.5)
	var ti: = Rng.pick_weighted(r, wts)
	for i in Defs.N_STATS:
		c.pot[i] = r.randf_range(10.0, top * 0.75)
	c.pot[ti] = top
	if r.randf() < 0.5:
		var si: = Rng.pick_weighted(r, Defs.AFFINITY[ti])
		c.pot[si] = maxf(float(c.pot[si]), top - r.randf_range(5.0, 20.0))
	for i in Defs.N_STATS:
		if i != ti:
			c.pot[i] = clampf(float(c.pot[i]) + float(bias[i]) * 0.5, 5.0, top)


static func add_trait(c: Character, t: String) -> void :
	if c.traits.has(t):
		return
	c.traits.append(t)
	var d: Dictionary = GameData.trait_def(t)
	c.y_chi = clampf(c.y_chi + float(d.get("y_chi", 0)), 0.0, 100.0)
	c.tham_vong = clampf(c.tham_vong + float(d.get("tham_vong", 0)), 0.0, 100.0)
	c.loyalty = clampf(c.loyalty + float(d.get("loyalty", 0)), 0.0, 100.0)
	c.concealment = clampf(c.concealment + float(d.get("concealment", 0)), 0.0, 100.0)


static func _roll_traits(c: Character, r: RandomNumberGenerator) -> void :
	c.y_chi = r.randf_range(25.0, 75.0)
	c.tham_vong = r.randf_range(20.0, 70.0)
	c.loyalty = r.randf_range(40.0, 60.0)
	var n: = 3 if r.randf() < 0.25 else 2
	var pool: Array = GameData.traits().keys()
	var tries: = 0
	while c.traits.size() < n and tries < 20:
		tries += 1
		var t: String = Rng.pick(r, pool)
		if c.traits.has(t):
			continue
		var opp: = str(GameData.trait_def(t).get("opposite", ""))
		if opp != "" and c.traits.has(opp):
			continue
		add_trait(c, t)



static func _roll_talents(c: Character, r: RandomNumberGenerator, rarity_w: Array = [70.0, 24.0, 5.5, 0.5], count_w: Array = [50, 35, 13, 2]) -> void :
	var n: = Rng.pick_weighted(r, count_w)
	var ti: = c.top_pot()
	for k in n:
		var rar: = Rng.pick_weighted(r, rarity_w)
		var cands: Array = []
		var wts: Array = []
		for tid in GameData.talents():
			var d: Dictionary = GameData.talent(tid)
			if not d.get("spawn", true) or int(d["rarity"]) != rar or c.has_talent(tid):
				continue
			cands.append(tid)
			var pb: Dictionary = d.get("pot", {})
			wts.append(3.0 if pb.has(Defs.STAT_KEYS[ti]) else 1.0)
		if cands.is_empty():
			continue
		Talents.add(c, cands[Rng.pick_weighted(r, wts)])



static func _roll_profession(w: World, c: Character, r: RandomNumberGenerator) -> void :
	var pid: String
	if r.randf() < 0.35:
		pid = str(Rng.pick(r, STAT_PROFS[c.top_pot()]))
	else:
		var city: Dictionary = w.cities[c.city_id]
		var ids: Array = []
		var wts: Array = []
		for p in Defs.PROFESSIONS:
			var pd: Dictionary = Defs.PROFESSIONS[p]
			if int(pd["w"]) <= 0:
				continue
			ids.append(p)
			var ck: String = pd["city"]
			var f: = 1.0 if ck == "" else 1.0 + (float(city[ck]) - 50.0) / 50.0
			for ft in city.get("features", []):
				if (Defs.FEATURE_BIAS.get(ft, {}).get("profs", []) as Array).has(p):
					f *= 3.0
			wts.append(float(pd["w"]) * maxf(0.2, f))
		pid = ids[Rng.pick_weighted(r, wts)]
	c.set_profession(pid)


static func _roll_real(c: Character, r: RandomNumberGenerator, age: int) -> void :
	for i in Defs.N_STATS:
		var frac: float
		if c.in_focus(i):
			frac = clampf(0.28 + (age - 14) * 0.022, 0.28, 0.8) + r.randf_range(-0.08, 0.08)
		else:
			frac = r.randf_range(0.18, 0.4)
		c.real[i] = maxf(3.0, float(c.pot[i]) * frac)



static func _roll_hidden(c: Character, r: RandomNumberGenerator, p_master: float, p_fraud: float) -> void :
	var x: = r.randf()
	if x < p_master:
		var ti: = c.top_pot()
		c.pot[ti] = maxf(float(c.pot[ti]), r.randf_range(78.0, 95.0))
		c.real[ti] = maxf(float(c.real[ti]), float(c.pot[ti]) * r.randf_range(0.7, 0.88))
		c.concealment = maxf(c.concealment, r.randf_range(60.0, 90.0))
		c.disguise_mul = [0.45, 0.45, 0.45, 0.45, 0.45, 0.45]
		c.disguise_add = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
		c.fame = minf(c.fame, 5.0)
		c.special = "an_cao_nhan"
	elif x < p_master + p_fraud:
		c.concealment = maxf(c.concealment, r.randf_range(45.0, 75.0))
		var order: Array = [0, 1, 2, 3, 4, 5]
		order.sort_custom( func(a: int, b: int) -> bool: return float(c.real[a]) > float(c.real[b]))
		c.disguise_mul = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
		c.disguise_add = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
		c.disguise_add[order[0]] = r.randf_range(20.0, 30.0)
		c.disguise_add[order[1]] = r.randf_range(10.0, 18.0)
		c.fame = minf(80.0, c.fame + 25.0)
		c.special = "hu_danh"



static func _roll_fate(w: World, c: Character) -> void :
	var fr: = w.fate_rng(["fate", c.id])
	var yrs: = 50 + fr.randi_range(0, 15) + fr.randi_range(0, 15)
	if c.has_talent("yeu_menh"):
		yrs = 35 + fr.randi_range(0, 10)
	if c.has_talent("cuong_trang"):
		yrs += 5
	c.lifespan_m = yrs * 12 + fr.randi_range(0, 11)
	var am: = c.age_months(w.m)
	if c.lifespan_m < am + 24:
		c.lifespan_m = am + 24 + fr.randi_range(0, 120)
	var ids: Array = []
	var wts: Array = []
	for eid in GameData.events():
		var fw: = float(GameData.event_def(eid).get("fate_w", 0))
		if fw > 0.0:
			ids.append(eid)
			wts.append(fw)
	var n: = Rng.pick_weighted(fr, [55, 35, 10])
	for k in n:
		var start: = maxi(w.m + 1, c.birth_m + 16 * 12)
		var end: = mini(c.birth_m + c.lifespan_m - 1, mini(c.birth_m + 60 * 12, w.m + 40 * 12))
		if end <= start:
			break
		c.fate.append({"m": fr.randi_range(start, end), "ev": ids[Rng.pick_weighted(fr, wts)], "st": "cho"})
	c.fate.sort_custom( func(a: Dictionary, b: Dictionary) -> bool: return int(a["m"]) < int(b["m"]))


static func _make_special(w: World, sd: Dictionary) -> void :
	var c: = _base(w, str(sd["city"]), int(sd["age"]))
	c.name = str(sd["name"])
	c.female = bool(sd.get("female", false))
	c.set_profession(str(sd["profession"]))
	for i in Defs.N_STATS:
		c.real[i] = float(sd["real"][i])
		c.pot[i] = float(sd["pot"][i])
	c.ngo = int(sd.get("ngo", 3))
	c.y_chi = 50.0
	c.tham_vong = 50.0
	c.loyalty = 50.0
	for t in sd.get("traits", []):
		add_trait(c, str(t))
	for t in sd.get("talents", []):
		Talents.add(c, str(t), false)
	c.y_chi = float(sd.get("y_chi", c.y_chi))
	c.tham_vong = float(sd.get("tham_vong", c.tham_vong))
	c.fame = float(sd.get("fame", 10.0))
	c.special = str(sd.get("tag", "dac_biet"))
	if sd.has("mi"):
		c.mi_real = float(sd["mi"][0])
		c.mi_pot = float(sd["mi"][1])
	else:
		roll_mi(w, c, int(sd["age"]))
	_roll_fate(w, c)
	if sd.has("fate"):
		c.fate = []
		for f in sd["fate"]:
			c.fate.append({"m": (int(f["year"]) - 1) * 12 + int(f["month"]) - 1, "ev": str(f["ev"]), "st": "cho", 
				"sev": str(f.get("sev", "")), "part": str(f.get("part", ""))})





static func roll_destinies(world_seed: int, life: int, n: int = 3, reroll: int = 0) -> Array:
	var out: Array = []
	for k in n:
		var r: = Rng.make([world_seed, "menh", life, k]) if reroll == 0 else Rng.make([world_seed, "menh", life, "r", reroll, k])
		var tmp: = Character.new()
		var top: = r.randi_range(0, 6)
		for i in Defs.N_STATS:
			tmp.pot[i] = r.randf_range(20.0, 62.0)
		var mi_pot: = r.randf_range(30.0, 75.0)
		if top < Defs.N_STATS:
			tmp.pot[top] = r.randf_range(72.0, 95.0)
			var si: = Rng.pick_weighted(r, Defs.AFFINITY[top])
			tmp.pot[si] = maxf(float(tmp.pot[si]), r.randf_range(55.0, 80.0))
		else:
			mi_pot = r.randf_range(72.0, 95.0)
		tmp.ngo = Rng.pick_weighted(r, [0, 4, 28, 38, 22, 8])
		_roll_talents(tmp, r, [55.0, 35.0, 9.0, 1.0], [0, 70, 30, 0])
		for i in Defs.N_STATS:
			var edu: = 4.0 if i == Defs.TRI or i == Defs.CHINH else 0.0
			tmp.real[i] = minf(float(tmp.pot[i]), float(tmp.pot[i]) * r.randf_range(0.22, 0.38) + edu)
		out.append({
			"name": "%s tinh" % Defs.DESTINY_STARS[top], 
			"hint": Defs.DESTINY_HINT[top], 
			"top": top, 
			"real": tmp.real.duplicate(), 
			"pot": tmp.pot.duplicate(), 
			"mi_real": mi_pot * r.randf_range(0.25, 0.4), 
			"mi_pot": mi_pot, 
			"ngo": tmp.ngo, 
			"talents": tmp.talents.duplicate(), 
		})
	return out


static func _make_player(w: World, destiny_idx: int, n_destiny: int = 3, reroll: int = 0) -> void :
	var pd: Dictionary = GameData.world_def()["player"]
	var opts: = roll_destinies(w.world_seed, w.life, n_destiny, reroll)
	var d: Dictionary = opts[clampi(destiny_idx, 0, opts.size() - 1)]
	var c: = Character.new()
	c.id = "p0"
	c.is_player = true
	c.name = str(pd["name"])
	c.female = bool(pd.get("female", false))
	c.city_id = str(pd["city"])
	c.nation_id = str(pd["nation"])
	var r: = Rng.make([w.world_seed, w.life, "player"])
	c.birth_m = w.m - 16 * 12 - r.randi_range(0, 11)
	c.set_profession("quy_toc")
	c.real = (d["real"] as Array).duplicate()
	c.pot = (d["pot"] as Array).duplicate()
	c.mi_real = float(d["mi_real"])
	c.mi_pot = float(d["mi_pot"])
	c.ngo = int(d["ngo"])
	c.destiny = str(d["name"])
	_roll_traits(c, r)
	for t in d["talents"]:
		Talents.add(c, str(t), false)
	var yrs: = 55 + r.randi_range(0, 12) + r.randi_range(0, 12)
	if c.has_talent("yeu_menh"):
		yrs = 38 + r.randi_range(0, 8)
	c.lifespan_m = yrs * 12 + r.randi_range(0, 11)
	c.fame = 5.0
	c.add_log(w.m, "Chào đời với mệnh cách %s (thiên hướng %s)" % [d["name"], d["hint"]])
	w.chars[c.id] = c
	w.player_id = c.id
	w.clan = {
		"name": str(pd["clan"]), "city": str(pd["city"]), "tier": 1, 
		"money": float(pd["money"]), "prestige": float(pd["prestige"]), "retainers": [], 
	}
