class_name Exam
extends RefCounted








const KINDS: = {
	"khoa_cu": {"name": "Khoa cử", "s": [Defs.TRI, Defs.CHINH], "feat": "hoc_phu", "prof": "thu_sinh", "won": "tan_khoa", 
		"titles": ["Trạng nguyên", "Bảng nhãn", "Thám hoa"], "rest": "Tiến sĩ"}, 
	"vo_cu": {"name": "Võ cử", "s": [Defs.VO, Defs.QUAN], "feat": "vo_duong", "prof": "vo_sinh", "won": "vo_cu_nhan", 
		"titles": ["Võ trạng nguyên", "Võ bảng nhãn", "Võ thám hoa"], "rest": "Võ tiến sĩ"}, 
}
const HUONG_PASS: = 0.4
const HUONG_MIN: = 18.0
const HOI_TOP: = 10
const HOI_MIN: = 22.0
const HOI_DAY: = 14
const DINH_DAY: = 24
const FAME: = [25.0, 18.0, 12.0, 6.0]
const PRESTIGE: = [15.0, 10.0, 8.0, 4.0]
const OFFICE_BONUS: = [15.0, 12.0, 10.0, 6.0]
const AGE_MIN: = 16
const AGE_MAX: = 40
const STAGE_NAMES: = ["chưa thi", "đỗ Thi Hương", "đỗ Thi Hội", "đỗ Thi Đình"]



static func kind_of_year(y: int) -> String:
	if (y - 1) % 4 == 0:
		return "khoa_cu"
	if (y - 3) % 4 == 0:
		return "vo_cu"
	return ""


static func season(w: World) -> Dictionary:
	if w.play.is_empty():
		return {}
	var s: Dictionary = w.play.get("exam_season", {})
	if s.is_empty() or int(s["y"]) != w.year():
		return {}
	return s



static func active(w: World) -> bool:
	var s: = season(w)
	return not s.is_empty() and w.month() <= 3


static func stage_label(w: World) -> String:
	var s: = season(w)
	if s.is_empty():
		return ""
	var d: = PlayerOps.day(w)
	match w.month():
		1:
			return "Yết bảng: tháng 2 thi Hương"
		2:
			return "Thi Hương (tháng 2, xét cuối tháng)"
		3:
			if not bool(s.get("hoi_done", false)):
				return "Sĩ tử tụ ở kinh thành · Thi Hội ngày 15"
			if not bool(s.get("dinh_done", false)):
				return "Thi Đình ngày 25"
			return "Đã yết bảng vàng"
	return ""


static func exam_cities(w: World, nid: String, kind: String) -> Array:
	var cap: = str(w.nations[nid]["capital"])
	var res: Array = [cap]
	var others: Array = w.nation_cities(nid).filter( func(x: String) -> bool: return x != cap and w.has_feature(x, str(KINDS[kind]["feat"])))
	var key: = "giao_duc" if kind == "khoa_cu" else "quan_su"
	others.sort_custom( func(a: String, b: String) -> bool: return float(w.cities[a].get(key, 0)) > float(w.cities[b].get(key, 0)))
	res.append_array(others.slice(0, 2))
	return res


static func _nearest(w: World, from: String, cities: Array) -> String:
	var best: = str(cities[0])
	var bd: = 99999
	for cid in cities:
		var d: = PlayerOps.path_days(w, from, str(cid)) if from != str(cid) else 0
		if d < bd:
			bd = d
			best = str(cid)
	return best



static func score(w: World, c: Character, kind: String, stage: int) -> float:
	var ss: Array = KINDS[kind]["s"]
	var v: = (float(c.real[int(ss[0])]) + float(c.real[int(ss[1])])) / 2.0 + float(c.ngo - 3) * 2.0
	v += w.rng(["exam_score", c.id, w.year(), stage]).randf_range(-6.0, 6.0)
	if stage == 3:
		v = v * 0.7 + Items.eff_mi(c) * 0.3
	return v




