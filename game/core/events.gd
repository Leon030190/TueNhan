class_name Events
extends RefCounted



const PERSONAL: = ["trong_thuong", "benh_nang", "cao_nhan", "bi_tich", "doi_thu", "mat_nguoi_than", "ham_hai"]
const CITY_EVENTS: = ["lu_lut", "han_han", "dich_benh", "thuong_lo"]
const GOOD_EVENTS: = ["cao_nhan", "bi_tich", "doi_thu"]
const RISKY_PROF: = ["binh_si", "vo_sinh", "kiem_khach", "vo_quan", "vo_cu_nhan"]
const RISKY_ENV: = ["quan_doanh", "chien_truong"]

const MAIM: = {
	"tay": {"name": "Tay phải bị phế", "main": 0, "real": [[0, 0.46]], "pot": [[0, 0.58], [2, 0.78]]}, 
	"chan": {"name": "Chân bị tật", "main": 0, "real": [[0, 0.6]], "pot": [[0, 0.7], [2, 0.9]]}, 
	"mat": {"name": "Hỏng một mắt", "main": 0, "real": [[0, 0.65], [2, 0.9]], "pot": [[0, 0.75], [2, 0.85]]}, 
}


static func p_of(ev: String) -> float:
	return float(GameData.event_def(ev).get("p", 0.0))


static func is_risky(c: Character) -> bool:
	return RISKY_PROF.has(c.profession) or RISKY_ENV.has(c.env)


static func tick(w: World) -> void :
	_fate(w)
	_personal(w)
	Exam.tick(w)
	_cities(w)
	_nations(w)
	_world(w)




static func fate_ok(c: Character, ev: String) -> bool:
	match ev:
		"trong_thuong":
			return is_risky(c)
		"cao_nhan":
			return not c.focus.is_empty()
		"bi_tich":
			return c.in_focus(Defs.VO) or c.in_focus(Defs.TRI)
		"doi_thu":
			return _focus_best_real(c) >= 45.0
	return true


static func _fate(w: World) -> void :
	for c: Character in w.chars.values():
		if not c.alive:
			continue
		for f in c.fate:
			if int(f["m"]) != w.m or str(f["st"]) != "cho":
				continue
			var ev: = str(f["ev"])
			if fate_ok(c, ev):
				f["st"] = "xay_ra"
				w.count("fate_hit")
				apply(w, c, ev, w.fate_rng(["fate_do", c.id, w.m]), true, f)
			else:
				f["st"] = "tranh"
				w.count("fate_averted")
				c.add_log(w.m, "Định mệnh lệch hướng: tránh được \"%s\"" % GameData.event_name(ev))
			if not c.alive:
				break




static func _personal(w: World) -> void :
	for c: Character in w.living():
		var r: = w.rng(["ev", c.id])
		var age: = c.age(w.m)
		for ev in PERSONAL:
			var p: = p_of(ev) * _mod(c, ev, age)
			if p > 0.0 and r.randf() < p:
				apply(w, c, ev, r, false, {})
				break


static func _mod(c: Character, ev: String, age: int) -> float:
	match ev:
		"trong_thuong":
			return 3.0 if is_risky(c) else 0.3
		"benh_nang":
			if age > 65:
				return 4.0
			return 2.0 if age > 50 else 1.0
		"cao_nhan", "bi_tich":
			var k: = 0.2 if c.focus.is_empty() else 1.0
			return k * (3.0 if c.has_talent("thien_menh") else 1.0)
		"doi_thu":
			if _focus_best_real(c) < 45.0:
				return 0.0
			return 3.0 if c.has_talent("thien_menh") else 1.0
		"ham_hai":
			return 1.0 if c.office_key != "" and not c.office_key.contains("thua_tuong") else 0.0
	return 1.0


static func apply(w: World, c: Character, ev: String, r: RandomNumberGenerator, fated: bool, f: Dictionary) -> void :
	w.count("ev:" + ev)
	match ev:
		"trong_thuong":
			injure(w, c, r, fated, str(f.get("sev", "")), str(f.get("part", "")), "")
		"benh_nang":
			_illness(w, c, r, fated)
		"cao_nhan":
			_master(w, c, r, fated)
		"bi_tich":
			_manual(w, c, r, fated)
		"doi_thu":
			_rival(w, c, r, fated)
		"mat_nguoi_than":
			_bereaved(w, c, r, fated)
		"ham_hai":
			_framed(w, c)


static func _tag(fated: bool) -> String:
	return "[Định mệnh] " if fated else ""


