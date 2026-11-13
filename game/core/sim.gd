class_name Sim
extends RefCounted


const MAX_ALIVE: = 650
const SPAWN_POP: = 4500000.0
const MIGRATE_P: = 0.008


static func tick(w: World) -> void :
	NationSim.tick(w)
	Growth.tick(w)
	Life.tick(w)
	Events.tick(w)
	War.tick(w)
	Crisis.tick(w)
	Talents.evolve_tick(w)
	Appointment.fill_vacancies(w)
	Rivals.tick(w)
	if w.month() == 12:
		Appointment.yearly_review(w)
	Merit.tick(w)
	_social(w)
	_migrate(w)
	_spawn(w)
	w.m += 1


static func run(w: World, months: int) -> void :
	for k in months:
		tick(w)



static func _social(w: World) -> void :
	for c: Character in w.living():
		var target: = 50.0
		if c.has_trait("trung_hau"):
			target += 10.0
		if c.has_trait("gian_xao"):
			target -= 10.0
		if c.office_key != "":
			target += 10.0
		c.loyalty += clampf(target - c.loyalty, -1.0, 1.0)
		if c.has_talent("trung_thanh"):
			c.loyalty = maxf(c.loyalty, 70.0)
		if c.office_key == "" and c.fame < 50.0 and not c.has_trait("an_dat"):
			var g: = 0.04 * maxf(0.0, c.max_real() - 40.0) / 10.0
			if c.has_trait("khiem_ton"):
				g *= 0.5
			c.fame = minf(50.0, c.fame + g)
		if c.nation_id != "" and not c.is_player and c.loyalty < 20.0 and c.tham_vong > 60.0:
			if w.rng(["defect", c.id]).randf() < 0.015:
				_defect(w, c)


static func _defect(w: World, c: Character) -> void :
	var old: = c.nation_id
	var others: Array = []
	for nid in w.nations:
		if nid != old:
			others.append(nid)
	if others.is_empty():
		return
	var nid: String = others[0]
	Appointment.vacate(w, c, "bỏ sang " + w.nation_name(nid))
	c.nation_id = nid
	c.faction_id = ""
	c.city_id = str(w.nations[nid]["capital"])
	c.loyalty = 50.0
	c.add_log(w.m, "Bỏ %s sang %s" % [w.nation_name(old), w.nation_name(nid)])
	w.add_news("%s bỏ %s sang đầu quân cho %s." % [c.name, w.nation_name(old), w.nation_name(nid)], [c.id], "quoc_gia")
	w.count("defect")





static func _migrate(w: World) -> void :
	var fronts: = {}
	for wr in w.wars:
		fronts[str(wr["front"])] = true
	for c: Character in w.living():
		if c.is_player or c.office_key != "" or c.clan_retainer or c.patron != "" or c.age(w.m) < 16 or c.special == "lam_van":
			continue
		var city: Dictionary = w.cities[c.city_id]
		var links: Dictionary = city["links"]
		if links.is_empty():
			continue
		var p: = MIGRATE_P
		var unsafe: = fronts.has(c.city_id) or float(city["an_ninh"]) < 35.0
		if unsafe:
			p += 0.04
		var pull: = ""
		match c.profession:
			"thu_sinh", "quy_toc":
				pull = "hoc"
				if w.month() == 2:
					p += 0.06
			"vo_sinh", "kiem_khach":
				pull = "vo"
				p += 0.008
			"thuong_nhan", "tieu_thuong":
				pull = "buon"
				p += 0.008
		var r: = w.rng(["migrate", c.id])
		if r.randf() >= p:
			continue
		var opts: Array = []
		var wts: Array = []
		for nb in links:
			if not w.cities.has(nb) or fronts.has(nb):
				continue
			var d: Dictionary = w.cities[nb]
			var wt: = float(d["pop"]) / 100000.0
			match pull:
				"hoc":
					wt *= 1.0 + float(d["giao_duc"]) / 25.0 + (3.0 if w.has_feature(nb, "hoc_phu") else 0.0)
					for nid in w.nations:
						if str(w.nations[nid]["capital"]) == nb:
							wt *= 2.0
				"vo":
					wt *= 1.0 + (4.0 if w.has_feature(nb, "vo_duong") else 0.0) + float(d["quan_su"]) / 50.0
				"buon":
					wt *= 1.0 + float(d["kinh_te"]) / 25.0
			if unsafe:
				wt *= 1.0 + float(d["an_ninh"]) / 25.0
			opts.append(nb)
			wts.append(maxf(0.05, wt))
		if opts.is_empty():
			continue
		var to: String = opts[Rng.pick_weighted(r, wts)]
		var why: String = "tránh loạn" if unsafe else ({"hoc": "tìm thầy, ứng thí", "vo": "tìm võ đường", "buon": "buôn bán"}.get(pull, "kiếm sống"))
		c.add_log(w.m, "Rời %s tới %s (%s)" % [w.city_name(c.city_id), w.city_name(to), why])
		c.city_id = to
		w.count("migrate")
		if w.play.has("leads"):
			w.play["leads"] = (w.play["leads"] as Array).filter( func(l: Dictionary) -> bool: return str(l["id"]) != c.id)



static func _spawn(w: World) -> void :
	if w.living().size() >= MAX_ALIVE:
		return
	for cid in w.cities:
		var r: = Rng.make([w.world_seed, "spawn", cid, w.m])
		if r.randf() < float(w.cities[cid]["pop"]) / SPAWN_POP:
			WorldGen.new_commoner(w, cid, 14 + r.randi_range(0, 2))
			w.count("spawn")