static func tick(w: World) -> void :
	if w.play.is_empty():
		return
	var mo: = w.month()
	if mo == 12 and kind_of_year(w.year() + 1) != "":
		_announce(w, kind_of_year(w.year() + 1), w.year() + 1)
		return
	if mo == 1 and season(w).is_empty() and kind_of_year(w.year()) != "":
		_announce(w, kind_of_year(w.year()), w.year())
	var s: = season(w)
	if s.is_empty():
		return
	match mo:
		1:
			_gather(w, s)
		2:
			_resolve_huong(w, s)
		3:
			if not bool(s.get("hoi_done", false)):
				_resolve_hoi(w, s)
			if not bool(s.get("dinh_done", false)):
				_resolve_dinh(w, s)
			_go_home(w, s)



static func day_tick(w: World) -> void :
	var s: = season(w)
	if s.is_empty() or w.month() != 3:
		return
	if PlayerOps.day(w) >= HOI_DAY and not bool(s.get("hoi_done", false)):
		_resolve_hoi(w, s)
	if PlayerOps.day(w) >= DINH_DAY and not bool(s.get("dinh_done", false)):
		_resolve_dinh(w, s)


static func _announce(w: World, kind: String, year: int) -> void :
	var s: = {"y": year, "kind": kind, "nat": {}, "p": {"st": 0, "nid": "", "reg": 0}}
	var kd: Dictionary = KINDS[kind]
	for nid in w.nations:
		var cities: = w.nation_cities(nid)
		s["nat"][nid] = {"cities": exam_cities(w, nid, kind), "c": {}}
		var n: = clampi(cities.size() * 3, 8, 20)
		for k in n:
			if w.living().size() >= Sim.MAX_ALIVE:
				break
			var r: = w.rng(["si_tu", nid, w.year(), k])
			var cid: = str(cities[r.randi_range(0, cities.size() - 1)])
			var c: = WorldGen.new_commoner(w, cid, r.randi_range(AGE_MIN, 30))
			c.set_profession(str(kd["prof"]))
			for i in kd["s"]:
				c.real[int(i)] = maxf(float(c.real[int(i)]), float(c.pot[int(i)]) * r.randf_range(0.45, 0.7))
			c.add_log(w.m, "Lều chõng chuẩn bị đi thi")
	w.play["exam_season"] = s
	w.add_news("Triều đình các nước yết bảng mở %s năm %d: tháng 2 thi Hương ở kinh đô và các thành lớn, tháng 3 thi Hội, thi Đình ở kinh thành." % [kd["name"], year], [], "quoc_gia")



static func _gather(w: World, s: Dictionary) -> void :
	for nid in s["nat"]:
		if not w.nations.has(nid):
			continue
		var ns: Dictionary = s["nat"][nid]
		var cities: = w.nation_cities(nid)
		for c: Character in w.living():
			if c.is_player or c.nation_id != "" or c.clan_retainer or c.patron != "" or not c.crisis.is_empty():
				continue
			if not cities.has(c.city_id) or c.age(w.m) < AGE_MIN or c.age(w.m) > AGE_MAX:
				continue
			if not _fit(c, str(s["kind"])):
				continue
			var to: = _nearest(w, c.city_id, ns["cities"])
			ns["c"][c.id] = {"home": c.city_id, "st": 0, "at": to}
			c.city_id = to



static func _fit(c: Character, kind: String) -> bool:
	var kd: Dictionary = KINDS[kind]
	if c.profession == str(kd["prof"]) or ProfTree.has_tree(c.profession) and c.profession == str(kd["prof"]):
		return true
	var ss: Array = kd["s"]
	return (float(c.real[int(ss[0])]) + float(c.real[int(ss[1])])) / 2.0 >= 20.0



static func _retainers_at(w: World, cid: String) -> Array:
	return PlayerOps.retainers(w).filter( func(x: Character) -> bool: return PlayerOps.exam_flag(w, x.id) and not PlayerOps.on_road(w, x) and PlayerOps.task_city(w, x) == cid and x.age(w.m) >= AGE_MIN and x.age(w.m) <= AGE_MAX)


static func _entry(s: Dictionary, nid: String, c: Character) -> Dictionary:
	var ns: Dictionary = s["nat"][nid]
	if not ns["c"].has(c.id):
		ns["c"][c.id] = {"home": c.city_id, "st": 0, "at": c.city_id, "ret": true}
	return ns["c"][c.id]


