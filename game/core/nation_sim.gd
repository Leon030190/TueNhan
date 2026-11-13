class_name NationSim
extends RefCounted




const TAX_K: = 0.001
const FOOD_K: = 0.004
const FOOD_EAT_POP: = 0.0012
const FOOD_EAT_TROOP: = 0.003
const TROOP_COST: = 0.006
const OFFICIAL_COST: = 4.0
const RECRUIT_TREASURY: = 3000.0
const FOOD_STORE_MONTHS: = 12.0


static func eff(w: World, nid: String, key: String) -> float:
	var offices: Dictionary = w.nations[nid]["offices"]
	if not offices.has(key):
		return 0.0
	var c: = w.office_holder(nid, key)
	if c == null:
		return 0.0
	return clampf((c.office_score(Appointment.office_of_key(key)) - 30.0) / 60.0, 0.0, 1.5)


static func tick(w: World) -> void :
	for nid in w.nations:
		_economy(w, nid)
		_factions(w, nid)


static func _economy(w: World, nid: String) -> void :
	var nat: Dictionary = w.nations[nid]
	var e_hb: = eff(w, nid, "ho_bo#0")
	var e_cb: = eff(w, nid, "cong_bo#0")
	var e_tt: = eff(w, nid, "thua_tuong#0")
	var e_bb: = eff(w, nid, "binh_bo#0")
	var income: = float(nat.get("base_income", 0.0))
	var food: = float(nat.get("base_food", 0.0))
	var pop_total: = 0.0
	for cid in w.nation_cities(nid):
		var city: Dictionary = w.cities[cid]
		var e_th: = eff(w, nid, "thai_thu#" + cid)
		var e_hl: = eff(w, nid, "huyen_lenh#" + cid)
		var e_du: = eff(w, nid, "do_uy#" + cid)
		var pop: float = city["pop"]
		pop_total += pop

		var gov: = 0.4 + 0.5 * e_th + 0.1 * e_hl
		income += pop * float(city["kinh_te"]) / 100.0 * TAX_K * gov * (0.6 + 0.6 * e_hb)
		food += pop * float(city["sx"]) / 100.0 * FOOD_K * gov * (0.6 + 0.6 * e_cb)


		var base: Dictionary = city["base"]
		city["kinh_te"] = clampf(_drift(city, base, "kinh_te") + (e_th - 0.5) * 0.1 + (e_hb - 0.5) * 0.06, 5.0, 95.0)
		city["sx"] = clampf(_drift(city, base, "sx") + (e_th - 0.5) * 0.06 + (e_cb - 0.5) * 0.1, 5.0, 95.0)
		city["an_ninh"] = clampf(_drift(city, base, "an_ninh") + (e_th - 0.5) * 0.06 + (e_du - 0.5) * 0.06, 5.0, 95.0)
		var pros: = (float(city["kinh_te"]) + float(city["sx"]) + float(city["an_ninh"])) / 3.0
		city["phon_vinh"] = pros
		city["pop"] = pop * (1.0 + 0.0002 * (pros - 40.0) / 10.0)
	var troops: float = nat["troops"]
	var filled: = 0
	for key in nat["offices"]:
		if str(nat["offices"][key]["holder"]) != "":
			filled += 1
	var expense: = troops * TROOP_COST + filled * OFFICIAL_COST
	var eat: = pop_total * FOOD_EAT_POP + troops * FOOD_EAT_TROOP
	food -= eat
	var tre: float = float(nat["treasury"]) + income - expense
	var fs: float = minf(float(nat["food"]) + food, eat * FOOD_STORE_MONTHS)
	var shortage: = fs < 0.0
	if shortage:
		fs = 0.0
	var base_troops: = float(nat.get("base_troops", troops))
	if not nat.has("base_troops"):
		nat["base_troops"] = troops
	var at_war_now: = not War.wars_of(w, nid).is_empty()
	if tre < 0.0:
		tre = 0.0
		troops *= 0.995
	elif at_war_now and troops < base_troops * 0.8 and tre > 500.0:

		var draft: = minf(base_troops * 0.02, (tre - 500.0) / 2.0)
		troops += draft
		tre -= draft * 2.0
	elif tre > RECRUIT_TREASURY:
		var recruit: = troops * 0.003
		troops += recruit
		tre -= recruit * 2.0
	nat["last_income"] = income - expense
	nat["last_food"] = food
	nat["treasury"] = tre
	nat["food"] = fs
	nat["troops"] = troops
	nat["shortage"] = shortage
	nat["quality"] = lerpf(float(nat["quality"]), 0.75 + 0.5 * e_bb, 0.02)
	var at_war: = not War.wars_of(w, nid).is_empty()
	var target: = 40.0 + 30.0 * e_tt - (15.0 if shortage else 0.0) - (5.0 if at_war else 0.0)
	var tt: = w.office_holder(nid, "thua_tuong#0")
	if tt != null:
		target += (tt.mi_real - 50.0) * 0.1
	nat["stability"] = clampf(float(nat["stability"]) + (target - float(nat["stability"])) * 0.05, 0.0, 100.0)


static func _drift(city: Dictionary, base: Dictionary, k: String) -> float:
	var v: = float(city[k])
	return v + (float(base[k]) - v) * 0.01



static func _factions(w: World, nid: String) -> void :
	var nat: Dictionary = w.nations[nid]
	var facs: Dictionary = nat["factions"]
	var held: = {}
	for fid in facs:
		held[fid] = 0.0
	var total: = 0.0
	for key in nat["offices"]:
		var c: = w.office_holder(nid, key)
		if c == null:
			continue
		var wgt: float = Defs.OFFICES[Appointment.office_of_key(key)]["weight"]
		total += wgt
		if held.has(c.faction_id):
			held[c.faction_id] = float(held[c.faction_id]) + wgt
	if total <= 0.0:
		return
	for fid in facs:
		var p: = float(facs[fid]["power"])
		facs[fid]["power"] = p + (100.0 * float(held[fid]) / total - p) * 0.03



static func command(w: World, nid: String) -> float:
	var nat: Dictionary = w.nations[nid]
	var best: = 20.0
	var second: = 20.0
	for key in nat["offices"]:
		var oid: = Appointment.office_of_key(key)
		if oid == "dai_tuong" or oid == "tuong_quan":
			var c: = w.office_holder(nid, key)
			if c != null:
				var s: = c.office_score(oid)
				if s > best:
					second = best
					best = s
				elif s > second:
					second = s
	return 0.7 * best + 0.3 * second



static func army_strength(w: World, nid: String) -> float:
	var nat: Dictionary = w.nations[nid]
	var supply: = 0.6 if bool(nat.get("shortage", false)) else 1.0
	return float(nat["troops"]) * float(nat["quality"]) * (0.6 + command(w, nid) / 60.0) * supply
