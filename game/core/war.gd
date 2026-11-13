class_name War
extends RefCounted







const DECLARE_REL: = -40.0
const DECLARE_RATIO: = 1.25
const DECLARE_P: = 0.03
const DECLARE_STABILITY: = 50.0
const CAPTURE_SCORE: = 80.0
const SCORE_PER_BATTLE: = 25.0
const DEFENSE_BONUS: = 1.2
const CAPITAL_BONUS: = 1.3
const PASS_BONUS: = 1.25
const TRUCE_MONTHS: = 24
const ALLY_AT: = 60.0
const ALLY_BREAK: = 30.0
const REL_NAMES: = [[-61.0, "Tử địch"], [-21.0, "Thù địch"], [20.0, "Trung lập"], [60.0, "Hữu hảo"], [101.0, "Đồng minh"]]


static func rel_name(v: float) -> String:
	for pr in REL_NAMES:
		if v < float(pr[0]):
			return str(pr[1])
	return "Đồng minh"


static func pact(w: World, a: String, b: String) -> Dictionary:
	var k: = World.rel_key(a, b)
	if not w.pacts.has(k):
		w.pacts[k] = {"ally": false, "truce": -1}
	return w.pacts[k]


static func allied(w: World, a: String, b: String) -> bool:
	return w.pacts.has(World.rel_key(a, b)) and bool(w.pacts[World.rel_key(a, b)]["ally"])


static func war_of(w: World, a: String, b: String) -> Dictionary:
	for wr in w.wars:
		if (str(wr["a"]) == a and str(wr["b"]) == b) or (str(wr["a"]) == b and str(wr["b"]) == a):
			return wr
	return {}


static func at_war(w: World, a: String, b: String) -> bool:
	return not war_of(w, a, b).is_empty()


static func wars_of(w: World, nid: String) -> Array:
	var res: Array = []
	for wr in w.wars:
		if str(wr["a"]) == nid or str(wr["b"]) == nid:
			res.append(wr)
	return res



static func border_cities(w: World, attacker: String, defender: String) -> Array:
	var res: Array = []
	for cid in w.nation_cities(defender):
		for nb in w.cities[cid]["links"]:
			if w.cities.has(nb) and w.city_nation(nb) == attacker and not res.has(cid):
				res.append(cid)
	return res


static func tick(w: World) -> void :
	_diplomacy(w)
	_declare(w)
	_fight(w)




static func _diplomacy(w: World) -> void :
	for key in w.relations.keys():
		var parts: PackedStringArray = str(key).split("|")
		var a: = parts[0]
		var b: = parts[1]
		var v: float = w.relations[key]
		var base: = float(w.rel_base.get(key, 0.0))

		for side in [a, b]:
			if w.nations.has(side):
				base += 12.0 * (NationSim.eff(w, side, "le_bo#0") - 0.4)
		v += clampf(base - v, -0.3, 0.3)

		for wr in w.wars:
			var foe: = ""
			if str(wr["a"]) == a or str(wr["b"]) == a:
				foe = str(wr["b"]) if str(wr["a"]) == a else str(wr["a"])
			if foe != "" and foe != b and at_war(w, b, foe):
				v += 0.5

		var p: = w.player()
		if p != null and p.nation_id != "" and (a == p.nation_id or b == p.nation_id):
			var other: = b if a == p.nation_id else a
			for k2 in ["thua_tuong#0", "ho_bo#0"]:
				if w.nations.has(other):
					var c: = w.office_holder(other, k2)
					if c != null and c.recommender == p.id and c.favor >= 50.0:
						v += 0.4
		w.relations[key] = clampf(v, -100.0, 100.0)
		var pc: = pact(w, a, b)
		if not bool(pc["ally"]) and v >= ALLY_AT and not at_war(w, a, b):
			pc["ally"] = true
			w.add_news("%s và %s kết làm đồng minh." % [w.nation_name(a), w.nation_name(b)], [], "quoc_gia")
			w.count("alliance")
		elif bool(pc["ally"]) and v < ALLY_BREAK:
			pc["ally"] = false
			w.add_news("Liên minh %s – %s tan vỡ." % [w.nation_name(a), w.nation_name(b)], [], "quoc_gia")




