class_name Endings
extends RefCounted



const NAMES: = {
	"nguoi_dung_sau": "Người đứng sau thiên hạ", 
	"thay_trieu": "Thay triều đổi đại", 
	"ngoai_bang": "Ngoại bang xưng đế", 
	"thong_nhat": "Thiên hạ quy về một mối", 
}
const DESCS: = {
	"nguoi_dung_sau": "Không ngồi ngai vàng, nhưng phần lớn ghế chủ chốt khắp thiên hạ đều là người do bạn đưa lên, và họ vẫn nhớ ơn bạn.", 
	"thay_trieu": "Triều cũ sụp đổ. Người ngồi trên ngai vàng nay là người của bạn.", 
	"ngoai_bang": "Một nước láng giềng thống nhất thiên hạ, và triều đình của họ đầy những người do bạn tiến cử.", 
	"thong_nhat": "Muôn nước quy về một mối dưới cờ bản quốc.", 
}
const SHADOW_SHARE: = 0.6
const SHADOW_MONTHS: = 12
const COUP_COST: = 1000


static func key_offices(w: World, nid: String) -> Array:
	var res: Array = []
	for key in w.nations[nid]["offices"]:
		var od: Dictionary = Defs.OFFICES[Appointment.office_of_key(key)]
		if not bool(od.get("per_city", false)) and float(od["weight"]) >= 1.5:
			res.append(key)
	return res


static func _mine(w: World, c: Character) -> bool:
	if c != null and c.is_player and c.alive:
		return true
	if c != null and c.alive and Rivals.backer(c) != "" and bool(w.rivals.get(Rivals.backer(c), {}).get("kin", false)):
		return true
	return c != null and c.alive and c.recommender != "" and c.recommender == w.player_id and c.favor >= 50.0



static func share(w: World, nid: String = "") -> Array:
	var mine: = 0
	var total: = 0
	for n in w.nations:
		if nid != "" and n != nid:
			continue
		for key in key_offices(w, n):
			total += 1
			if _mine(w, w.office_holder(n, key)):
				mine += 1
	return [mine, total]



static func check(w: World) -> String:
	var p: = w.player()
	if str(w.play.get("ending", "")) != "":
		return str(w.play["ending"])
	if w.nations.size() == 1:
		var only: String = w.nations.keys()[0]
		if only == p.nation_id and only == str(w.play.get("home", only)):
			return "thong_nhat"
		var sh: = share(w, only)
		if int(sh[1]) > 0 and float(sh[0]) / float(sh[1]) >= 0.5:
			return "ngoai_bang"
	var all: = share(w)
	if int(all[1]) > 0 and float(all[0]) / float(all[1]) >= SHADOW_SHARE:
		w.play["shadow_m"] = int(w.play.get("shadow_m", 0)) + 1
		if int(w.play["shadow_m"]) >= SHADOW_MONTHS:
			return "nguoi_dung_sau"
	else:
		w.play["shadow_m"] = 0
	for nid in w.nations:
		var rid: = str(w.nations[nid].get("ruler_id", ""))
		if rid != "" and _mine(w, w.ch(rid)):
			return "thay_trieu"
	return ""



static func progress(w: World) -> Array:
	var res: Array = []
	var all: = share(w)
	res.append({"id": "nguoi_dung_sau", "text": "Người của bạn (còn ân tình ≥ 50) nắm %d / %d ghế chủ chốt khắp thiên hạ; cần ≥ %d%% liên tục %d tháng (đã giữ %d tháng)." % [
		int(all[0]), int(all[1]), roundi(SHADOW_SHARE * 100.0), SHADOW_MONTHS, int(w.play.get("shadow_m", 0))]})
	var cond: = coup_conditions(w)
	var met: = 0
	for c in cond:
		if bool(c["ok"]):
			met += 1
	res.append({"id": "thay_trieu", "text": "Chính biến: đạt %d / %d điều kiện. Hoặc một người của bạn tự lên ngôi khi triều đình loạn." % [met, cond.size()]})
	res.append({"id": "ngoai_bang", "text": "Một nước khác thống nhất thiên hạ, và ≥ 50% ghế chủ chốt của nước đó là người của bạn."})
	res.append({"id": "thong_nhat", "text": "Bản quốc chiếm hết thiên hạ (hiện còn %d nước)." % w.nations.size()})
	return res