static func _focus_best_real(c: Character) -> float:
	var best: = 0.0
	for f in c.focus:
		best = maxf(best, float(c.real[int(f)]))
	return best


static func _focus_best_real_idx(c: Character) -> int:
	var b: = -1
	for f in c.focus:
		var i: = int(f)
		if b < 0 or float(c.real[i]) > float(c.real[b]):
			b = i
	return b if b >= 0 else c.top_real()



static func _path_stat(c: Character) -> int:
	var b: = -1
	for f in c.focus:
		var i: = int(f)
		if b < 0 or float(c.pot[i]) > float(c.pot[b]):
			b = i
	return b if b >= 0 else c.top_pot()


static func _raise_pot(c: Character, i: int, amount: float, cap: float) -> float:
	var cur: float = c.pot[i]
	var nv: = maxf(cur, minf(cap, cur + amount))
	c.pot[i] = nv
	return nv - cur


static func _temp_injury(c: Character, nm: String, months: int, red: Array) -> void :
	var rest: Array = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	for pr in red:
		var i: int = pr[0]
		var amt: = minf(float(c.real[i]), float(pr[1]))
		c.real[i] = float(c.real[i]) - amt
		rest[i] = amt
	c.injuries.append({"name": nm, "months": months, "restore": rest})


static func injure(w: World, c: Character, r: RandomNumberGenerator, fated: bool, sev: String, part: String, where: String) -> void :
	var resist: = 0.0
	if c.has_talent("bach_chien"):
		resist = 0.5
	elif c.has_talent("cuong_trang"):
		resist = 0.3
	if sev == "":
		var p_phe: = (0.35 if fated else 0.1) * (1.0 - resist)
		var p_nang: = 0.33 * (1.0 - resist)
		var x: = r.randf()
		if x < p_phe:
			sev = "phe"
		elif x < p_phe + p_nang:
			sev = "nang"
		else:
			sev = "nhe"
	match sev:
		"nhe":
			c.health -= 15.0
			_temp_injury(c, "Thương nhẹ", 4, [[Defs.VO, 4.0]])
			c.add_log(w.m, "%sBị thương nhẹ%s" % [_tag(fated), where])
		"nang":
			c.health -= 30.0
			_temp_injury(c, "Trọng thương", 10, [[Defs.VO, 8.0], [Defs.QUAN, 3.0]])
			c.set_mood("sa_sut", 4)
			c.add_log(w.m, "%sTrọng thương%s, cần 10 tháng hồi phục" % [_tag(fated), where])
			if c.fame >= 25.0 or fated:
				w.add_news("%s bị trọng thương%s." % [c.name, where], [c.id], "bien_co")
		"phe":
			if part == "":
				part = ["tay", "chan", "mat"][r.randi_range(0, 2)]
			var spec: Dictionary = MAIM[part]
			var lost: Array = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
			for pr in spec["pot"]:
				var i: int = pr[0]
				var before: float = c.pot[i]
				c.pot[i] = before * float(pr[1])
				if i == int(spec["main"]):
					lost[i] = before - float(c.pot[i])
			for rr in spec["real"]:
				var j: int = rr[0]
				c.real[j] = float(c.real[j]) * float(rr[1])
			for i in Defs.N_STATS:
				c.real[i] = minf(float(c.real[i]), float(c.pot[i]))
			c.injuries.append({"name": spec["name"], "months": -1})
			c.health -= 40.0
			c.add_log(w.m, "%s%s%s. Tiềm năng %s −%.0f" % [_tag(fated), spec["name"], where, Defs.STAT_NAMES[int(spec["main"])], float(lost[int(spec["main"])])])
			w.add_news("%s: %s%s." % [c.name, str(spec["name"]).to_lower(), where], [c.id], "bien_co")
			if c.health > 0.0:
				Crisis.start(w, c, lost, r, str(spec["name"]))
	if c.health <= 0.0:
		Life.die(w, c, "tử thương")


static func _illness(w: World, c: Character, r: RandomNumberGenerator, fated: bool) -> void :
	var age: = c.age(w.m)
	c.health -= r.randf_range(25.0, 45.0) + (10.0 if age > 60 else 0.0)
	c.set_mood("sa_sut", 3)
	var txt: = "Lâm bệnh nặng"
	if r.randf() < 0.15:
		c.pot[Defs.VO] = maxf(0.0, float(c.pot[Defs.VO]) - 8.0)
		c.real[Defs.VO] = minf(float(c.pot[Defs.VO]), maxf(0.0, float(c.real[Defs.VO]) - 5.0))
		txt += ", thể chất suy yếu (Tiềm năng Võ lực −8)"
	c.add_log(w.m, _tag(fated) + txt)
	if c.health <= 0.0:
		Life.die(w, c, "bệnh nặng")
	elif c.fame >= 40.0:
		w.add_news("%s lâm bệnh nặng." % c.name, [c.id], "bien_co")


