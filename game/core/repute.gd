class_name Repute
extends RefCounted








const SHOW_PRESTIGE: = 30.0
const EXPOSE_PRESTIGE: = 50.0
const VOUCH_PRESTIGE: = 70.0

const FAKE_GAP: = 8.0
const PLAIN_GAP: = 22.0
const SHAME_FAME: = 20.0
const EXPOSE_DAYS_KEY: = "expose"
const EXPOSE_COOLDOWN: = 12
const VOUCH_STAKE: = 15.0
const VOUCH_BONUS: = 12.0
const VOUCH_MONTHS: = 12
const VOUCH_MERIT: = 6.0
const SHOW_COST: = 200
const SHOW_COOLDOWN: = 12
const CASE_DAYS: = {"expose": [10, 15], "vu_cao": [10, 15], "to_giac": [15, 20]}
const OUTRANK_DAYS: = [6, 9]
const OUTRANK_BONUS: = 0.15
const BRIBE_BASE: = 0.15
const BRIBE_COST: = 150.0



static func outranks(w: World, c: Character) -> bool:
	var p: = w.player()
	if p.office_key == "" or c.office_key == "" or p.nation_id != c.nation_id:
		return false
	return Appointment.weight_of(p) > Appointment.weight_of(c)




static func cases(w: World) -> Array:
	if not w.play.has("cases"):
		w.play["cases"] = []
	return w.play["cases"]



static func open_case(w: World, data: Dictionary, fast: bool = false) -> int:
	var rng: Array = OUTRANK_DAYS if fast else CASE_DAYS[str(data["kind"])]
	var seq: = int(w.play.get("case_seq", 0))
	w.play["case_seq"] = seq + 1
	var days: = w.rng(["case_days", seq]).randi_range(int(rng[0]), int(rng[1]))
	data["due"] = PlayerOps.now(w) + days
	data["seq"] = seq
	cases(w).append(data)
	return days



static func process_cases(w: World) -> void :
	if w.play.is_empty() or not w.play.has("cases"):
		return
	for cs in cases(w).duplicate():
		if int(cs["due"]) > PlayerOps.now(w):
			continue
		cases(w).erase(cs)
		var t: = _resolve(w, cs)
		if t != "":
			PlayerOps.log_line(w, t)
			if not w.play.has("case_out"):
				w.play["case_out"] = []
			(w.play["case_out"] as Array).append({"title": str(cs.get("title", "Kết quả xét xử")), "t": t, "ok": bool(cs.get("good", false))})


static func take_results(w: World) -> Array:
	var res: Array = w.play.get("case_out", [])
	w.play["case_out"] = []
	return res


static func pending_for(w: World, id: String) -> Dictionary:
	for cs in cases(w):
		if str(cs.get("id", "")) == id:
			return cs
	return {}



static func _bribed(w: World, cs: Dictionary) -> bool:
	var rid: = str(cs.get("rid", ""))
	if rid == "" or not w.rivals.has(rid):
		return false
	var rv: Dictionary = w.rivals[rid]
	if Rivals.is_fallen(rv) or float(rv["money"]) < BRIBE_COST:
		return false
	var p: = BRIBE_BASE + minf(0.25, float(rv["money"]) / 4000.0) - (0.1 if bool(cs.get("fast", false)) else 0.0)
	if w.rng(["bribe", int(cs["seq"])]).randf() >= p:
		return false
	rv["money"] = float(rv["money"]) - BRIBE_COST
	return true


