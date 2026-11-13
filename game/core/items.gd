class_name Items
extends RefCounted





const KINDS: = ["binh_khi", "y_phuc", "toa_ky"]
const KIND: = {
	"binh_khi": {"name": "Binh khí", "price": 120, "names": ["", "Đao sắt", "Kiếm tốt", "Bảo kiếm tinh xảo"]}, 
	"y_phuc": {"name": "Y phục", "price": 100, "names": ["", "Áo vải lành", "Áo gấm", "Cẩm bào tinh xảo"]}, 
	"toa_ky": {"name": "Tọa kỵ", "price": 160, "names": ["", "Ngựa thồ", "Tuấn mã", "Thiên lý mã"]}, 
}
const Q_NAMES: = ["", "Thường", "Tốt", "Tinh xảo"]
const Q_BONUS: = [0, 3, 6, 10]
const Q_PRICE: = [0.0, 1.0, 2.5, 6.0]
const HORSE_BANDIT: = [1.0, 0.8, 0.6, 0.4]
const STORE_CAP: = 6
const SELL_RATE: = 0.5
const CRAFT_MAT: = 0.6
const CRAFT_SPREAD: = 15.0
const Q_AT: = [0.0, 0.0, 50.0, 80.0]
const ITEM_GIFT: = [0.0, 5.0, 10.0, 16.0]
const MARKET_KT: = 60.0
const MARKET_KT_GOOD: = 70.0
const FEATURE_KIND: = {"mo_sat": "binh_khi", "xuong_lua": "y_phuc", "bai_ngua": "toa_ky"}
const FEATURE_CRAFT: = 15.0




static func store(w: World) -> Array:
	if not w.clan.has("items"):
		w.clan["items"] = []
	return w.clan["items"]


static func name_of(kind: String, q: int) -> String:
	return str(KIND[kind]["names"][q])


static func effect_text(kind: String, q: int) -> String:
	match kind:
		"binh_khi":
			return "+%d Võ lực" % int(Q_BONUS[q])
		"y_phuc":
			return "+%d Mị lực" % int(Q_BONUS[q])
	var s: = "cướp đường −%d%%" % roundi((1.0 - float(HORSE_BANDIT[q])) * 100.0)
	if q >= 1:
		s = "đi đường bộ nhanh hơn %d%% · " % roundi((1.0 - float(PlayerOps.HORSE_SPEED[q])) * 100.0) + s
	return s


static func price(kind: String, q: int) -> int:
	return roundi(float(KIND[kind]["price"]) * float(Q_PRICE[q]))


static func sell_price(kind: String, q: int) -> int:
	return roundi(price(kind, q) * SELL_RATE)


static func gear_q(c: Character, kind: String) -> int:
	if c == null or not c.gear.has(kind):
		return 0
	return int(c.gear[kind]["q"])


static func bonus(c: Character, kind: String) -> int:
	return int(Q_BONUS[gear_q(c, kind)])



static func eff_vo(c: Character) -> float:
	return minf(100.0, float(c.real[Defs.VO]) + bonus(c, "binh_khi"))



static func eff_mi(c: Character) -> float:
	return minf(100.0, c.mi_real + bonus(c, "y_phuc"))



static func gear_text(c: Character) -> String:
	var parts: Array = []
	for k in KINDS:
		var q: = gear_q(c, k)
		if q > 0:
			parts.append("%s (%s)" % [name_of(k, q), effect_text(k, q)])
	return " · ".join(parts)


static func _find(w: World, uid: int) -> int:
	var st: = store(w)
	for i in st.size():
		if int(st[i]["uid"]) == uid:
			return i
	return -1


static func _new_item(w: World, kind: String, q: int) -> Dictionary:
	var seq: = int(w.clan.get("item_seq", 0)) + 1
	w.clan["item_seq"] = seq
	return {"uid": seq, "k": kind, "q": q}


static func _ok(msg: String, extra: Dictionary = {}) -> Dictionary:
	var d: = {"ok": true, "msg": msg}
	d.merge(extra)
	return d


static func _fail(msg: String) -> Dictionary:
	return {"ok": false, "msg": msg}





static func specialty(w: World, cid: String) -> String:
	for f in FEATURE_KIND:
		if w.has_feature(cid, f):
			return str(FEATURE_KIND[f])
	return ""