static func _fortune_cap(c: Character, fated: bool) -> float:
	if c.has_talent("thien_menh"):
		return Defs.POT_HARD_CAP
	return Defs.POT_CAP + (10.0 if fated else 0.0)


static func _master(w: World, c: Character, r: RandomNumberGenerator, fated: bool) -> void :
	var i: = _path_stat(c)
	var g: = _raise_pot(c, i, r.randf_range(6.0, 12.0), _fortune_cap(c, fated))
	c.mentor_m = 24
	c.mentor_stat = i
	c.mentor_mult = Defs.MENTOR_MULT
	c.fame = minf(100.0, c.fame + 3.0)
	c.set_mood("phan_chan", 6)
	c.add_log(w.m, "%sĐược cao nhân truyền thụ %s: Tiềm năng +%.0f, được chỉ dạy 24 tháng" % [_tag(fated), Defs.STAT_NAMES[i], g])
	if fated or c.max_pot() >= 75.0:
		w.add_news("Có lời đồn %s ở %s được cao nhân để mắt tới." % [c.name, w.city_name(c.city_id)], [c.id], "co_duyen")


static func _manual(w: World, c: Character, r: RandomNumberGenerator, fated: bool) -> void :
	var i: = Defs.VO
	if not c.in_focus(Defs.VO) or (c.in_focus(Defs.TRI) and float(c.pot[Defs.TRI]) > float(c.pot[Defs.VO])):
		i = Defs.TRI
	if i == Defs.VO and r.randf() < 0.2:
		c.real[i] = maxf(0.0, float(c.real[i]) - 10.0)
		c.pot[i] = maxf(0.0, float(c.pot[i]) - 8.0)
		c.set_mood("suy_sup", 6)
		c.add_log(w.m, "%sLuyện bí tịch bị tẩu hỏa nhập ma: Võ lực −10, Tiềm năng −8" % _tag(fated))
		return
	var g: = _raise_pot(c, i, r.randf_range(5.0, 10.0), _fortune_cap(c, fated))
	c.real[i] = minf(float(c.pot[i]), float(c.real[i]) + 2.0)
	c.set_mood("phan_chan", 3)
	c.add_log(w.m, "%sTìm được bí tịch %s: Tiềm năng +%.0f" % [_tag(fated), Defs.STAT_NAMES[i], g])


static func _rival(w: World, c: Character, r: RandomNumberGenerator, fated: bool) -> void :
	var i: = _focus_best_real_idx(c)
	c.real[i] = minf(float(c.pot[i]), float(c.real[i]) + 3.0)
	var g: = _raise_pot(c, i, r.randf_range(3.0, 6.0), Defs.POT_CAP if not c.has_talent("thien_menh") else Defs.POT_HARD_CAP)
	c.fame = minf(100.0, c.fame + 5.0)
	c.add_log(w.m, "%sGặp đối thủ xứng tầm về %s: Thực +3, Tiềm năng +%.0f" % [_tag(fated), Defs.STAT_NAMES[i], g])


static func _bereaved(w: World, c: Character, r: RandomNumberGenerator, fated: bool) -> void :
	c.set_mood("suy_sup", r.randi_range(3, 6))
	if c.y_chi >= 70.0 and r.randf() < 0.5:
		var g: = _raise_pot(c, Defs.TRI, 3.0, c.pot_cap())
		c.add_log(w.m, "%sMất người thân, trưởng thành sau mất mát (Tiềm năng Trí lực +%.0f)" % [_tag(fated), g])
	elif c.y_chi < 35.0 and r.randf() < 0.4:
		var i: = _path_stat(c)
		c.pot[i] = maxf(float(c.real[i]), float(c.pot[i]) - 5.0)
		c.tham_vong = maxf(0.0, c.tham_vong - 10.0)
		c.add_log(w.m, "%sMất người thân, suy sụp và mất ý chí (Tiềm năng %s −5)" % [_tag(fated), Defs.STAT_NAMES[i]])
	else:
		c.add_log(w.m, "%sMất người thân" % _tag(fated))