static func coup_conditions(w: World) -> Array:
	var p: = w.player()
	var nid: = p.nation_id
	var has_nat: = w.nations.has(nid)
	var general: = false
	if has_nat:
		for key in ["dai_tuong#0", "binh_bo#0"]:
			var c: = w.office_holder(nid, key)
			if c != null and c.recommender == p.id and c.favor >= 60.0:
				general = true
	return [
		{"text": "Gia tộc từ Thế gia trở lên", "ok": PlayerOps.clan_tier(w) >= 2}, 
		{"text": "Ảnh hưởng với triều đình bản quốc ≥ 50", "ok": float(w.play["influence"].get(nid, 0.0)) >= 50.0}, 
		{"text": "Người của bạn (ân tình ≥ 60) nắm Đại tướng quân hoặc Binh bộ", "ok": general}, 
		{"text": "Có %d lượng" % COUP_COST, "ok": PlayerOps.money(w) >= COUP_COST}, 
		{"text": "Đang đứng ở kinh đô bản quốc", "ok": has_nat and PlayerOps.here(w) == str(w.nations[nid]["capital"])}, 
	]


static func coup_chance(w: World) -> float:
	var p: = w.player()
	if not w.nations.has(p.nation_id):
		return 0.0
	var ch: = 0.3 + 0.08 * PlayerOps.network(w, p.nation_id)
	if float(w.nations[p.nation_id]["stability"]) < 40.0:
		ch += 0.2
	ch += PlayerOps.troop_coup_bonus(w)
	return clampf(ch, 0.0, 0.85)



static func coup_death_chance(w: World) -> float:
	return 0.3 * clampf(1.0 - PlayerOps.guard_power(w) / 150.0, 0.3, 1.0)


static func coup_ready(w: World) -> bool:
	for c in coup_conditions(w):
		if not bool(c["ok"]):
			return false
	return true


static func coup(w: World) -> Dictionary:
	if not coup_ready(w):
		return {"ok": false, "msg": "Chưa đủ điều kiện phát động chính biến."}
	var p: = w.player()
	var nid: = p.nation_id
	PlayerOps._spend(w, PlayerOps.act_days(w, "coup"))
	w.clan["money"] = PlayerOps.money(w) - COUP_COST
	var r: = w.rng(["coup"])
	if r.randf() < coup_chance(w):
		var nat: Dictionary = w.nations[nid]
		var old: = str(nat.get("ruler", ""))
		nat["ruler"] = "%s (%s)" % [w.clan["name"], p.name]
		nat["ruler_id"] = p.id
		w.play["ending"] = "thay_trieu"
		w.play["over"] = "ending"
		var t: = "Chính biến thành công! %s phế truất %s, %s nắm quyền %s." % [w.clan["name"], old, p.name, w.nation_name(nid)]
		w.add_news(t, [p.id], "quoc_gia")
		PlayerOps.log_line(w, t)
		PlayerOps._settle()
		return {"ok": true, "msg": t, "success": true}

	for key in w.nations[nid]["offices"]:
		var c: = w.office_holder(nid, key)
		if c != null and c.recommender == p.id:
			Appointment.vacate(w, c, "bị thanh trừng sau chính biến thất bại")
	w.clan["prestige"] = maxf(0.0, PlayerOps.prestige(w) - 50.0)
	w.play["influence"][nid] = 0.0
	var t2: = "Chính biến thất bại! Người của %s trong triều bị thanh trừng." % w.clan["name"]
	if r.randf() < coup_death_chance(w):
		Life.die(w, p, "chính biến thất bại")
		t2 += " %s bị xử trảm." % p.name
		w.play["over"] = "death"
	w.add_news(t2, [p.id], "quoc_gia")
	PlayerOps.log_line(w, t2)
	PlayerOps._settle()
	return {"ok": true, "msg": t2, "success": false}
