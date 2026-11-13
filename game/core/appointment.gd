class_name Appointment
extends RefCounted



const MIN_SCORE: = 25.0
const REVIEW_MARGIN: = 12.0
const MAX_CHANGES_PER_YEAR: = 2
const RETIRE_AGE: = 70
const KNOWN_FAME: = 25.0


static func office_of_key(key: String) -> String:
	return key.split("#")[0]


static func office_label(w: World, nid: String, key: String) -> String:
	var slot: Dictionary = w.nations[nid]["offices"][key]
	var oid: String = slot["office"]
	var nm: String = Defs.OFFICES[oid]["name"]
	if bool(Defs.OFFICES[oid].get("per_city", false)):
		nm += " " + w.city_name(str(slot["city"]))
	return nm


static func office_label_of(w: World, c: Character) -> String:
	if c.office_key == "":
		return ""
	var parts: = c.office_key.split("/")
	return office_label(w, parts[0], parts[1])


static func office_id_of(c: Character) -> String:
	if c.office_key == "":
		return ""
	return office_of_key(c.office_key.split("/")[1])


static func office_focus(oid: String) -> Array:
	var role: String = Defs.OFFICES[oid]["roles"][0]
	var rw: Array = Defs.ROLES[role]["w"]
	var idx: Array = [0, 1, 2, 3, 4, 5]
	idx.sort_custom( func(a: int, b: int) -> bool: return float(rw[a]) > float(rw[b]))
	return [int(idx[0]), int(idx[1])]


static func faction_for(nat: Dictionary, military: bool) -> String:
	var want: = "military" if military else "civil"
	for fid in nat["factions"]:
		if str(nat["factions"][fid]["pref"]) == want:
			return fid
	return ""


static func appoint(w: World, nid: String, key: String, c: Character, silent: bool = false) -> void :
	var nat: Dictionary = w.nations[nid]
	var slot: Dictionary = nat["offices"][key]
	var oid: String = slot["office"]
	var mil: bool = Defs.OFFICES[oid]["military"]
	slot["holder"] = c.id
	c.office_key = nid + "/" + key
	c.nation_id = nid
	if c.faction_id == "" or not (nat["factions"] as Dictionary).has(c.faction_id):
		c.faction_id = faction_for(nat, mil)
	c.profession = "vo_quan" if mil else "quan_lai"
	c.env = "quan_doanh" if mil else "trieu_dinh"
	c.focus = office_focus(oid)
	c.city_id = str(slot["city"])
	c.loyalty = maxf(c.loyalty, 55.0)
	c.office_months = 0
	var label: = office_label(w, nid, key)
	c.add_log(w.m, "Nhậm chức %s của %s" % [label, nat["name"]])
	if not silent:
		w.add_news("%s được bổ nhiệm làm %s (%s)." % [c.name, label, nat["name"]], [c.id], "bo_nhiem")
		w.count("appoint")



static func promote_or_appoint(w: World, nid: String, key: String, c: Character) -> void :
	if c.office_key != "":
		var old: = office_label_of(w, c)
		vacate(w, c, "được thăng chức", true)
		c.set_mood("phan_chan", 3)
		c.add_log(w.m, "Được thăng từ %s" % old)
		w.count("promote")
	appoint(w, nid, key, c)


static func vacate(w: World, c: Character, reason: String, quiet: bool = false) -> void :
	if c.office_key == "":
		return
	var parts: = c.office_key.split("/")
	var label: = office_label(w, parts[0], parts[1])
	var slot: Dictionary = w.nations[parts[0]]["offices"][parts[1]]
	if str(slot["holder"]) == c.id:
		slot["holder"] = ""
	c.office_key = ""
	c.office_months = 0
	if c.alive:
		c.set_profession("cuu_quan")
		c.env = ""
		c.idle_until = w.m + IDLE_MONTHS
	c.add_log(w.m, "Rời chức %s (%s)" % [label, reason])
	if reason != "qua đời" and not quiet:
		w.add_news("%s rời chức %s: %s." % [c.name, label, reason], [c.id], "bo_nhiem")
	if c.recommender != "" and c.recommender == w.player_id:
		PlayerOps.on_vacate(w, c, label, reason)