static func _framed(w: World, c: Character) -> void :
	if not w.play.is_empty() and c.recommender != "" and c.recommender == w.player_id:
		PlayerOps.choice_framed(w, c)
		return
	framed_apply(w, c)


static func framed_apply(w: World, c: Character) -> void :
	var label: = Appointment.office_label_of(w, c)
	Appointment.vacate(w, c, "bị hãm hại")
	Appointment.shame(w, c)
	c.fame = maxf(0.0, c.fame - 10.0)
	c.loyalty = maxf(0.0, c.loyalty - 25.0)
	c.set_mood("sa_sut", 6)
	c.add_log(w.m, "Bị gièm pha hãm hại, mất chức %s" % label)




static func _exam(w: World, kind: String) -> void :
	var khoa: = kind == "khoa_cu"
	var s1: int = Defs.TRI if khoa else Defs.VO
	var s2: int = Defs.CHINH if khoa else Defs.QUAN
	var titles: Array = ["Trạng nguyên", "Bảng nhãn", "Thám hoa"] if khoa else ["Võ trạng nguyên", "Võ bảng nhãn", "Võ thám hoa"]
	var bonus: Array = [25.0, 18.0, 12.0]
	w.count("ev:" + kind)
	for nid in w.nations:
		var r: = w.rng(["exam", kind, nid])
		var cities: = w.nation_cities(nid)
		var cand: Array = []
		for c: Character in w.living():
			if c.is_player or c.nation_id != "" or not c.crisis.is_empty():
				continue
			if c.clan_retainer and not PlayerOps.exam_flag(w, c.id):
				continue
			if not cities.has(c.city_id):
				continue
			var age: = c.age(w.m)
			if age < 16 or age > 40:
				continue
			var s: = (Appraisal.perceived_real(w, c, s1) + Appraisal.perceived_real(w, c, s2)) / 2.0 + r.randf_range(-5.0, 5.0)
			cand.append([s, c])
		cand.sort_custom( func(a: Array, b: Array) -> bool: return float(a[0]) > float(b[0]))
		var winners: Array = []
		var ids: Array = []
		for k in mini(3, cand.size()):
			if float(cand[k][0]) < 45.0:
				break
			var c: Character = cand[k][1]
			c.fame = minf(100.0, c.fame + float(bonus[k]))
			c.add_log(w.m, "Đỗ %s kỳ %s của %s" % [titles[k], GameData.event_name(kind), w.nation_name(nid)])
			if c.clan_retainer:
				PlayerOps.choice_court_invite(w, c, nid, "%s kỳ %s" % [titles[k], GameData.event_name(kind)])
			else:
				c.nation_id = nid
				c.set_profession("tan_khoa" if khoa else "vo_cu_nhan")
			winners.append("%s %s" % [titles[k], c.name])
			ids.append(c.id)
		if not winners.is_empty():
			w.add_news("%s %s năm %d: %s." % [GameData.event_name(kind), w.nation_name(nid), w.year(), ", ".join(winners)], ids, "quoc_gia")




static func _cities(w: World) -> void :
	for cid in w.cities:
		var city: Dictionary = w.cities[cid]
		var r: = w.rng(["city", cid])
		for ev in CITY_EVENTS:
			if r.randf() >= p_of(ev):
				continue
			w.count("ev:" + ev)
			match ev:
				"lu_lut":
					city["sx"] = float(city["sx"]) - 8.0
					city["kinh_te"] = float(city["kinh_te"]) - 4.0
					city["pop"] = float(city["pop"]) * 0.97
				"han_han":
					city["sx"] = float(city["sx"]) - 10.0
					city["pop"] = float(city["pop"]) * 0.98
				"dich_benh":
					city["pop"] = float(city["pop"]) * 0.95
					for c: Character in w.living():
						if c.city_id == cid and r.randf() < 0.08:
							_illness(w, c, r, false)
				"thuong_lo":
					city["kinh_te"] = float(city["kinh_te"]) + 5.0
			for k in ["kinh_te", "sx"]:
				city[k] = clampf(float(city[k]), 5.0, 95.0)
			w.add_news("%s ở %s." % [GameData.event_name(ev), w.city_name(cid)], [], "thanh_tran")
			break




static func _nations(w: World) -> void :
	for nid in w.nations.keys():
		var r: = w.rng(["nat_ev", nid])
		if r.randf() < p_of("tranh_dau"):
			_faction_strife(w, nid, r)
		elif r.randf() < p_of("tich_bien"):
			_confiscation(w, nid, r)
		_unrest(w, nid, r)



