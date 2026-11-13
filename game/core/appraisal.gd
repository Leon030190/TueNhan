class_name Appraisal
extends RefCounted






static func half_width(base: float, observer_tri: float) -> float:
	return base * (1.0 - clampf(observer_tri, 0.0, 100.0) / 250.0)



static func band(w: World, c: Character, kind: String, i: int, tier: int, value: float, half: float) -> Array:
	if half <= 0.01:
		return [roundi(value), roundi(value)]
	var r: = Rng.make([w.world_seed, "appr", c.id, kind, i, tier])
	var o: = r.randf_range( - half, half)

	var top: = Defs.POT_HARD_CAP if value > Defs.POT_CAP else Defs.POT_CAP
	return [maxi(0, floori(value + o - half)), mini(int(top), ceili(value + o + half))]


static func appraise(w: World, c: Character, tier: int, observer: Character = null) -> Dictionary:
	var tri: float = 0.0 if observer == null else float(observer.real[Defs.TRI])
	var pen: float = Defs.TIER_PEN[tier]
	var hidden: = c.concealment > pen
	var fake: = hidden and c.has_disguise()
	var masked: = hidden and not fake
	var wm: = 2.0 if masked else 1.0
	var rec: = {"id": c.id, "tier": tier, "m": w.m, "fake": fake, "masked": masked, "anomaly": false}
	var reals: Array = []
	var pots: Array = []
	for i in Defs.N_STATS:
		var rv: float = c.shown_real(i) if fake else float(c.real[i])
		var pv: float = c.shown_pot(i) if fake else float(c.pot[i])
		var wr: float = Defs.TIER_W_REAL[tier]
		if tier == 0:
			wr *= 1.0 - 0.75 * clampf(c.fame, 0.0, 100.0) / 100.0
		reals.append(band(w, c, "r", i, tier, rv, half_width(wr, tri) * wm))
		var wp: float = Defs.TIER_W_POT[tier]
		pots.append([] if wp < 0.0 else band(w, c, "p", i, tier, pv, half_width(wp, tri) * wm))
	rec["real"] = reals
	rec["pot"] = pots

	var wmr: float = Defs.TIER_W_REAL[tier] * (0.6 if tier == 0 else 1.0)
	if tier == 0:
		wmr *= 1.0 - 0.75 * clampf(c.fame, 0.0, 100.0) / 100.0
	rec["mi_real"] = band(w, c, "mr", 0, tier, c.mi_real, half_width(wmr, tri) * wm)
	var wmp: float = Defs.TIER_W_POT[tier]
	rec["mi_pot"] = [] if wmp < 0.0 else band(w, c, "mp", 0, tier, c.mi_pot, half_width(wmp, tri) * wm)
	if tier >= 1:
		rec["health"] = roundi(c.health)
		var inj: Array = []
		for x in c.injuries:
			inj.append(str(x["name"]))
		rec["injuries"] = inj
	if tier >= 2 and not hidden:
		rec["ngo"] = c.ngo
		var maxr: int = Defs.TIER_MAX_RARITY[tier]
		var tl: Array = []
		for t in c.talents:
			if int(GameData.talent(t).get("rarity", 0)) <= maxr:
				tl.append(t)
		rec["talents"] = tl
	if tier >= 3 and not hidden:
		rec["traits"] = c.traits.duplicate()
		rec["loyalty"] = roundi(c.loyalty)
		rec["y_chi"] = roundi(c.y_chi)
		rec["tham_vong"] = roundi(c.tham_vong)
		if not c.crisis.is_empty():
			rec["crisis"] = Crisis.probabilities(w, c)
	if tier >= 3 and hidden and c.concealment <= pen + 30.0:
		rec["anomaly"] = true
	if tier >= 4 and not hidden:
		var hints: Array = []
		for f in c.fate:
			var fm: = int(f["m"])
			if str(f["st"]) == "cho" and fm >= w.m and fm <= w.m + 24:
				var good: = ["cao_nhan", "bi_tich", "doi_thu"].has(str(f["ev"]))
				hints.append({"in": fm - w.m, "kind": "cơ duyên" if good else "kiếp nạn"})
		rec["fate"] = hints
	return rec



static func perceived_real(w: World, c: Character, i: int) -> float:
	var base: = c.shown_real(i)
	var half: = 20.0 * (1.0 - 0.75 * clampf(c.fame, 0.0, 100.0) / 100.0)
	var r: = Rng.make([w.world_seed, w.life, "perc", c.id, i, w.year()])
	return clampf(base + r.randf_range( - half, half), 0.0, Defs.POT_HARD_CAP)



static func perceived_mi(w: World, c: Character) -> float:
	var half: = 10.0 * (1.0 - 0.75 * clampf(c.fame, 0.0, 100.0) / 100.0)
	var r: = Rng.make([w.world_seed, w.life, "perc_mi", c.id, w.year()])
	return clampf(Items.eff_mi(c) + r.randf_range( - half, half), 0.0, 100.0)



static func perceived_vals(w: World, c: Character) -> Array:
	var v: Array = []
	for i in Defs.N_STATS:
		v.append(perceived_real(w, c, i))
	v.append(perceived_mi(w, c))
	return v


static func perceived_office_score(w: World, c: Character, office_id: String, vals: Array = []) -> float:
	var pv: Array = perceived_vals(w, c) if vals.is_empty() else vals
	var best: = 0.0
	for role in Defs.OFFICES[office_id]["roles"]:
		best = maxf(best, c.role_score(role, pv))
	return best
