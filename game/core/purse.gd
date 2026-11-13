class_name Purse
extends RefCounted







const SALARY_KEEP: = 0.6
const TRADE_CUT: = 0.1
const SKIM_RATE: = 0.2
const STEWARD_SKIM: = 10.0
const SKIM_START: = 0.15
const BUY_BUFFER: = 1.2
const GIFT_SHARE: = 0.3
const REWARDS: = [[50, 4.0], [150, 10.0], [400, 20.0]]
const LOAN_DAYS_M: = 6
const LOAN_MIN: = 50
const PICK_SHARE: = 0.5
const PICK_COOLDOWN: = 6


static func debts(w: World) -> Dictionary:
	if not w.play.has("debts"):
		w.play["debts"] = {}
	return w.play["debts"]


static func debt_of(w: World, id: String) -> Dictionary:
	return debts(w).get(id, {})



static func wish_kinds(c: Character) -> Array:
	if PlayerOps.is_martial(c):
		return ["binh_khi", "toa_ky", "y_phuc"]
	return ["y_phuc", "toa_ky", "binh_khi"]


static func month(w: World) -> void :
	var gift_month: = w.m % 12 == 0
	for c: Character in PlayerOps.retainers(w):
		var task: = PlayerOps.job_of(w, c)
		var working: = PlayerOps.task_pause(w, c) == ""
		var gain: = float(w.play["salary"].get(c.id, 0)) * SALARY_KEEP
		var notes: Array = ["lương %d" % roundi(gain)]
		var spent: = 0.0
		if task == "kinh_doanh" and working:
			var base: = maxf(0.0, c.role_score("thuong_nhan") - 20.0) * 1.2 * PlayerOps.trade_mult(c)
			var cut: = base * TRADE_CUT
			gain += cut
			notes.append("hoa hồng %d" % roundi(cut))
			if c.skim > 0.0:
				var sk: = base * c.skim
				gain += sk
				c.skimmed += sk
		if task == "quan_gia" and working and c.skim > 0.0:
			var sk2: = minf(STEWARD_SKIM, PlayerOps.money(w))
			w.clan["money"] = PlayerOps.money(w) - sk2
			gain += sk2
			c.skimmed += sk2
		c.purse += gain

		if c.skim <= 0.0 and c.has_trait("tham_tai") and c.loyalty < 70.0 and (task == "kinh_doanh" or task == "quan_gia")\
		and w.rng(["skim", c.id, w.m]).randf() < SKIM_START:
			c.skim = SKIM_RATE
		elif c.skim > 0.0 and c.loyalty >= 80.0:
			c.skim = 0.0

		if c.skimmed >= 30.0 and not PlayerOps._has_choice_for(w, c.id) and w.rng(["skim_find", c.id, w.m]).randf() < find_chance(w):
			PlayerOps.push_choice(w, "bien_thu", c.id, "Có người báo: %s đã lén biển thủ khoảng %d lượng tiền của gia tộc." % [c.name, roundi(c.skimmed)], 
				[["tha", "Tha, cảnh cáo", "Thôi biển thủ; Trung thành −3"], ["thu", "Thu lại tiền", "Lấy lại tới %d lượng; Trung thành −10" % roundi(minf(c.purse, c.skimmed))], 
				["duoi", "Đuổi đi", "%s rời gia tộc" % c.name]])

		for k in wish_kinds(c):
			var q: = Items.gear_q(c, str(k)) + 1
			if q > 3:
				continue
			var pr: = float(Items.price(str(k), q))
			if c.purse >= pr * BUY_BUFFER:
				var refund: = float(Items.sell_price(str(k), q - 1)) if q > 1 and bool(c.gear.get(k, {}).get("own", false)) else 0.0
				var it: = Items._new_item(w, str(k), q)
				if q > 1 and c.gear.has(k) and not bool(c.gear[k].get("own", false)) and Items.store(w).size() < Items.STORE_CAP:
					Items.store(w).append({"uid": int(c.gear[k]["uid"]), "k": str(k), "q": int(c.gear[k]["q"])})
				c.gear[k] = {"uid": int(it["uid"]), "q": q, "own": true}
				c.purse += refund - pr
				spent += pr - refund
				notes.append("sắm %s %d" % [Items.name_of(str(k), q), roundi(pr - refund)])
				PlayerOps.report(w, "%s dùng tiền riêng sắm %s (%d lượng)." % [c.name, Items.name_of(str(k), q), roundi(pr - refund)])
			break

		if gift_month and (c.loyalty >= 75.0 or c.has_trait("trung_hau")) and c.purse >= 100.0:
			var g: = floorf(c.purse * GIFT_SHARE)
			c.purse -= g
			spent += g
			w.clan["money"] = PlayerOps.money(w) + g
			notes.append("biếu Tết %d" % roundi(g))
			if g >= 100.0:
				w.clan["prestige"] = PlayerOps.prestige(w) + 1.0
			PlayerOps.report(w, "Tết đến, %s biếu gia chủ %d lượng tiền riêng%s." % [c.name, roundi(g), " (Danh vọng +1)" if g >= 100.0 else ""])

		var d: = debt_of(w, c.id)
		if not d.is_empty() and int(d["due"]) <= w.m:
			c.loyalty = maxf(0.0, c.loyalty - 3.0)
			if int(d["due"]) == w.m:
				PlayerOps.report(w, "Tới hạn mà chưa trả %s %d lượng đã vay: Trung thành giảm dần mỗi tháng." % [c.name, int(d["amt"])])
		c.purse_last = {"m": w.m, "in": roundi(gain), "out": roundi(spent), "notes": notes}