static func _resolve(w: World, cs: Dictionary) -> String:
	var c: = w.ch(str(cs.get("id", "")))
	var kind: = str(cs["kind"])
	if kind != "to_giac" and (c == null or not c.alive):
		return "Vụ xét %s khép lại: người bị tố không còn." % (c.name if c != null else "")
	var rname: = str(w.rivals[str(cs["rid"])]["name"]) if w.rivals.has(str(cs.get("rid", ""))) else ""
	if _bribed(w, cs):
		cs["good"] = false
		if kind == "expose":
			w.clan["prestige"] = maxf(0.0, PlayerOps.prestige(w) - 3.0)
		if kind == "to_giac" and w.rivals.has(str(cs["rid"])):
			w.rivals[str(cs["rid"])]["spy"] = 0
		return "Vụ xét %s bị ém nhẹm: nghe nói %s đã đút lót người xét án.%s" % [c.name if c != null else rname, rname if rname != "" else "có kẻ", " Danh vọng −3." if kind == "expose" else ""]
	match kind:
		"expose":
			return _resolve_expose(w, c, cs)
		"vu_cao":
			cs["good"] = bool(cs["ok"])
			if bool(cs["ok"]) and c.office_key != "":
				Events.framed_apply(w, c)
				return "Lời gièm pha thành: %s mất chức." % c.name
			return "Triều đình xét xong, không tin lời gièm pha về %s." % c.name
		"to_giac":
			cs["good"] = bool(cs["ok"])
			if not w.rivals.has(str(cs["rid"])):
				return ""
			var rv: Dictionary = w.rivals[str(cs["rid"])]
			if bool(cs["ok"]) and not Rivals.is_fallen(rv):
				rv["blame"] = true
				Rivals.confiscate(w, rv, "bị %s tố giác mưu phản" % w.clan["name"])
				return "Triều đình xét thấy chứng cứ: %s bị kết tội mưu phản, tịch biên cả nhà." % rv["name"]
			rv["spy"] = 0
			return "Triều đình bác lời tố giác %s; nội gián của bạn cũng bị lộ." % rv["name"]
	return ""



static func gap(w: World, c: Character) -> float:
	if c.office_key == "":
		return 0.0
	var oid: = Appointment.office_id_of(c)
	return Appraisal.perceived_office_score(w, c, oid) - c.office_score(oid)


static func inflated(c: Character) -> bool:
	if not c.has_disguise():
		return false
	for x in c.disguise_add:
		if float(x) > 0.0:
			return true
	return false




static func tick(w: World) -> void :
	for nid in w.nations:
		var offices: Dictionary = w.nations[nid]["offices"]
		for key in offices.keys():
			var c: = w.office_holder(nid, str(key))
			if c == null or c.is_player:
				continue
			var g: = gap(w, c)
			var th: = FAKE_GAP if inflated(c) else PLAIN_GAP
			if g <= th:
				continue
			var p: = minf(0.2, (g - th) / 150.0 + float(c.office_months) * 0.002)
			if w.rng(["lo_tai", c.id, w.m]).randf() < p:
				disgrace(w, c, g, "làm việc kém cỏi, lộ ra là kẻ bất tài", "")
	_vouch_check(w)
	Appointment.idle_tick(w)



static func disgrace(w: World, c: Character, g: float, why: String, by: String) -> void :
	var nid: = c.nation_id
	var label: = Appointment.office_label_of(w, c)
	var rid: = Rivals.backer(c)
	if inflated(c):
		c.disguise_mul = []
		c.disguise_add = []
	if c.special == "hu_danh":
		c.special = ""
	c.fame = maxf(0.0, c.fame - SHAME_FAME)
	c.add_log(w.m, "Bị cách chức %s: %s" % [label, why])
	Appointment.vacate(w, c, "bị cách chức vì bất tài")
	Appointment.shame(w, c)
	w.add_news("%s %s bị cách chức: %s%s." % [label, c.name, why, (" (" + by + " vạch trần)") if by != "" else ""], [c.id], "trieu_dinh")
	if c.recommender == w.player_id and by == "" and not w.play.is_empty():
		var lose: = clampf(g / 2.0, 5.0, 20.0)
		w.clan["prestige"] = maxf(0.0, PlayerOps.prestige(w) - lose)
		w.play["influence"][nid] = maxf(0.0, float(w.play["influence"].get(nid, 0.0)) - 10.0)
		PlayerOps.report(w, "%s do bạn tiến cử lộ bất tài, bị cách chức: Danh vọng −%d, Ảnh hưởng ở %s −10." % [c.name, roundi(lose), w.nation_name(nid)])
	if rid != "" and w.rivals.has(rid):
		var rv: Dictionary = w.rivals[rid]
		rv["prestige"] = maxf(0.0, float(rv["prestige"]) - 10.0)