static func _resolve_huong(w: World, s: Dictionary) -> void :
	var kind: = str(s["kind"])
	var kd: Dictionary = KINDS[kind]
	for nid in s["nat"]:
		if not w.nations.has(nid):
			continue
		var ns: Dictionary = s["nat"][nid]
		var passed: = 0
		for ec in ns["cities"]:
			var group: Array = []
			for id in ns["c"]:
				var c: = w.ch(str(id))
				if c != null and c.alive and str(ns["c"][id]["at"]) == str(ec) and c.city_id == str(ec):
					group.append(c)
			for rc: Character in _retainers_at(w, str(ec)):
				if not group.has(rc):
					_entry(s, nid, rc)["at"] = str(ec)
					group.append(rc)
			var p: = w.player()
			var pst: Dictionary = s["p"]
			if int(pst["reg"]) == 1 and str(pst["nid"]) == nid and p.city_id == str(ec):
				group.append(p)
			group.sort_custom( func(a: Character, b: Character) -> bool: return score(w, a, kind, 1) > score(w, b, kind, 1))
			var n: = ceili(group.size() * HUONG_PASS)
			for k in group.size():
				var c: Character = group[k]
				var ok: = k < n and score(w, c, kind, 1) >= HUONG_MIN
				_publish(w, c, kind)
				if c.is_player:
					pst["st"] = 1 if ok else 0
					pst["reg"] = 0
					PlayerOps.report(w, ("Bạn đỗ Thi Hương ở %s! Tháng 3 lên kinh %s dự Thi Hội (trước ngày 15)." % [w.city_name(str(ec)), w.city_name(str(w.nations[nid]["capital"]))]) if ok else "Bạn trượt Thi Hương ở %s." % w.city_name(str(ec)))
					continue
				var e: Dictionary = ns["c"][c.id]
				if ok:
					e["st"] = 1
					passed += 1
					c.add_log(w.m, "Đỗ Thi Hương (%s)" % kd["name"])
					if not c.clan_retainer:
						c.city_id = str(w.nations[nid]["capital"])
					else:
						PlayerOps.report(w, "%s đỗ Thi Hương: tháng 3 phải có mặt ở %s trước ngày 15 để thi Hội." % [c.name, w.city_name(str(w.nations[nid]["capital"]))])
				else:
					_unmask_fraud(w, c, "trượt Thi Hương")
					if c.clan_retainer:
						PlayerOps.report(w, "%s trượt Thi Hương." % c.name)
					else:
						c.city_id = str(e["home"])
		if passed > 0:
			w.add_news("%s %s: %d sĩ tử đỗ Thi Hương, tháng 3 tụ về %s." % [kd["name"], w.nation_name(nid), passed, w.city_name(str(w.nations[nid]["capital"]))], [], "quoc_gia")


static func _resolve_hoi(w: World, s: Dictionary) -> void :
	s["hoi_done"] = true
	var kind: = str(s["kind"])
	var kd: Dictionary = KINDS[kind]
	for nid in s["nat"]:
		if not w.nations.has(nid):
			continue
		var ns: Dictionary = s["nat"][nid]
		var cap: = str(w.nations[nid]["capital"])
		var group: Array = []
		for id in ns["c"]:
			var c: = w.ch(str(id))
			if c == null or not c.alive or int(ns["c"][id]["st"]) != 1:
				continue
			if c.clan_retainer and PlayerOps.task_city(w, c) != cap:
				PlayerOps.report(w, "%s đỗ Thi Hương nhưng không có mặt ở %s ngày thi Hội: bỏ lỡ khoa thi." % [c.name, w.city_name(cap)])
				ns["c"][id]["st"] = 0
				continue
			group.append(c)
		var pst: Dictionary = s["p"]
		if int(pst["reg"]) == 2 and str(pst["nid"]) == nid:
			group.append(w.player())
		group.sort_custom( func(a: Character, b: Character) -> bool: return score(w, a, kind, 2) > score(w, b, kind, 2))
		for k in group.size():
			var c: Character = group[k]
			var ok: = k < HOI_TOP and score(w, c, kind, 2) >= HOI_MIN
			_publish(w, c, kind)
			if c.is_player:
				pst["st"] = 2 if ok else 1
				pst["reg"] = 0
				PlayerOps.report(w, "Bạn đỗ Thi Hội! Ngày 25 vào Thi Đình ứng đối." if ok else "Bạn trượt Thi Hội.")
				continue
			if ok:
				ns["c"][c.id]["st"] = 2
				c.add_log(w.m, "Đỗ Thi Hội (%s)" % kd["name"])
				if c.has_disguise() and not Repute.inflated(c):
					c.disguise_mul = []
					c.disguise_add = []
					c.concealment = 0.0
					c.add_log(w.m, "Đỗ cao ở trường thi, tài thật lộ ra")
			else:
				_unmask_fraud(w, c, "trượt Thi Hội")