static func find_chance(w: World) -> float:
	var p: = 0.05
	for c: Character in PlayerOps.retainers(w):
		if str(w.play["tasks"].get(c.id, "")) == "mat_tham" and PlayerOps.task_pause(w, c) == "":
			p = maxf(p, 0.1 + (float(c.real[Defs.TRI]) + float(c.real[Defs.CHINH])) / 300.0)
	return clampf(p, 0.05, 0.7)


static func on_choice(w: World, c: Character, key: String) -> String:
	match key:
		"tha":
			c.skim = 0.0
			c.skimmed = 0.0
			c.loyalty = maxf(0.0, c.loyalty - 3.0)
			return "Tha cho %s, dặn không được tái phạm." % c.name
		"thu":
			var back: = floorf(minf(c.purse, c.skimmed))
			c.purse -= back
			w.clan["money"] = PlayerOps.money(w) + back
			c.skim = 0.0
			c.skimmed = 0.0
			c.loyalty = maxf(0.0, c.loyalty - 10.0)
			return "Thu lại %d lượng %s đã biển thủ (Trung thành −10)." % [roundi(back), c.name]
		"duoi":
			c.skim = 0.0
			c.skimmed = 0.0
			if PlayerOps.is_retainer(w, c):
				PlayerOps._release(w, c)
				Items.reclaim(w, c)
			return "Đuổi %s khỏi gia tộc vì tội biển thủ." % c.name
	return ""




static func reward_block(w: World, c: Character) -> String:
	if c == null or not PlayerOps.is_retainer(w, c):
		return "Chỉ ban thưởng cho môn khách."
	if int(w.notebook.get(c.id, {}).get("reward_m", -99)) == w.m:
		return "Đã ban thưởng %s tháng này." % c.name
	return ""


static func reward(w: World, id: String, tier: int) -> Dictionary:
	var c: = w.ch(id)
	var err: = reward_block(w, c)
	if err != "":
		return PlayerOps._fail(err)
	var amt: = float(REWARDS[tier][0])
	if PlayerOps.money(w) < amt:
		return PlayerOps._fail("Không đủ %d lượng." % roundi(amt))
	w.clan["money"] = PlayerOps.money(w) - amt
	c.purse += amt
	var gain: = float(REWARDS[tier][1]) * (1.5 if c.has_trait("tham_tai") else 1.0)
	c.loyalty = minf(100.0, c.loyalty + gain)
	PlayerOps.note(w, id)["reward_m"] = w.m
	var t: = "Ban thưởng %s %d lượng: Trung thành +%d." % [c.name, roundi(amt), roundi(gain)]
	PlayerOps.log_line(w, t)
	return PlayerOps._ok(t)