static func expose_block(w: World, c: Character) -> String:
	if c == null or not c.alive or c.office_key == "":
		return "Chỉ vạch trần được người đang giữ chức."
	if c.recommender == w.player_id:
		return "Người do chính bạn tiến cử."
	if not pending_for(w, c.id).is_empty():
		return "Đang có vụ xét về %s." % c.name
	var high: = outranks(w, c)
	if not high and PlayerOps.prestige(w) < EXPOSE_PRESTIGE:
		return "Cần Danh vọng ≥ %d (hiện %d) thì lời bạn mới có trọng lượng." % [int(EXPOSE_PRESTIGE), roundi(PlayerOps.prestige(w))]
	var rec: Dictionary = w.notebook.get(c.id, {}).get("appr", {})
	if rec.is_empty() or int(rec["tier"]) < 2:
		return "Phải thẩm định %s từ tầng Trung cấp trở lên." % c.name
	if not high and PlayerOps.here(w) != str(w.nations[c.nation_id]["capital"]):
		return "Phải đứng ở kinh đô %s (%s)." % [w.nation_name(c.nation_id), w.city_name(str(w.nations[c.nation_id]["capital"]))]
	var last: = int(w.notebook[c.id].get("expose_m", -99))
	if last + EXPOSE_COOLDOWN > w.m:
		return "Vừa tâu về người này; đợi tới %s." % World.date_of(last + EXPOSE_COOLDOWN)
	return ""


static func _expose_p(w: World, c: Character, g: float, tier: int) -> float:
	if g < 8.0:
		return 0.03
	var infl: = float(w.play["influence"].get(c.nation_id, 0.0))
	return clampf(0.15 + (g - 8.0) / 30.0 + float(tier - 2) * 0.08 + infl / 300.0 + (OUTRANK_BONUS if outranks(w, c) else 0.0), 0.03, 0.9)



static func expose_estimate(w: World, c: Character) -> Dictionary:
	var rec: Dictionary = w.notebook.get(c.id, {}).get("appr", {})
	if rec.is_empty() or c.office_key == "":
		return {"gap": 0.0, "p": 0.0}
	var vals: Array = []
	for i in Defs.N_STATS:
		var b: Array = rec["real"][i]
		vals.append((float(b[0]) + float(b[1])) / 2.0 if not b.is_empty() else float(c.real[i]))
	var oid: = Appointment.office_id_of(c)
	var best: = 0.0
	for role in Defs.OFFICES[oid]["roles"]:
		best = maxf(best, c.role_score(role, vals))
	var g: = Appraisal.perceived_office_score(w, c, oid) - best
	return {"gap": g, "p": _expose_p(w, c, g, int(rec["tier"]))}



static func nominees(w: World) -> Array:
	return PlayerOps.retainers(w).filter( func(x: Character) -> bool: return x.age(w.m) >= 16 and x.crisis.is_empty())



static func nominee_chance(w: World, cand: Character, nid: String, key: String) -> float:
	var oid: = Appointment.office_of_key(key)
	var diff: = Appointment.weight_of(w.player()) - float(Defs.OFFICES[oid]["weight"])
	return clampf(0.35 + (Appointment.score(w, cand, nid, oid) - 45.0) / 60.0 + diff * 0.1, 0.1, 0.85)


static func expose(w: World, id: String, nominee: String = "") -> Dictionary:
	var c: = w.ch(id)
	var err: = expose_block(w, c)
	if err != "":
		return PlayerOps._fail(err)
	var high: = outranks(w, c)
	PlayerOps._spend(w, PlayerOps.act_days(w, EXPOSE_DAYS_KEY))
	var n: = PlayerOps.note(w, id)
	n["expose_m"] = w.m
	var g: = gap(w, c)
	var ok: = w.rng(["expose", id, w.m]).randf() < _expose_p(w, c, g, int(n["appr"]["tier"]))
	var parts: = c.office_key.split("/")
	var days: = open_case(w, {"kind": "expose", "id": id, "rid": Rivals.backer(c), "ok": ok, "g": g, "nid": c.nation_id, 
		"key": str(parts[1]) if parts.size() > 1 else "", "nominee": nominee, "fast": high, "title": "Kết quả vạch trần %s" % c.name}, high)
	var t: = "%s %s về %s. Triều đình giao người thẩm tra, khoảng %d ngày nữa có kết quả." % [
		"Bạn hặc tấu thẳng" if high else "Bạn dâng sớ vạch trần", c.name if nominee == "" else "%s, đề cử %s thay" % [c.name, w.ch(nominee).name], c.name, days]
	PlayerOps.log_line(w, t)
	return PlayerOps._ok(t)