static func market_q(w: World, kind: String = "") -> int:
	var cid: = PlayerOps.here(w)
	var kt: = float(w.cities[cid]["kinh_te"])
	var q: = 0
	if kt >= MARKET_KT_GOOD:
		q = 2
	elif kt >= MARKET_KT or w.has_feature(cid, "cang"):
		q = 1
	if kind != "" and specialty(w, cid) == kind:
		q = 2
	return q



static func has_market(w: World) -> bool:
	if market_q(w) > 0:
		return true
	return specialty(w, PlayerOps.here(w)) != ""


static func buy(w: World, kind: String, q: int) -> Dictionary:
	if not KIND.has(kind) or q < 1 or q > 3:
		return _fail("Món đồ không hợp lệ.")
	if q > market_q(w, kind):
		return _fail("Chợ %s không bán %s phẩm %s." % [w.city_name(PlayerOps.here(w)), str(KIND[kind]["name"]).to_lower(), Q_NAMES[q]])
	if store(w).size() >= STORE_CAP:
		return _fail("Kho đã đầy (%d món)." % STORE_CAP)
	var cost: = price(kind, q)
	if PlayerOps.money(w) < float(cost):
		return _fail("Cần %d lượng." % cost)
	w.clan["money"] = PlayerOps.money(w) - float(cost)
	store(w).append(_new_item(w, kind, q))
	var t: = "Mua %s (−%d lượng)." % [name_of(kind, q), cost]
	PlayerOps.log_line(w, t)
	return _ok(t)


static func sell(w: World, uid: int) -> Dictionary:
	var i: = _find(w, uid)
	if i < 0:
		return _fail("Không có món này trong kho.")
	if not has_market(w):
		return _fail("%s không có chợ lớn (cần Kinh tế ≥ %d hoặc bến cảng)." % [w.city_name(PlayerOps.here(w)), int(MARKET_KT)])
	var it: Dictionary = store(w)[i]
	var v: = sell_price(str(it["k"]), int(it["q"]))
	store(w).remove_at(i)
	w.clan["money"] = PlayerOps.money(w) + float(v)
	var t: = "Bán %s được %d lượng." % [name_of(str(it["k"]), int(it["q"])), v]
	PlayerOps.log_line(w, t)
	return _ok(t)






static func crafter(w: World, kind: String = "") -> Array:
	var p: = w.player()
	var best: Array = [float(p.real[Defs.SX]), "bạn"]
	for c: Character in PlayerOps.retainers(w):
		var skill: = float(c.real[Defs.SX]) + (10.0 if ProfTree.rank(c) >= 3 and (c.profession == "tho_ren" or c.profession == "tho_thu_cong") else 0.0)
		if PlayerOps.study_of(w, c) == "cong_xuong" and skill > float(best[0]):
			best = [skill, c.name]
	if kind != "" and specialty(w, PlayerOps.here(w)) == kind:
		best[0] = float(best[0]) + FEATURE_CRAFT
	return best



static func craft_odds(w: World, kind: String = "") -> Array:
	var s: = float(crafter(w, kind)[0])
	var span: = CRAFT_SPREAD * 2.0
	var p3: = clampf((s + CRAFT_SPREAD - float(Q_AT[3])) / span, 0.0, 1.0)
	var p2plus: = clampf((s + CRAFT_SPREAD - float(Q_AT[2])) / span, 0.0, 1.0)
	return [0.0, 1.0 - p2plus, p2plus - p3, p3]


static func crafts_left(w: World) -> int:
	var used: = int(w.play.get("craft_n", 0)) if int(w.play.get("craft_m", -1)) == w.m else 0
	return int(w.clan.get("workshops", 0)) - used


static func craft_cost(kind: String) -> int:
	return roundi(float(KIND[kind]["price"]) * CRAFT_MAT)


static func craft_block(w: World) -> String:
	if int(w.clan.get("workshops", 0)) <= 0:
		return "Cần có Xưởng (Mở xưởng trong hồ sơ Bản thân)."
	if crafts_left(w) <= 0:
		return "Mỗi xưởng chế tác 1 món mỗi tháng; tháng này đã hết."
	if store(w).size() >= STORE_CAP:
		return "Kho đã đầy (%d món)." % STORE_CAP
	return ""



