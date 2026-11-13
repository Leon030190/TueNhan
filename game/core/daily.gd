class_name Daily
extends RefCounted



const MEDITATE_MAX: = 2
const COURT_CHAT_MAX: = 2
const DEED_MAX: = 2
const OBS_HINT_P: = 0.3
const DEEDS: = {
	"xu_an": {"name": "Giúp quan xử án", "stat": Defs.TRI, "desc": "Lấy Trí lực gỡ một vụ án rối ở nha môn."}, 
	"dep_cuop": {"name": "Dẹp cướp quanh thành", "stat": Defs.VO, "desc": "Cùng dân binh đánh toán cướp quanh thành; có thưởng, có rủi ro."}, 
	"chua_benh": {"name": "Chữa bệnh cho dân", "stat": Defs.TRI, "desc": "Mở lều chữa bệnh miễn phí (cần thầy thuốc theo hầu, hoặc thành có Y quán)."}, 
}


static func _count(w: World, key: String) -> int:
	var d: Dictionary = w.play.get("daily", {})
	return int(d.get(key, 0)) if int(d.get("m", -1)) == w.m else 0


static func _bump(w: World, key: String) -> void :
	if not w.play.has("daily") or int(w.play["daily"].get("m", -1)) != w.m:
		w.play["daily"] = {"m": w.m}
	w.play["daily"][key] = _count(w, key) + 1




static func observe_block(w: World, c: Character) -> String:
	if c == null or not c.alive or c.is_player:
		return "Không có ai để quan sát."
	if c.city_id != PlayerOps.here(w):
		return "Phải ở cùng thành với %s." % c.name
	if not w.notebook.has(c.id) or int(w.notebook[c.id].get("met_m", -99)) < 0:
		return "Phải Gặp gỡ %s trước." % c.name
	if _unobserved(w, c).is_empty():
		return "Đã quan sát kỹ mọi mặt của %s." % c.name
	return ""


static func _unobserved(w: World, c: Character) -> Array:
	var obs: Dictionary = w.notebook.get(c.id, {}).get("obs", {})
	var res: Array = []
	for i in Defs.N_STATS + 1:
		if not obs.has(str(i)):
			res.append(i)
	return res



static func _observe_one(w: World, c: Character, seed_key: String) -> String:
	var left: = _unobserved(w, c)
	if left.is_empty():
		return ""
	var r: = w.rng(["observe", c.id, seed_key])
	var i: = int(left[r.randi_range(0, left.size() - 1)])
	var tri: = float(w.player().real[Defs.TRI])
	var half: = maxf(3.0, 10.0 - tri / 12.0)
	var val: = c.mi_real if i == Defs.N_STATS else c.shown_real(i)
	var band: = Appraisal.band(w, c, "obs", i, 0, val, half)
	var n: = PlayerOps.note(w, c.id)
	if not n.has("obs"):
		n["obs"] = {}
	n["obs"][str(i)] = band
	var nm: String = "Mị lực" if i == Defs.N_STATS else Defs.STAT_NAMES[i]
	var t: = "%s khoảng %d–%d" % [nm, int(band[0]), int(band[1])]
	if r.randf() < OBS_HINT_P + tri / 200.0:
		var hint: = _hint(w, c, r)
		if hint != "":
			if not n.has("hints"):
				n["hints"] = []
			if not (n["hints"] as Array).has(hint):
				(n["hints"] as Array).append(hint)
				t += ". Nghe được: \"%s\"" % hint
	return t


static func _hint(w: World, c: Character, r: RandomNumberGenerator) -> String:
	var opts: Array = []
	if c.ngo >= 4:
		opts.append("học gì cũng nhanh hơn người")
	elif c.ngo <= 1:
		opts.append("hàng xóm bảo chậm hiểu")
	opts.append("hình như có khiếu về %s" % Defs.STAT_NAMES[c.top_pot()].to_lower())
	if not c.traits.is_empty():
		opts.append("tính tình có vẻ %s" % GameData.trait_name(str(c.traits[r.randi_range(0, c.traits.size() - 1)])).to_lower())
	if c.has_disguise():
		opts.append("tiếng đồn với người thật có chỗ không khớp")
	return str(opts[r.randi_range(0, opts.size() - 1)])