static func weight_of(c: Character) -> float:
	var oid: = office_id_of(c)
	return 0.0 if oid == "" else float(Defs.OFFICES[oid]["weight"])




const IDLE_MONTHS: = 6
const SHAME_MONTHS: = 24


static func shamed(w: World, c: Character) -> bool:
	return c.shame_until > w.m


static func shame(w: World, c: Character) -> void :
	c.shame_until = w.m + SHAME_MONTHS



static func idle_tick(w: World) -> void :
	for c: Character in w.living():
		if c.is_player or c.office_key != "" or c.nation_id == "" or c.clan_retainer:
			continue
		if c.idle_until < 0:
			if c.profession == "cuu_quan":
				c.idle_until = w.m + IDLE_MONTHS
			continue
		if w.m < c.idle_until:
			continue
		var nid: = c.nation_id
		c.idle_until = -1
		c.nation_id = ""
		c.faction_id = ""
		var cities: = w.nation_cities(nid)
		if not cities.is_empty():
			c.city_id = str(Rng.pick(w.rng(["ve_que", c.id]), cities))
		c.add_log(w.m, "Thôi chờ bổ dụng, rời kinh về %s" % w.city_name(c.city_id))


static func candidates(w: World, nid: String) -> Array:
	var cities: = w.nation_cities(nid)
	var res: Array = []
	for c: Character in w.living():
		if c.is_player or c.clan_retainer or c.patron != "" or not c.crisis.is_empty() or c.shame_until > w.m:
			continue
		if c.office_key != "" and ( not c.office_key.begins_with(nid + "/") or weight_of(c) >= 2.0):
			continue
		var age: = c.age(w.m)
		if age < 18 or age >= RETIRE_AGE - 2:
			continue
		if c.nation_id == nid:
			res.append(c)
		elif c.nation_id == "" and cities.has(c.city_id) and c.fame >= KNOWN_FAME:
			res.append(c)
	return res


static func score(w: World, c: Character, nid: String, oid: String, pv: Array = []) -> float:
	var nat: Dictionary = w.nations[nid]
	var facs: Dictionary = nat["factions"]
	var support: = 30.0
	if c.faction_id != "" and facs.has(c.faction_id):
		support = float(facs[c.faction_id]["power"])
	return Appraisal.perceived_office_score(w, c, oid, pv) * 0.6 + c.fame * 0.2 + support * 0.2 + charm_term(w, c)



static func incumbency(c: Character) -> float:
	return 5.0 + minf(10.0, float(c.office_months) / 6.0)



static func needs_text(oid: String) -> String:
	var parts: Array = []
	for role in Defs.OFFICES[oid]["roles"]:
		var rd: Dictionary = Defs.ROLES[role]
		var ws: Array = rd["w"]
		var idx: Array = []
		for i in ws.size():
			if float(ws[i]) > 0.0:
				idx.append(i)
		idx.sort_custom( func(a: int, b: int) -> bool: return float(ws[a]) > float(ws[b]))
		var names: Array = []
		for i in idx:
			names.append(Defs.STAT_NAMES[i] + (" (chính)" if float(ws[i]) >= 0.5 else ""))
		if rd.has("mi"):
			names.append("Mị lực (chính)")
		parts.append("%s: %s" % [rd["name"], ", ".join(names)])
	return " · hoặc ".join(parts)