static func craft(w: World, kind: String) -> Dictionary:
	if not KIND.has(kind):
		return _fail("Món đồ không hợp lệ.")
	var err: = craft_block(w)
	if err != "":
		return _fail(err)
	var cost: = craft_cost(kind)
	if PlayerOps.money(w) < float(cost):
		return _fail("Cần %d lượng nguyên liệu." % cost)
	PlayerOps._spend(w, PlayerOps.act_days(w, "craft"))
	w.clan["money"] = PlayerOps.money(w) - float(cost)
	var seq: = int(w.play.get("craft_seq", 0))
	w.play["craft_seq"] = seq + 1
	var cr: = crafter(w, kind)
	var roll: = float(cr[0]) + w.rng(["craft", seq]).randf_range( - CRAFT_SPREAD, CRAFT_SPREAD)
	var q: = 3 if roll >= float(Q_AT[3]) else (2 if roll >= float(Q_AT[2]) else 1)
	w.play["craft_n"] = (int(w.play.get("craft_n", 0)) if int(w.play.get("craft_m", -1)) == w.m else 0) + 1
	w.play["craft_m"] = w.m
	store(w).append(_new_item(w, kind, q))
	var t: = "Xưởng (%s cầm chính) làm ra %s, phẩm %s." % [cr[1], name_of(kind, q), Q_NAMES[q]]
	if q == 3:
		PlayerOps.report(w, t)
	PlayerOps.log_line(w, t)
	PlayerOps._settle()
	return _ok(t, {"q": q})




static func can_dress(w: World, c: Character) -> bool:
	return c != null and c.alive and (c.is_player or PlayerOps.is_retainer(w, c))



static func equip(w: World, uid: int, cid: String) -> Dictionary:
	var c: = w.ch(cid)
	if not can_dress(w, c):
		return _fail("Chỉ trang bị được cho bạn hoặc môn khách.")
	var i: = _find(w, uid)
	if i < 0:
		return _fail("Không có món này trong kho.")
	var it: Dictionary = store(w)[i]
	var kind: = str(it["k"])
	store(w).remove_at(i)
	if c.gear.has(kind):
		var old: Dictionary = c.gear[kind]
		store(w).append({"uid": int(old["uid"]), "k": kind, "q": int(old["q"])})
	c.gear[kind] = {"uid": int(it["uid"]), "q": int(it["q"])}
	var who: = "bạn" if c.is_player else c.name
	var t: = "Trang bị %s cho %s (%s)." % [name_of(kind, int(it["q"])), who, effect_text(kind, int(it["q"]))]
	PlayerOps.log_line(w, t)
	return _ok(t)


static func unequip(w: World, cid: String, kind: String) -> Dictionary:
	var c: = w.ch(cid)
	if not can_dress(w, c) or not c.gear.has(kind):
		return _fail("Không có món đồ để cất.")
	if store(w).size() >= STORE_CAP:
		return _fail("Kho đã đầy (%d món)." % STORE_CAP)
	var old: Dictionary = c.gear[kind]
	c.gear.erase(kind)
	store(w).append({"uid": int(old["uid"]), "k": kind, "q": int(old["q"])})
	return _ok("Cất %s vào kho." % name_of(kind, int(old["q"])))



static func reclaim(w: World, c: Character) -> void :
	for k in KINDS:
		if c.gear.has(k) and not bool(c.gear[k].get("own", false)) and store(w).size() < STORE_CAP:
			var old: Dictionary = c.gear[k]
			store(w).append({"uid": int(old["uid"]), "k": k, "q": int(old["q"])})
			c.gear.erase(k)





static func likes(c: Character, kind: String) -> bool:
	if kind == "y_phuc":
		return c.mi_real >= 50.0 or c.fame >= 40.0
	return PlayerOps.is_martial(c)


static func gift_gain(c: Character, it: Dictionary) -> float:
	var kind: = str(it["k"])
	var g: = float(ITEM_GIFT[int(it["q"])])
	if likes(c, kind):
		g *= 1.5
	return g



static func give(w: World, uid: int, c: Character) -> Dictionary:
	var i: = _find(w, uid)
	if i < 0:
		return {}
	var it: Dictionary = store(w)[i]
	store(w).remove_at(i)
	var kind: = str(it["k"])
	if gear_q(c, kind) < int(it["q"]):
		c.gear[kind] = {"uid": int(it["uid"]), "q": int(it["q"])}
	return it


static func find_item(w: World, uid: int) -> Dictionary:
	var i: = _find(w, uid)
	return {} if i < 0 else store(w)[i]