static func _unrest(w: World, nid: String, r: RandomNumberGenerator) -> void :
	var nat: Dictionary = w.nations[nid]
	if float(nat["stability"]) >= 25.0:
		return
	var facs: Dictionary = nat["factions"]
	var weak: = ""
	var strong: = ""
	for fid in facs:
		if weak == "" or float(facs[fid]["power"]) < float(facs[weak]["power"]):
			weak = fid
		if strong == "" or float(facs[fid]["power"]) > float(facs[strong]["power"]):
			strong = fid
	if weak == strong:
		return
	var gen: = w.office_holder(nid, "dai_tuong#0")
	if str(facs[strong]["pref"]) == "military" and float(facs[strong]["power"]) >= 55.0 and gen != null and r.randf() < 0.04:
		var old: = str(nat.get("ruler", ""))
		nat["ruler"] = gen.name
		nat["ruler_id"] = gen.id
		gen.fame = minf(100.0, gen.fame + 30.0)
		gen.add_log(w.m, "Phát động binh biến, lên ngôi thay %s" % old)
		_purge(w, nid, weak, 3, r, "bị thanh trừng sau binh biến")
		nat["stability"] = minf(100.0, float(nat["stability"]) + 15.0)
		w.add_news("Binh biến ở %s! Đại tướng quân %s phế truất %s, tự lập làm vua." % [w.nation_name(nid), gen.name, old], [gen.id], "quoc_gia")
		w.count("binh_bien")
		if not w.play.is_empty() and gen.recommender == w.player_id:
			PlayerOps.report(w, "%s, người bạn tiến cử, đã lên ngôi ở %s!" % [gen.name, w.nation_name(nid)])
	elif r.randf() < 0.05:
		var n: = _purge(w, nid, weak, 3, r, "bị thanh trừng")
		if n > 0:
			nat["stability"] = minf(100.0, float(nat["stability"]) + 5.0)
			w.add_news("Thanh trừng ở %s: phe %s ra tay, %d quan phe %s mất chức." % [w.nation_name(nid), facs[strong]["name"], n, facs[weak]["name"]], [], "quoc_gia")
			w.count("thanh_trung")


static func _purge(w: World, nid: String, faction: String, max_n: int, r: RandomNumberGenerator, why: String) -> int:
	var vs: Array = []
	for c: Character in _holders(w, nid):
		if c.faction_id == faction and not c.office_key.contains("thua_tuong") and str(w.nations[nid].get("ruler_id", "")) != c.id:
			vs.append(c)
	var n: = 0
	while n < max_n and not vs.is_empty():
		var i: = r.randi_range(0, vs.size() - 1)
		var v: Character = vs[i]
		vs.remove_at(i)
		Appointment.vacate(w, v, why)
		v.loyalty = maxf(0.0, v.loyalty - 20.0)
		v.set_mood("sa_sut", 6)
		n += 1
	return n


static func _holders(w: World, nid: String) -> Array:
	var res: Array = []
	for key in w.nations[nid]["offices"]:
		var c: = w.office_holder(nid, key)
		if c != null:
			res.append(c)
	return res


static func _faction_strife(w: World, nid: String, r: RandomNumberGenerator) -> void :
	var facs: Dictionary = w.nations[nid]["factions"]
	var weak: = ""
	var strong: = ""
	for fid in facs:
		if weak == "" or float(facs[fid]["power"]) < float(facs[weak]["power"]):
			weak = fid
		if strong == "" or float(facs[fid]["power"]) > float(facs[strong]["power"]):
			strong = fid
	if weak == strong:
		return
	var victims: Array = []
	for c: Character in _holders(w, nid):
		if c.faction_id == weak and not c.office_key.contains("thua_tuong"):
			victims.append(c)
	w.count("ev:tranh_dau")
	if victims.is_empty():
		return
	var v: Character = Rng.pick(r, victims)
	Appointment.vacate(w, v, "thất thế trong tranh đấu phe phái")
	v.loyalty = maxf(0.0, v.loyalty - 15.0)
	v.set_mood("sa_sut", 6)
	w.add_news("Tranh đấu phe phái ở %s: phe %s lấn át phe %s, %s mất chức." % [w.nation_name(nid), facs[strong]["name"], facs[weak]["name"], v.name], [v.id], "quoc_gia")