static func score_parts(w: World, c: Character, nid: String, oid: String) -> Array:
	var nat: Dictionary = w.nations[nid]
	var facs: Dictionary = nat["factions"]
	var fac: = "không phe phái (mặc định 30)"
	var support: = 30.0
	if c.faction_id != "" and facs.has(c.faction_id):
		support = float(facs[c.faction_id]["power"])
		fac = "phe %s (sức %d)" % [facs[c.faction_id]["name"], roundi(support)]
	var seen: Array = []
	var shown: = {}
	for role in Defs.OFFICES[oid]["roles"]:
		var ws: Array = Defs.ROLES[role]["w"]
		for i in ws.size():
			if float(ws[i]) > 0.0 and not shown.has(i):
				shown[i] = true
				seen.append("%s ~%d" % [Defs.STAT_NAMES[i], roundi(Appraisal.perceived_real(w, c, i))])
	return [
		["Năng lực ở chức này, theo những gì triều đình thấy (%s)" % ", ".join(seen), Appraisal.perceived_office_score(w, c, oid) * 0.6], 
		["Danh tiếng %d" % roundi(c.fame), c.fame * 0.2], 
		["Thế lực: %s" % fac, support * 0.2], 
		["Dung mạo, ăn nói (Mị lực triều đình thấy ~%d)" % roundi(Appraisal.perceived_mi(w, c)), charm_term(w, c)], 
	]



static func charm_term(w: World, c: Character) -> float:
	return (Appraisal.perceived_mi(w, c) - 50.0) * Defs.CHARM_WEIGHT



static func snub_chance(w: World, c: Character) -> float:
	return clampf((Defs.SNUB_BELOW - Appraisal.perceived_mi(w, c)) / 50.0, 0.0, 0.6)


static func snubbed(w: World, c: Character) -> bool:
	var ch: = snub_chance(w, c)
	if ch <= 0.0:
		return false
	return Rng.make([w.world_seed, w.life, "snub", c.id, w.year()]).randf() < ch


static func _best(w: World, pool: Array, nid: String, oid: String, cache: Dictionary) -> Array:
	var best: Character = null
	var bs: = -1.0
	var wt: = float(Defs.OFFICES[oid]["weight"])
	for c: Character in pool:
		if c.office_key != "" and weight_of(c) >= wt:
			continue
		if snubbed(w, c):
			continue
		if not cache.has(c.id):
			cache[c.id] = Appraisal.perceived_vals(w, c)
		var s: = score(w, c, nid, oid, cache[c.id])
		if s > bs:
			bs = s
			best = c
	return [best, bs]


static func fill_vacancies(w: World) -> void :
	for nid in w.nations:
		var offices: Dictionary = w.nations[nid]["offices"]
		var pool: Array = []
		var built: = false
		var cache: = {}
		for key in offices:
			if str(offices[key]["holder"]) != "":
				continue
			if not built:
				pool = candidates(w, nid)
				built = true
			var res: = _best(w, pool, nid, office_of_key(key), cache)
			var best: Character = res[0]
			if best != null and float(res[1]) >= MIN_SCORE:
				promote_or_appoint(w, nid, key, best)
				pool.erase(best)



static func yearly_review(w: World) -> void :
	for nid in w.nations:
		var offices: Dictionary = w.nations[nid]["offices"]
		for key in offices:
			var c: = w.office_holder(nid, key)
			if c != null and c.age(w.m) >= RETIRE_AGE:
				vacate(w, c, "cáo lão về quê")
				c.set_profession("lao_than")
		var pool: = candidates(w, nid)
		var cache: = {}
		var changes: = 0
		for key in offices:
			if changes >= MAX_CHANGES_PER_YEAR:
				break
			var cur: = w.office_holder(nid, key)
			if cur == null:
				continue
			var oid: = office_of_key(key)
			var cs: = score(w, cur, nid, oid) + REVIEW_MARGIN - Rivals.remnant_penalty(w, cur)
			var res: = _best(w, pool, nid, oid, cache)
			var best: Character = res[0]
			if best != null and float(res[1]) > cs:
				vacate(w, cur, "bị thay thế bởi " + best.name)
				cur.loyalty = maxf(0.0, cur.loyalty - (30.0 if cur.has_talent("do_ky") else 15.0))
				cur.set_mood("sa_sut", 3)
				promote_or_appoint(w, nid, key, best)
				pool.erase(best)
				changes += 1
				w.count("replace")