static func _declare(w: World) -> void :
	for key in w.relations.keys():
		var parts: PackedStringArray = str(key).split("|")
		if at_war(w, parts[0], parts[1]):
			continue
		if int(pact(w, parts[0], parts[1])["truce"]) > w.m:
			continue
		if float(w.relations[key]) >= DECLARE_REL:
			continue
		var r: = w.rng(["declare", key])
		for pair in [[parts[0], parts[1]], [parts[1], parts[0]]]:
			var att: String = pair[0]
			var dfn: String = pair[1]
			if border_cities(w, att, dfn).is_empty():
				continue
			if float(w.nations[att]["stability"]) < DECLARE_STABILITY:
				continue
			var ratio: = NationSim.army_strength(w, att) / maxf(1.0, _side_strength(w, dfn, att))
			if ratio >= DECLARE_RATIO and r.randf() < DECLARE_P:
				declare(w, att, dfn)
				return


static func declare(w: World, att: String, dfn: String) -> void :
	var fronts: = border_cities(w, att, dfn)
	if fronts.is_empty():
		return
	var wr: = {"a": att, "b": dfn, "start": w.m, "score": 0.0, "front": _pick_front(w, fronts, dfn), "battles": 0}
	w.wars.append(wr)
	w.add_rel(att, dfn, -20.0)
	pact(w, att, dfn)["ally"] = false
	w.add_news("%s tuyên chiến với %s! Mũi tiến công nhắm vào %s." % [w.nation_name(att), w.nation_name(dfn), w.city_name(str(wr["front"]))], [], "chien_su")
	w.count("war")


static func _pick_front(w: World, fronts: Array, dfn: String) -> String:
	var cap: = str(w.nations[dfn]["capital"])
	for cid in fronts:
		if cid != cap:
			return cid
	return str(fronts[0])



static func _side_strength(w: World, nid: String, enemy: String) -> float:
	var s: = NationSim.army_strength(w, nid)
	for other in w.nations:
		if other != nid and other != enemy and allied(w, nid, other) and not at_war(w, other, enemy):
			s += 0.5 * NationSim.army_strength(w, other)
	return s




static func generals(w: World, nid: String) -> Array:
	var res: Array = []
	for key in w.nations[nid]["offices"]:
		var oid: = Appointment.office_of_key(key)
		if oid == "dai_tuong" or oid == "tuong_quan":
			var g: = w.office_holder(nid, key)
			if g != null:
				res.append(g)
	return res


static func _fight(w: World) -> void :
	for wr in w.wars.duplicate():
		if not w.wars.has(wr):
			continue
		var a: = str(wr["a"])
		var b: = str(wr["b"])
		if not w.nations.has(a) or not w.nations.has(b):
			w.wars.erase(wr)
			continue
		var front: = str(wr["front"])
		if not w.cities.has(front) or w.city_nation(front) != b:
			var fronts: = border_cities(w, a, b)
			if fronts.is_empty():
				end_war(w, wr, b, "hết đường tiến quân")
				continue
			front = _pick_front(w, fronts, b)
			wr["front"] = front
		var r: = w.rng(["war", a, b])
		var sa: = _side_strength(w, a, b) * r.randf_range(0.8, 1.2)
		var cap_bonus: = CAPITAL_BONUS if front == str(w.nations[b]["capital"]) else 1.0
		if w.has_feature(front, "cua_ai"):
			cap_bonus *= PASS_BONUS
		var sb: = _side_strength(w, b, a) * DEFENSE_BONUS * cap_bonus * r.randf_range(0.8, 1.2)
		var diff: = (sa - sb) / maxf(1.0, sa + sb)
		wr["score"] = float(wr["score"]) + diff * SCORE_PER_BATTLE
		wr["battles"] = int(wr["battles"]) + 1
		var win: = a if diff >= 0.0 else b
		var lose: = b if win == a else a
		w.nations[lose]["troops"] = float(w.nations[lose]["troops"]) * (0.98 - absf(diff) * 0.04)
		w.nations[win]["troops"] = float(w.nations[win]["troops"]) * 0.99
		_battle_people(w, win, lose, front, r)
		if absf(diff) > 0.15:
			w.add_news("Trận %s: %s đại thắng %s." % [w.city_name(front), w.nation_name(win), w.nation_name(lose)], [], "chien_su")
		var months: = w.m - int(wr["start"])
		if float(wr["score"]) >= CAPTURE_SCORE:
			capture(w, front, a)
			wr["score"] = 0.0
			if not w.nations.has(b):
				w.wars.erase(wr)
			elif r.randf() < 0.5:
				end_war(w, wr, a, "%s cắt đất cầu hòa" % w.nation_name(b))
		elif float(wr["score"]) <= - CAPTURE_SCORE:
			end_war(w, wr, b, "quân %s bị đánh bại phải rút về" % w.nation_name(a))
		elif months >= 8 and r.randf() < 0.05 + (months - 8) * 0.01:
			end_war(w, wr, a if float(wr["score"]) > 0.0 else b, "hai bên kiệt sức, nghị hòa")