static func _confiscation(w: World, nid: String, r: RandomNumberGenerator) -> void :
	var hs: = _holders(w, nid)
	if hs.is_empty():
		return
	var v: Character = Rng.pick(r, hs)
	w.count("ev:tich_bien")
	Appointment.vacate(w, v, "gia tộc bị tịch biên")
	v.nation_id = ""
	v.faction_id = ""
	v.fame = maxf(0.0, v.fame - 20.0)
	var lost: Array = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	var cut: = minf(10.0, float(v.pot[Defs.CHINH]))
	v.pot[Defs.CHINH] = float(v.pot[Defs.CHINH]) - cut
	v.real[Defs.CHINH] = minf(float(v.real[Defs.CHINH]), float(v.pot[Defs.CHINH]))
	lost[Defs.CHINH] = cut
	v.add_log(w.m, "Gia tộc bị tịch biên, con đường hoạn lộ đứt đoạn (Tiềm năng Chính trị −%.0f)" % cut)
	w.add_news("%s bị tịch biên gia sản, cả nhà sa cơ." % v.name, [v.id], "quoc_gia")
	Crisis.start(w, v, lost, r, "gia tộc bị tịch biên")




static func _world(w: World) -> void :
	for key in w.relations.keys():
		var parts: PackedStringArray = str(key).split("|")
		var r: = w.rng(["world", key])
		var rel: float = w.relations[key]
		if War.at_war(w, parts[0], parts[1]):
			continue
		if War.border_cities(w, parts[0], parts[1]).is_empty() and War.border_cities(w, parts[1], parts[0]).is_empty():
			continue
		var p: = p_of("xung_dot") if rel < -20.0 else 0.005
		if r.randf() < p:
			_skirmish(w, parts[0], parts[1], r)


static func _army(w: World, nid: String, r: RandomNumberGenerator) -> Array:
	var res: Array = []
	for key in w.nations[nid]["offices"]:
		var oid: = Appointment.office_of_key(key)
		if oid == "dai_tuong" or oid == "tuong_quan":
			var g: = w.office_holder(nid, key)
			if g != null:
				res.append(g)
	var border: Array = []
	for cid in w.nation_cities(nid):
		for other in w.cities[cid]["links"]:
			if w.city_nation(other) != nid and not border.has(cid):
				border.append(cid)
	var soldiers: Array = []
	for c: Character in w.living():
		if c.is_player or c.office_key != "" or not border.has(c.city_id):
			continue
		if c.nation_id != "" and c.nation_id != nid:
			continue
		var age: = c.age(w.m)
		if RISKY_PROF.has(c.profession) and age >= 16 and age <= 50:
			soldiers.append(c)
	for k in mini(3, soldiers.size()):
		var s: Character = soldiers[r.randi_range(0, soldiers.size() - 1)]
		if not res.has(s):
			res.append(s)
	return res


static func _skirmish(w: World, a: String, b: String, r: RandomNumberGenerator) -> void :
	w.count("ev:xung_dot")
	w.add_rel(a, b, - r.randf_range(6.0, 14.0))
	var sa: = NationSim.army_strength(w, a) * r.randf_range(0.85, 1.15)
	var sb: = NationSim.army_strength(w, b) * r.randf_range(0.85, 1.15)
	var win: = a if sa >= sb else b
	var lose: = b if win == a else a
	var nw: Dictionary = w.nations[win]
	var nl: Dictionary = w.nations[lose]
	nl["troops"] = float(nl["troops"]) * 0.97
	nl["stability"] = maxf(0.0, float(nl["stability"]) - 2.0)
	nw["troops"] = float(nw["troops"]) * 0.985
	nw["stability"] = minf(100.0, float(nw["stability"]) + 1.0)
	var where: = " ở biên giới %s – %s" % [w.nation_name(a), w.nation_name(b)]
	var ids: Array = []
	for nid in [a, b]:
		for c: Character in _army(w, nid, r):
			ids.append(c.id)
			c.battles += 1
			for i in [Defs.VO, Defs.QUAN]:
				c.real[i] = minf(float(c.pot[i]), float(c.real[i]) + r.randf_range(0.5, 2.0))
			if r.randf() < 0.012:
				c.add_log(w.m, "Tử trận" + where)
				Life.die(w, c, "tử trận")
				continue
			var inj_p: = 0.15 * (1.2 if c.has_trait("dung_cam") else 1.0)
			if r.randf() < inj_p:
				injure(w, c, r, false, "", "", where)
			else:
				c.add_log(w.m, "Tham chiến" + where)
	w.add_news("Giao tranh%s: %s thắng thế." % [where, w.nation_name(win)], ids, "chien_su")