static func _resolve_dinh(w: World, s: Dictionary) -> void :
	if not bool(s.get("hoi_done", false)):
		_resolve_hoi(w, s)
	s["dinh_done"] = true
	var kind: = str(s["kind"])
	var kd: Dictionary = KINDS[kind]
	for nid in s["nat"]:
		if not w.nations.has(nid):
			continue
		var ns: Dictionary = s["nat"][nid]
		var cap: = str(w.nations[nid]["capital"])
		var group: Array = []
		for id in ns["c"]:
			var c: = w.ch(str(id))
			if c != null and c.alive and int(ns["c"][id]["st"]) == 2 and ( not c.clan_retainer or PlayerOps.task_city(w, c) == cap):
				group.append(c)
		var pst: Dictionary = s["p"]
		if int(pst["reg"]) == 3 and str(pst["nid"]) == nid:
			group.append(w.player())
		if group.is_empty():
			continue
		group.sort_custom( func(a: Character, b: Character) -> bool: return score(w, a, kind, 3) > score(w, b, kind, 3))
		var names: Array = []
		var ids: Array = []
		for k in group.size():
			var c: Character = group[k]
			var rk: = mini(k, 3)
			var title: = str(kd["titles"][k]) if k < 3 else str(kd["rest"])
			c.fame = minf(100.0, c.fame + float(FAME[rk]))
			if k < 3:
				names.append("%s %s" % [title, c.name])
				ids.append(c.id)
			if c.is_player:
				pst["st"] = 3
				pst["reg"] = 0
				w.clan["prestige"] = PlayerOps.prestige(w) + float(PRESTIGE[rk])
				w.play["influence"][nid] = float(w.play["influence"].get(nid, 0.0)) + 5.0
				w.play["exam_title"] = {"title": title, "nid": nid, "bonus": float(OFFICE_BONUS[rk]), "until": w.m + 36}
				c.add_log(w.m, "Đỗ %s kỳ %s của %s" % [title, kd["name"], w.nation_name(nid)])
				PlayerOps.report(w, "Bạn đỗ %s! Danh tiếng +%d, Danh vọng +%d, Ảnh hưởng +5; 3 năm tới xin chức ở %s được cộng %d điểm." % [title, roundi(float(FAME[rk])), roundi(float(PRESTIGE[rk])), w.nation_name(nid), roundi(float(OFFICE_BONUS[rk]))])
				continue
			ns["c"][c.id]["st"] = 3
			c.add_log(w.m, "Đỗ %s kỳ %s của %s" % [title, kd["name"], w.nation_name(nid)])
			if c.clan_retainer:
				PlayerOps.choice_court_invite(w, c, nid, "%s kỳ %s" % [title, kd["name"]])
			else:
				c.nation_id = nid
				c.city_id = cap
				c.set_profession(str(kd["won"]))
		if not names.is_empty():
			var more: = group.size() - 3
			w.add_news("Bảng vàng %s %s năm %d: %s%s." % [kd["name"], w.nation_name(nid), w.year(), ", ".join(names), (" (cùng %d %s)" % [more, str(kd["rest"]).to_lower()]) if more > 0 else ""], ids, "quoc_gia")



static func _go_home(w: World, s: Dictionary) -> void :
	for nid in s["nat"]:
		var ns: Dictionary = s["nat"][nid]
		for id in ns["c"]:
			var c: = w.ch(str(id))
			var e: Dictionary = ns["c"][id]
			if c != null and c.alive and not c.clan_retainer and c.nation_id == "" and int(e["st"]) < 3:
				c.city_id = str(e["home"])
				if w.notebook.has(c.id):
					PlayerOps.note(w, c.id)["exam_home"] = str(e["home"])