static func observe(w: World, id: String) -> Dictionary:
	var c: = w.ch(id)
	var err: = observe_block(w, c)
	if err != "":
		return PlayerOps._fail(err)
	PlayerOps._spend(w, PlayerOps.act_days(w, "observe"))
	var seq: = int(w.play.get("obs_seq", 0))
	w.play["obs_seq"] = seq + 1
	var t: = "Quan sát kỹ %s hai ngày: %s." % [c.name, _observe_one(w, c, str(seq))]
	PlayerOps.log_line(w, t)
	return PlayerOps._ok(t)


static func chat_block(w: World, c: Character) -> String:
	if c == null or not c.alive or c.is_player:
		return "Không có ai để đàm đạo."
	if PlayerOps.is_retainer(w, c):
		return "Môn khách đã ở trong nhà."
	if c.city_id != PlayerOps.here(w):
		return "Phải ở cùng thành với %s." % c.name
	if not w.notebook.has(c.id) or int(w.notebook[c.id].get("met_m", -99)) < 0:
		return "Phải Gặp gỡ %s trước." % c.name
	if int(w.notebook[c.id].get("chat_m", -99)) == w.m:
		return "Đã đàm đạo với %s tháng này." % c.name
	return ""


static func chat(w: World, id: String) -> Dictionary:
	var c: = w.ch(id)
	var err: = chat_block(w, c)
	if err != "":
		return PlayerOps._fail(err)
	PlayerOps._spend(w, PlayerOps.act_days(w, "chat"))
	var n: = PlayerOps.note(w, id)
	n["chat_m"] = w.m
	n["met_m"] = w.m
	n["met_t"] = PlayerOps.now(w)
	var gain: = minf(2.0 + PlayerOps.charm(w) / 50.0, maxf(0.0, PlayerOps.VISIT_CAP - c.favor))
	c.favor += gain
	var t: = "Uống trà, đánh cờ với %s: ân tình +%.0f." % [c.name, gain]
	var seen: = _observe_one(w, c, "chat%d" % w.m)
	if seen != "":
		t += " Trò chuyện cũng thấy được: %s." % seen
	PlayerOps.log_line(w, t)
	return PlayerOps._ok(t)




static func meditate_block(w: World) -> String:
	if _count(w, "med") >= MEDITATE_MAX:
		return "Đã tĩnh tâm %d lần tháng này." % MEDITATE_MAX
	if int(w.play["eye"]) >= int(w.play["eye_max"]):
		return "Nhãn lực đang đầy."
	return ""


static func meditate_gain(w: World) -> int:
	var cid: = PlayerOps.here(w)
	return 2 if w.has_feature(cid, "hoc_phu") or PlayerOps.capital_nations(w).size() > 0 else 1


static func meditate(w: World) -> Dictionary:
	var err: = meditate_block(w)
	if err != "":
		return PlayerOps._fail(err)
	PlayerOps._spend(w, PlayerOps.act_days(w, "meditate"))
	_bump(w, "med")
	var g: = mini(meditate_gain(w), int(w.play["eye_max"]) - int(w.play["eye"]))
	w.play["eye"] = int(w.play["eye"]) + g
	var t: = "Tĩnh tâm bốn ngày, mắt nhìn người sáng lại: Nhãn lực +%d." % g
	PlayerOps.log_line(w, t)
	return PlayerOps._ok(t)