static func _resolve_expose(w: World, c: Character, cs: Dictionary) -> String:
	var nid: = str(cs["nid"])
	var rid: = str(cs.get("rid", ""))
	var t: = ""
	if not bool(cs["ok"]):
		cs["good"] = false
		w.clan["prestige"] = maxf(0.0, PlayerOps.prestige(w) - 8.0)
		w.play["influence"][nid] = maxf(0.0, float(w.play["influence"].get(nid, 0.0)) - 5.0)
		if rid != "" and w.rivals.has(rid):
			Rivals.on_offended(w, rid, 10.0, "bạn tâu xấu %s" % c.name)
		return "Thẩm tra xong: %s làm việc không đến nỗi; bạn bị coi là vu khống. Danh vọng −8, Ảnh hưởng −5." % c.name
	if c.office_key == "":
		return "Thẩm tra xong thì %s đã rời chức từ trước." % c.name
	cs["good"] = true
	disgrace(w, c, float(cs["g"]), "bị vạch trần là kẻ bất tài", w.clan["name"])
	w.play["influence"][nid] = float(w.play["influence"].get(nid, 0.0)) + 10.0
	w.clan["prestige"] = PlayerOps.prestige(w) + 5.0
	PlayerOps._add_ngo(w, 5)
	t = "Thẩm tra xong: %s quả là kẻ bất tài, bị cách chức. Ảnh hưởng +10, Danh vọng +5, Ngộ đạo +5." % c.name
	if rid != "" and w.rivals.has(rid):
		Rivals.on_offended(w, rid, 20.0, "bạn vạch trần %s" % c.name)
		t += " %s mất mặt, thù bạn." % w.rivals[rid]["name"]
	var nm: = w.ch(str(cs.get("nominee", "")))
	var key: = str(cs.get("key", ""))
	if nm != null and nm.alive and key != "" and w.office_holder(nid, key) == null:
		if Appointment.snubbed(w, nm):
			t += " Đề cử %s bị gạt: các quan chê dung mạo, ăn nói." % nm.name
		elif w.rng(["nominee", int(cs["seq"])]).randf() < nominee_chance(w, nm, nid, key):
			PlayerOps._join_court(w, nm, nid, true)
			Appointment.appoint(w, nid, key, nm)
			nm.add_log(w.m, "Được %s đề cử làm %s" % [w.player().name, Appointment.office_label(w, nid, key)])
			t += " Đề cử của bạn được duyệt: %s nhậm chức %s." % [nm.name, Appointment.office_label(w, nid, key)]
		else:
			t += " Nhưng các quan không duyệt đề cử %s; ghế để triều đình tự chọn." % nm.name
	return t




static func vouch_block(w: World) -> String:
	if PlayerOps.prestige(w) < VOUCH_PRESTIGE:
		return "Cần Danh vọng ≥ %d (hiện %d) để bảo cử." % [int(VOUCH_PRESTIGE), roundi(PlayerOps.prestige(w))]
	return ""


static func vouches(w: World) -> Dictionary:
	if not w.play.has("vouch"):
		w.play["vouch"] = {}
	return w.play["vouch"]



static func start_vouch(w: World, c: Character) -> void :
	w.clan["prestige"] = maxf(0.0, PlayerOps.prestige(w) - VOUCH_STAKE)
	vouches(w)[c.id] = {"due": w.m + VOUCH_MONTHS, "m0": c.merit_total}
	c.add_log(w.m, "Được %s bảo cử" % w.clan["name"])