static func _unmask_fraud(w: World, c: Character, why: String) -> void :
	if c.is_player or not Repute.inflated(c):
		return
	c.disguise_mul = []
	c.disguise_add = []
	if c.special == "hu_danh":
		c.special = ""
	c.fame = maxf(0.0, c.fame - 10.0)
	c.add_log(w.m, "Lộ thực học: %s" % why)



static func _publish(w: World, c: Character, kind: String) -> void :
	if c.is_player or not w.notebook.has(c.id) or int(w.notebook[c.id].get("met_m", -99)) < 0:
		return
	var n: = PlayerOps.note(w, c.id)
	if not n.has("obs"):
		n["obs"] = {}
	for i in KINDS[kind]["s"]:
		n["obs"][str(i)] = Appraisal.band(w, c, "exam", int(i), 0, c.shown_real(int(i)) if not Repute.inflated(c) else float(c.real[int(i)]), 4.0)





static func player_next(w: World) -> Array:
	var s: = season(w)
	if s.is_empty():
		return [0, "Năm nay không có khoa thi."]
	var p: = w.player()
	var pst: Dictionary = s["p"]
	if p.office_key != "":
		return [0, "Đang làm quan thì không đi thi."]
	if p.age(w.m) < AGE_MIN or p.age(w.m) > AGE_MAX:
		return [0, "Chỉ người %d–%d tuổi được dự thi." % [AGE_MIN, AGE_MAX]]
	var nid: = w.city_nation(p.city_id)
	var st: = int(pst["st"])
	if int(pst["reg"]) > 0:
		return [0, "Đã vào trường thi, chờ kết quả."]
	match w.month():
		1:
			return [0, "Tháng 2 mới thi Hương."]
		2:
			if st > 0:
				return [0, "Đã đỗ Thi Hương."]
			if not s["nat"].has(nid) or not (s["nat"][nid]["cities"] as Array).has(p.city_id):
				return [1, "Phải ở một thành thi Hương: %s." % _city_list(w, s)]
			return [1, ""]
		3:
			if str(pst["nid"]) != "" and nid != str(pst["nid"]):
				return [0, "Phải thi tiếp ở nước đã thi Hương."]
			if st == 1 and not bool(s.get("hoi_done", false)):
				return [2, "" if p.city_id == str(w.nations[nid]["capital"]) else "Phải ở kinh thành %s." % w.city_name(str(w.nations[nid]["capital"]))]
			if st == 2 and not bool(s.get("dinh_done", false)):
				return [3, "" if p.city_id == str(w.nations[nid]["capital"]) else "Phải ở kinh thành."]
			return [0, "Không còn vòng thi nào cho bạn kỳ này."]
	return [0, "Mùa thi đã qua."]


static func _city_list(w: World, s: Dictionary) -> String:
	var names: Array = []
	for nid in s["nat"]:
		for cid in s["nat"][nid]["cities"]:
			names.append(w.city_name(str(cid)))
	return ", ".join(names)


const STAGE_DAYS: = [0, 5, 5, 2]
const STAGE_NAME: = ["", "Thi Hương", "Thi Hội", "Thi Đình"]


static func enter(w: World) -> Dictionary:
	var nx: = player_next(w)
	if int(nx[0]) == 0 or str(nx[1]) != "":
		return PlayerOps._fail(str(nx[1]))
	var s: = season(w)
	var stage: = int(nx[0])
	var pst: Dictionary = s["p"]
	pst["reg"] = stage
	pst["nid"] = w.city_nation(w.player().city_id)
	var t: = "Bạn vào trường %s (%d ngày)." % [STAGE_NAME[stage], STAGE_DAYS[stage]]
	if stage == 1:
		t += " Kết quả yết cuối tháng 2."
	PlayerOps._spend(w, STAGE_DAYS[stage])
	PlayerOps.log_line(w, t)
	return PlayerOps._ok(t)



static func candidates_here(w: World) -> Array:
	var s: = season(w)
	var res: Array = []
	if s.is_empty():
		return res
	var cid: = PlayerOps.here(w)
	for nid in s["nat"]:
		for id in s["nat"][nid]["c"]:
			var c: = w.ch(str(id))
			if c != null and c.alive and c.city_id == cid and not c.clan_retainer:
				res.append([c, s["nat"][nid]["c"][id]])
	return res