static func teahouse(w: World) -> Dictionary:
	PlayerOps._spend(w, PlayerOps.act_days(w, "teahouse"))
	var cid: = PlayerOps.here(w)
	var seq: = int(w.play.get("tea_seq", 0))
	w.play["tea_seq"] = seq + 1
	var r: = w.rng(["tea", seq])
	var parts: Array = []
	if r.randf() < 0.6:
		var existing: Array = []
		for l in w.play["leads"]:
			existing.append(str(l["id"]))
		var cands: Array = []
		for c: Character in w.living():
			if c.is_player or c.city_id != cid or c.office_key != "" or PlayerOps.is_retainer(w, c) or c.patron != "":
				continue
			if w.notebook.has(c.id) or existing.has(c.id) or c.age(w.m) < 14:
				continue
			cands.append(c)
		if not cands.is_empty():
			var c: Character = cands[r.randi_range(0, cands.size() - 1)]
			(w.play["leads"] as Array).append({"id": c.id, "city": cid, "m": w.m, "text": PlayerOps._lead_text(w, c, r)})
			parts.append("nghe được một lời đồn về người trong thành (tab Tại đây)")
	if r.randf() < 0.35:
		var unknown: Array = []
		for rid in w.rivals:
			var rv: Dictionary = w.rivals[rid]
			if not Rivals.is_fallen(rv) and not bool(rv.get("met", false)):
				unknown.append(rid)
		if not unknown.is_empty():
			var rv2: Dictionary = w.rivals[str(unknown[r.randi_range(0, unknown.size() - 1)])]
			rv2["met"] = true
			parts.append("nghe người ta bàn tán về %s, biết họ là hạng nhà nào (tab Thế gia)" % rv2["name"])
	var t: = "Ngồi trà quán hai ngày: %s." % (", ".join(parts) if not parts.is_empty() else "toàn chuyện phiếm, chẳng nghe được gì đáng giá")
	PlayerOps.log_line(w, t)
	return PlayerOps._ok(t)




const JOBS: = [
	[Defs.TRI, "dạy học, viết thuê"], [Defs.VO, "áp tiêu, gác thuê"], [Defs.SX, "làm công ở xưởng"], 
	[Defs.THUONG, "làm thuê cho hiệu buôn"], [-1, "hát xướng, làm mối"], 
]


static func job_of(w: World) -> Array:
	var p: = w.player()
	var best: Array = JOBS[0]
	var bv: = -1.0
	for j in JOBS:
		var v: = p.mi_real if int(j[0]) < 0 else float(p.real[int(j[0])])
		if v > bv:
			bv = v
			best = j
	return [best, bv]


static func job_pay(w: World) -> int:
	var kt: = float(w.cities[PlayerOps.here(w)]["kinh_te"])
	return roundi((20.0 + float(job_of(w)[1]) * 1.2) * kt / 60.0)


static func odd_job(w: World) -> Dictionary:
	PlayerOps._spend(w, PlayerOps.act_days(w, "odd_job"))
	var jb: Array = job_of(w)
	var pay: = job_pay(w)
	w.clan["money"] = PlayerOps.money(w) + float(pay)
	var t: = "Làm thuê năm ngày (%s): kiếm được %d lượng." % [jb[0][1], pay]
	if int(jb[0][0]) == Defs.VO and w.rng(["job_hurt", w.m, PlayerOps.day(w)]).randf() < 0.1:
		w.player().health = maxf(1.0, w.player().health - 10.0)
		t += " Đụng độ với bọn trộm, bị thương nhẹ (Sức khỏe −10)."
	if PlayerOps.clan_tier(w) >= 2:
		w.clan["prestige"] = maxf(0.0, PlayerOps.prestige(w) - 2.0)
		t += " Người ta xì xào gia chủ thế gia mà đi làm thuê (Danh vọng −2)."
	PlayerOps.log_line(w, t)
	return PlayerOps._ok(t)




static func court_chat_block(w: World) -> String:
	if PlayerOps.capital_nations(w).is_empty():
		return "Phải ở kinh đô: %s." % PlayerOps.capitals_text(w)
	if _count(w, "court") >= COURT_CHAT_MAX:
		return "Đã hầu chuyện %d lần tháng này." % COURT_CHAT_MAX
	return ""


static func court_chat(w: World) -> Dictionary:
	var err: = court_chat_block(w)
	if err != "":
		return PlayerOps._fail(err)
	PlayerOps._spend(w, PlayerOps.act_days(w, "court_chat"))
	_bump(w, "court")
	var nid: = str(PlayerOps.capital_nations(w)[0])
	w.play["influence"][nid] = float(w.play["influence"].get(nid, 0.0)) + 1.0
	var t: = "Ngồi hầu chuyện, đánh cờ với mấy vị quan ở %s: Ảnh hưởng +1." % w.nation_name(nid)
	PlayerOps.log_line(w, t)
	return PlayerOps._ok(t)