static func _battle_people(w: World, win: String, lose: String, front: String, r: RandomNumberGenerator) -> void :
	for nid in [win, lose]:
		var people: = generals(w, nid)
		var du: = w.office_holder(nid, "do_uy#" + front)
		if du != null and not people.has(du):
			people.append(du)
		for c: Character in people:
			c.battles += 1
			for i in [Defs.VO, Defs.QUAN]:
				c.real[i] = minf(float(c.pot[i]), float(c.real[i]) + r.randf_range(0.3, 1.2))
			if nid == win:
				c.merit_y += 3.0
				c.merit_total += 3.0
				c.fame = minf(100.0, c.fame + 1.0)
			if r.randf() < 0.01:
				c.add_log(w.m, "Tử trận ở %s" % w.city_name(front))
				Life.die(w, c, "tử trận")
			elif r.randf() < 0.08:
				Events.injure(w, c, r, false, "", "", " trong trận %s" % w.city_name(front))



static func capture(w: World, cid: String, to: String) -> void :
	var frm: = w.city_nation(cid)
	transfer_city(w, cid, to)
	w.nations[frm]["stability"] = maxf(0.0, float(w.nations[frm]["stability"]) - 10.0)
	w.nations[to]["stability"] = minf(100.0, float(w.nations[to]["stability"]) + 5.0)
	w.add_news("%s thất thủ! %s chiếm thành từ tay %s." % [w.city_name(cid), w.nation_name(to), w.nation_name(frm)], [], "chien_su")
	w.count("capture")
	if w.nation_cities(frm).is_empty():
		annex(w, frm, to)


static func transfer_city(w: World, cid: String, to: String) -> void :
	var frm: = w.city_nation(cid)
	var offices: Dictionary = w.nations[frm]["offices"]
	var fcap: = str(w.nations[frm]["capital"])
	for key in offices.keys():
		if str(offices[key]["city"]) != cid or not bool(Defs.OFFICES[Appointment.office_of_key(key)].get("per_city", false)):
			continue
		var h: = w.office_holder(frm, key)
		if h != null:
			Appointment.vacate(w, h, "%s thất thủ" % w.city_name(cid))
			if fcap != cid:
				h.city_id = fcap
		offices.erase(key)
	w.cities[cid]["nation"] = to
	var to_off: Dictionary = w.nations[to]["offices"]
	for oid in Defs.OFFICE_ORDER:
		if bool(Defs.OFFICES[oid].get("per_city", false)):
			to_off[oid + "#" + cid] = {"office": oid, "city": cid, "holder": ""}



static func annex(w: World, loser: String, winner: String) -> void :
	for c: Character in w.chars.values():
		if c.office_key.begins_with(loser + "/"):
			Appointment.vacate(w, c, "%s diệt vong" % w.nation_name(loser))
		if c.nation_id == loser:
			c.nation_id = winner if c.is_player else ""
			c.faction_id = ""
	var nm: = w.nation_name(loser)
	w.nations.erase(loser)
	for key in w.relations.keys():
		if str(key).split("|").has(loser):
			w.relations.erase(key)
			w.rel_base.erase(key)
			w.pacts.erase(key)
	for wr in w.wars.duplicate():
		if str(wr["a"]) == loser or str(wr["b"]) == loser:
			w.wars.erase(wr)
	w.add_news("%s diệt vong, cả nước sáp nhập vào %s." % [nm, w.nation_name(winner)], [], "chien_su")
	w.count("annex")


static func end_war(w: World, wr: Dictionary, winner: String, why: String) -> void :
	w.wars.erase(wr)
	var a: = str(wr["a"])
	var b: = str(wr["b"])
	var loser: = b if winner == a else a
	if not w.nations.has(a) or not w.nations.has(b):
		return
	pact(w, a, b)["truce"] = w.m + TRUCE_MONTHS
	w.relations[World.rel_key(a, b)] = -20.0
	var pay: = minf(1500.0, float(w.nations[loser]["treasury"]))
	w.nations[loser]["treasury"] = float(w.nations[loser]["treasury"]) - pay
	w.nations[winner]["treasury"] = float(w.nations[winner]["treasury"]) + pay
	w.nations[loser]["stability"] = maxf(0.0, float(w.nations[loser]["stability"]) - 5.0)
	w.add_news("Chiến tranh %s – %s kết thúc (%s). %s bồi thường %d lượng; đình chiến %d tháng." % [w.nation_name(a), w.nation_name(b), why, w.nation_name(loser), roundi(pay), TRUCE_MONTHS], [], "chien_su")
	w.count("peace")