static func loan_amount(c: Character) -> int:
	return int(floorf(c.purse * 0.8 / 10.0) * 10.0)


static func borrow_block(w: World, c: Character) -> String:
	if c == null or not PlayerOps.is_retainer(w, c):
		return "Chỉ vay được môn khách."
	if not debt_of(w, c.id).is_empty():
		return "Còn nợ %s chưa trả." % c.name
	if loan_amount(c) < LOAN_MIN:
		return "Túi của %s không đủ cho vay (cần ≥ %d lượng)." % [c.name, ceili(LOAN_MIN / 0.8)]
	if c.loyalty < 50.0:
		return "%s chưa đủ tin bạn để cho vay (Trung thành < 50)." % c.name
	return ""


static func borrow(w: World, id: String) -> Dictionary:
	var c: = w.ch(id)
	var err: = borrow_block(w, c)
	if err != "":
		return PlayerOps._fail(err)
	var amt: = loan_amount(c)
	c.purse -= float(amt)
	w.clan["money"] = PlayerOps.money(w) + float(amt)
	debts(w)[id] = {"amt": amt, "due": w.m + LOAN_DAYS_M}
	var t: = "Vay %s %d lượng, hẹn trả trước %s." % [c.name, amt, World.date_of(w.m + LOAN_DAYS_M)]
	PlayerOps.log_line(w, t)
	return PlayerOps._ok(t)


static func repay(w: World, id: String) -> Dictionary:
	var c: = w.ch(id)
	var d: = debt_of(w, id)
	if c == null or d.is_empty():
		return PlayerOps._fail("Không nợ người này.")
	var amt: = float(d["amt"])
	if PlayerOps.money(w) < amt:
		return PlayerOps._fail("Không đủ %d lượng để trả." % roundi(amt))
	w.clan["money"] = PlayerOps.money(w) - amt
	c.purse += amt
	var on_time: = int(d["due"]) > w.m
	if on_time:
		c.loyalty = minf(100.0, c.loyalty + 3.0)
	debts(w).erase(id)
	var t: = "Trả %s %d lượng%s." % [c.name, roundi(amt), " đúng hẹn (Trung thành +3)" if on_time else ""]
	PlayerOps.log_line(w, t)
	return PlayerOps._ok(t)


static func pick_block(w: World, c: Character) -> String:
	if c == null or not PlayerOps.is_retainer(w, c):
		return "Chỉ với môn khách."
	if c.purse < 30.0:
		return "Túi của %s gần như rỗng." % c.name
	var last: = int(w.notebook.get(c.id, {}).get("pick_m", -99))
	if last + PICK_COOLDOWN > w.m:
		return "Vừa bày cớ thu tiền %s; đợi tới %s." % [c.name, World.date_of(last + PICK_COOLDOWN)]
	return ""



static func pick_risk(c: Character) -> float:
	return clampf(0.3 + float(c.real[Defs.TRI]) / 200.0, 0.3, 0.8)


static func pickpocket(w: World, id: String) -> Dictionary:
	var c: = w.ch(id)
	var err: = pick_block(w, c)
	if err != "":
		return PlayerOps._fail(err)
	var take: = floorf(c.purse * PICK_SHARE)
	c.purse -= take
	w.clan["money"] = PlayerOps.money(w) + take
	c.loyalty = maxf(0.0, c.loyalty - 20.0)
	PlayerOps.note(w, id)["pick_m"] = w.m
	var t: = "Bày cớ \"góp quỹ gia tộc\", thu của %s %d lượng (Trung thành −20)." % [c.name, roundi(take)]
	if w.rng(["pick", id, w.m]).randf() < pick_risk(c):
		for o: Character in PlayerOps.retainers(w):
			o.loyalty = maxf(0.0, o.loyalty - 5.0)
		w.clan["prestige"] = maxf(0.0, PlayerOps.prestige(w) - 3.0)
		t += " Chuyện vỡ lở: cả nhà môn khách mất lòng (Trung thành −5), Danh vọng −3."
	PlayerOps.log_line(w, t)
	return PlayerOps._ok(t)