static func deed_block(w: World, kind: String) -> String:
	if _count(w, "deed") >= DEED_MAX:
		return "Đã làm %d việc nghĩa tháng này." % DEED_MAX
	if kind == "chua_benh" and not Rivals._has_healer(w):
		return "Cần thầy thuốc theo hầu (nghề Thầy thuốc / thiên phú Y thuật), hoặc thành có Y quán."
	return ""


static func deed_chance(w: World, kind: String) -> float:
	match kind:
		"dep_cuop":
			return clampf(PlayerOps.guard_power(w) / 80.0, 0.15, 0.95)
		"xu_an":
			return clampf(float(w.player().real[Defs.TRI]) / 70.0, 0.2, 0.95)
	return 0.9


static func good_deed(w: World, kind: String) -> Dictionary:
	var err: = deed_block(w, kind)
	if err != "":
		return PlayerOps._fail(err)
	PlayerOps._spend(w, PlayerOps.act_days(w, "deed"))
	_bump(w, "deed")
	var city: Dictionary = w.cities[PlayerOps.here(w)]
	var ok: = w.rng(["deed", kind, w.m, PlayerOps.day(w)]).randf() < deed_chance(w, kind)
	var t: = ""
	match kind:
		"xu_an":
			if ok:
				var g: = 2.0 + float(w.player().real[Defs.TRI]) / 40.0
				w.clan["prestige"] = PlayerOps.prestige(w) + g
				t = "Bạn giúp nha môn gỡ được vụ án rối: dân trong thành ca ngợi (Danh vọng +%.0f)." % g
			else:
				t = "Bạn xem hồ sơ vụ án mấy ngày mà không tìm ra manh mối."
		"dep_cuop":
			if ok:
				w.clan["prestige"] = PlayerOps.prestige(w) + 3.0
				w.clan["money"] = PlayerOps.money(w) + 60.0
				city["an_ninh"] = minf(100.0, float(city.get("an_ninh", 50)) + 2.0)
				t = "Toán cướp quanh thành bị dẹp: thưởng 60 lượng, Danh vọng +3, an ninh thành +2."
			else:
				w.player().health = maxf(1.0, w.player().health - 15.0)
				t = "Đánh cướp không thành, bạn bị thương (Sức khỏe −15)."
		"chua_benh":
			w.clan["prestige"] = PlayerOps.prestige(w) + 3.0
			city["an_ninh"] = minf(100.0, float(city.get("an_ninh", 50)) + 1.0)
			t = "Mở lều chữa bệnh cho dân nghèo: Danh vọng +3."
	PlayerOps.log_line(w, t)
	return PlayerOps._ok(t)




static func tutor_block(w: World, c: Character) -> String:
	if c == null or not PlayerOps.is_retainer(w, c):
		return "Chỉ chỉ dạy môn khách."
	if not PlayerOps.with_me(w, c):
		return "%s phải đang ở cùng bạn." % c.name
	if int(w.notebook.get(c.id, {}).get("tutor_m", -99)) == w.m:
		return "Đã chỉ dạy %s tháng này." % c.name
	if float(PlayerOps.mentor_effect(w, w.player(), c)["mult"]) <= 1.0:
		return "Bạn không giỏi hơn %s ở chỉ số họ đang rèn." % c.name
	return ""


static func tutor(w: World, id: String) -> Dictionary:
	var c: = w.ch(id)
	var err: = tutor_block(w, c)
	if err != "":
		return PlayerOps._fail(err)
	PlayerOps._spend(w, PlayerOps.act_days(w, "tutor"))
	PlayerOps.note(w, id)["tutor_m"] = w.m
	var eff: = PlayerOps.mentor_effect(w, w.player(), c)
	c.mentor_stat = int(eff["stat"])
	c.mentor_mult = float(eff["mult"])
	c.mentor_m = maxi(c.mentor_m, 2)
	c.loyalty = minf(100.0, c.loyalty + 3.0)
	var t: = "Bạn tự tay chỉ dạy %s về %s (hiệu quả %s, 2 tháng): Trung thành +3." % [c.name, Defs.STAT_NAMES[int(eff["stat"])], eff["word"]]
	PlayerOps.log_line(w, t)
	return PlayerOps._ok(t)