static func _vouch_check(w: World) -> void :
	if w.play.is_empty():
		return
	for id in vouches(w).keys():
		var v: Dictionary = vouches(w)[id]
		var c: = w.ch(str(id))
		if c == null or not c.alive:
			vouches(w).erase(id)
			continue
		if int(v["due"]) > w.m:
			continue
		vouches(w).erase(id)
		var gained: = c.merit_total - float(v["m0"])
		if gained >= VOUCH_MERIT:
			w.clan["prestige"] = PlayerOps.prestige(w) + VOUCH_STAKE * 2.0
			PlayerOps.report(w, "%s không phụ lời bảo cử (công lao năm đầu %d): Danh vọng +%d." % [c.name, roundi(gained), roundi(VOUCH_STAKE * 2.0)])
		else:
			PlayerOps.report(w, "%s làm không nổi như lời bạn bảo cử (công lao năm đầu %d): mất %d Danh vọng đã cược." % [c.name, roundi(gained), roundi(VOUCH_STAKE)])




static func show_block(w: World, c: Character) -> String:
	if c == null or not c.alive or c.is_player:
		return "Không có người để thi tài."
	if PlayerOps.prestige(w) < SHOW_PRESTIGE:
		return "Cần Danh vọng ≥ %d (hiện %d) mới mời được quan lại tới xem." % [int(SHOW_PRESTIGE), roundi(PlayerOps.prestige(w))]
	if PlayerOps.capital_nations(w).is_empty():
		return "Phải tổ chức ở kinh đô: %s." % PlayerOps.capitals_text(w)
	var ret: = PlayerOps.is_retainer(w, c)
	if ret and not PlayerOps.with_me(w, c):
		return "%s phải đang ở cùng bạn." % c.name
	if not ret and not PlayerOps.met_now(w, c):
		return "Phải đang gặp %s." % c.name
	var last: = int(w.notebook.get(c.id, {}).get("show_m", -99))
	if last + SHOW_COOLDOWN > w.m:
		return "Vừa thi tài; đợi tới %s." % World.date_of(last + SHOW_COOLDOWN)
	if PlayerOps.money(w) < float(SHOW_COST):
		return "Cần %d lượng." % SHOW_COST
	return ""


static func _best_seen(w: World, c: Character) -> float:
	var b: = 0.0
	for i in Defs.N_STATS:
		b = maxf(b, Appraisal.perceived_real(w, c, i))
	return b


static func showcase(w: World, id: String) -> Dictionary:
	var c: = w.ch(id)
	var err: = show_block(w, c)
	if err != "":
		return PlayerOps._fail(err)
	PlayerOps._spend(w, PlayerOps.act_days(w, "showcase"))
	w.clan["money"] = PlayerOps.money(w) - float(SHOW_COST)
	PlayerOps.note(w, id)["show_m"] = w.m
	var real_best: = c.max_real()
	var seen: = _best_seen(w, c)
	var t: = ""
	if real_best > seen + 3.0:
		var hidden: = c.has_disguise() and not inflated(c)
		if hidden:
			c.disguise_mul = []
			c.disguise_add = []
		c.concealment = 0.0
		var cleared: = Appointment.shamed(w, c)
		c.shame_until = -1
		var gain: = minf(30.0, 12.0 + (real_best - seen) / 2.0)
		c.fame = minf(100.0, c.fame + gain)
		w.clan["prestige"] = PlayerOps.prestige(w) + 3.0
		c.add_log(w.m, "Thi tài ở kinh đô, danh tiếng vang dội")
		w.add_news("%s trổ tài trước quan lại kinh thành, ai nấy kinh ngạc." % c.name, [c.id], "nhan_vat")
		t = "%s trổ tài trước quan lại: %striều đình nay thấy rõ tài thật. Danh tiếng +%d, Danh vọng +3.%s" % [c.name, "lớp ẩn tàng không còn, " if hidden else "", roundi(gain), " Tiếng xấu cũ được rửa sạch: triều đình dùng lại được." if cleared else ""]
	else:
		c.fame = minf(100.0, c.fame + 3.0)
		w.clan["prestige"] = maxf(0.0, PlayerOps.prestige(w) - 2.0)
		t = "%s thi tài nhưng chẳng có gì hơn lời đồn sẵn có: danh tiếng +3, bạn mất chút thể diện (Danh vọng −2)." % c.name
	PlayerOps.log_line(w, t)
	return PlayerOps._ok(t)
