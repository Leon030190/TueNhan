class_name Rivals
extends RefCounted






const KINDS: = {
	"kieu_ngao": {"name": "Danh môn kiêu ngạo", "eye": 0, "fame_w": 1.0, "gap_w": 0.0, "stats": [], "aggr": 0.3, 
		"plots": ["vu_cao", "bom_deu"], "rec": 4.0, "scout": 0.4, 
		"desc": "Giàu, mắt kém, chỉ chuộng người đã có danh tiếng; trả giá cao."}, 
	"tinh_mat": {"name": "Hàn môn tinh mắt", "eye": 3, "fame_w": 0.0, "gap_w": 1.0, "stats": [], "aggr": 0.2, 
		"plots": ["bom_deu", "vu_cao"], "rec": 2.0, "scout": 0.45, 
		"desc": "Nghèo nhưng mắt tinh, săn đúng ngọc thô: đối thủ trực tiếp của bạn."}, 
	"vo_gia": {"name": "Võ gia", "eye": 1, "fame_w": 0.3, "gap_w": 0.3, "stats": [0, 2], "aggr": 0.5, 
		"plots": ["am_sat", "vu_cao"], "rec": 4.0, "scout": 0.4, 
		"desc": "Gom võ nhân, nhắm ghế tướng; không ngại dùng dao."}, 
	"thuong_gia": {"name": "Thương gia", "eye": 1, "fame_w": 0.5, "gap_w": 0.3, "stats": [5, 4], "aggr": 0.3, 
		"plots": ["dung_doc", "bom_deu"], "rec": 5.0, "scout": 0.4, 
		"desc": "Nhiều bạc, mua người, mua ảnh hưởng."}, 
	"gia_than": {"name": "Gia thần trong triều", "eye": 1, "fame_w": 0.5, "gap_w": 0.2, "stats": [3, 1], "aggr": 0.6, 
		"plots": ["vu_cao", "dung_doc"], "rec": 10.0, "scout": 0.25, 
		"desc": "Ít môn khách nhưng thạo đường trong triều, giỏi hãm hại."}, 
}


const PLOTS: = {
	"bom_deu": {"name": "Thổi phồng", "cost": 150, "days": 3, "expose": 0.1, "rel": 10.0, "prestige": 5.0, 
		"desc": "Tung lời đồn thổi phồng một kẻ tầm thường thành kỳ tài (hồ sơ giả 2 năm). Kẻ mắt kém sẽ tốn tiền rước về, tốn ghế tiến cử."}, 
	"vu_cao": {"name": "Vu cáo", "cost": 300, "days": 4, "expose": 0.3, "rel": 25.0, "prestige": 10.0, 
		"desc": "Gièm pha một quan chức trong triều để họ mất chức. Phải đứng ở kinh đô nước đó."}, 
	"am_sat": {"name": "Ám sát", "cost": 200, "days": 3, "expose": 0.5, "rel": 40.0, "prestige": 20.0, 
		"desc": "Sai môn khách giỏi võ ra tay. Thất bại thì người đi có thể không về."}, 
	"dung_doc": {"name": "Hạ độc", "cost": 250, "days": 3, "expose": 0.25, "rel": 30.0, "prestige": 12.0, 
		"desc": "Bỏ độc qua người hầu: Sức khỏe −45, yếu sẵn thì chết. Kín đáo hơn ám sát."}, 
	"to_giac": {"name": "Tố giác", "cost": 300, "days": 4, "expose": 0.6, "rel": 40.0, "prestige": 15.0, 
		"desc": "Đem chứng cứ nội gián thu được tố họ mưu phản trước triều đình. Thành thì cả nhà bị tịch biên. Cần nội gián đang cài trong nhà đó và phải đứng ở kinh đô nước họ."}, 
	"noi_gian": {"name": "Cài nội gián", "cost": 400, "days": 5, "expose": 0.2, "rel": 20.0, "prestige": 5.0, 
		"desc": "Cài người vào một thế gia 12 tháng: biết họ là hạng nhà nào, thấy môn khách của họ, hay tin họ âm mưu với bạn."}, 
}
const PLOT_ORDER: = ["bom_deu", "vu_cao", "am_sat", "dung_doc", "noi_gian", "to_giac"]
const BROKE_MONTHS: = 6
const MIN_HOUSES: = 5
const ORPHAN_MONTHS: = 24
const REMNANT_PENALTY: = 10.0

const ALLY_REL: = 50.0
const ENEMY_REL: = -30.0
const KIN_REL: = 70.0
const KIN_COST: = 1500
const KIN_MAX: = 2
const VISIT_DAYS: = 3
const GIFTS: = [[0, 4.0], [200, 9.0], [600, 16.0]]
const SPY_MONTHS: = 12
const POACH_LOYALTY: = 40.0
const STAT_ENV: = ["quan_doanh", "hoc_vien", "quan_doanh", "hoc_vien", "cong_xuong", "thuong_hoi"]




static func generate(w: World) -> void :
	for rd in GameData.world_def().get("rivals", []):
		var rid: = str(rd["id"])
		if not w.nations.has(str(rd["nation"])) or not w.cities.has(str(rd["city"])) or w.rivals.has(rid):
			continue
		var kind: = str(rd["kind"])
		var r: = Rng.make([w.world_seed, "rival", rid])
		var head: = WorldGen.new_commoner(w, str(rd["city"]), r.randi_range(42, 58))
		head.name = str(rd["head"])
		head.female = rid == "mai" or rid == "tiet"
		head.patron = rid
		head.special = "gia_chu"
		head.fame = maxf(head.fame, 30.0 + float(rd["tier"]) * 8.0)
		var ks: Array = KINDS[kind]["stats"]
		for i in (ks if not ks.is_empty() else [Defs.CHINH, Defs.TRI]):
			head.pot[int(i)] = maxf(float(head.pot[int(i)]), r.randf_range(65.0, 85.0))
			head.real[int(i)] = maxf(float(head.real[int(i)]), float(head.pot[int(i)]) * 0.9)
		w.rivals[rid] = {
			"id": rid, "name": str(rd["name"]), "kind": kind, "nation": str(rd["nation"]), "city": str(rd["city"]), 
			"desc": str(rd.get("desc", "")), "head": head.id, "tier": int(rd["tier"]), "prestige": float(rd["prestige"]), 
			"money": float(rd["money"]), "eye": int(KINDS[kind]["eye"]), "rel": float(rd.get("rel", 0.0)), "base": float(rd.get("rel", 0.0)), 
			"met": false, "kin": false, "spy": 0, "retainers": [], "visit_m": -99, "plot_m": -99, "dom_m": 0, "coup_m": -99, 
		}
		var rv: Dictionary = w.rivals[rid]
		for k in r.randi_range(1, 3):
			_scout(w, rv, r, true)



static func of(w: World, c: Character) -> Dictionary:
	if c == null or c.patron == "":
		return {}
	return w.rivals.get(c.patron, {})



static func backer(c: Character) -> String:
	if c == null or not c.recommender.begins_with("clan:"):
		return ""
	return c.recommender.substr(5)


static func head_of(w: World, rv: Dictionary) -> Character:
	return w.ch(str(rv["head"]))


static func members(w: World, rv: Dictionary) -> Array:
	var res: Array = []
	for id in rv["retainers"]:
		var c: = w.ch(str(id))
		if c != null and c.alive and c.patron == str(rv["id"]):
			res.append(c)
	return res


static func officials(w: World, rid: String) -> Array:
	var res: Array = []
	for c: Character in w.living():
		if c.office_key != "" and c.recommender == "clan:" + rid:
			res.append(c)
	return res


static func is_ally(rv: Dictionary) -> bool:
	return bool(rv.get("kin", false)) or float(rv["rel"]) >= ALLY_REL


static func stance(rv: Dictionary) -> String:
	if bool(rv.get("kin", false)):
		return "Thông gia"
	var rel: = float(rv["rel"])
	if rel >= ALLY_REL:
		return "Liên minh"
	if rel <= ENEMY_REL:
		return "Thù địch"
	return "Trung lập"



static func known_kind(rv: Dictionary) -> bool:
	return bool(rv.get("met", false)) or int(rv.get("spy", 0)) > 0


static func cap(rv: Dictionary) -> int:
	return 2 + int(rv["tier"]) * 2


static func _cities(w: World, rv: Dictionary) -> Array:
	var home: = str(rv["city"])
	var res: Array = [home]
	if w.nations.has(str(rv["nation"])):
		var capc: = str(w.nations[str(rv["nation"])]["capital"])
		if not res.has(capc):
			res.append(capc)
	for nb in w.cities[home]["links"]:
		if w.cities.has(nb) and not res.has(nb):
			res.append(nb)
	return res



static func estimate(w: World, rv: Dictionary, c: Character) -> float:
	var kd: Dictionary = KINDS[str(rv["kind"])]
	var e: = float(rv["eye"]) * 0.22
	var v: = lerpf(PlayerOps.perceived_best(w, c), c.max_pot(), e)
	v += c.fame * 0.15 * float(kd["fame_w"])
	v += maxf(0.0, c.max_pot() - c.max_real()) * 0.2 * float(kd["gap_w"]) * e
	var ks: Array = kd["stats"]
	if ks.has(c.top_pot()):
		v += 6.0
	return v




static func tick(w: World) -> void :
	if w.rivals.is_empty():
		generate(w)
	for rid in w.rivals.keys():
		var rv: Dictionary = w.rivals[rid]
		if is_fallen(rv):
			continue
		var r: = w.rng(["rival", rid])
		if not w.nations.has(str(rv["nation"])):
			_stateless(w, rv)
			continue
		_succession(w, rv, r)
		if is_fallen(rv):
			continue
		_economy(w, rv)
		if is_fallen(rv):
			continue
		if r.randf() < float(KINDS[str(rv["kind"])]["scout"]):
			_scout(w, rv, r, false)
		if r.randf() < 0.34:
			_recommend(w, rv, r)
		if not w.play.is_empty():
			_poach(w, rv, r)
			_plot_vs_player(w, rv, r)
			_share_lead(w, rv, r)
			rv["rel"] = move_toward(float(rv["rel"]), float(rv.get("base", 0.0)), 0.3)
			rv["spy"] = maxi(0, int(rv.get("spy", 0)) - 1)
		_feud(w, rv, r)
		_coup(w, rv, r)
		_dominance(w, rv)
	_rise(w)


static func _succession(w: World, rv: Dictionary, r: RandomNumberGenerator) -> void :
	var head: = head_of(w, rv)
	if head != null and head.alive:
		return
	var best: Character = null
	for c: Character in members(w, rv):
		if c.age(w.m) >= 25 and (best == null or float(c.real[Defs.CHINH]) > float(best.real[Defs.CHINH])):
			best = c
	if best == null:
		fall(w, rv, "tuyệt tự: gia chủ mất mà không còn người kế vị")
		return
	(rv["retainers"] as Array).erase(best.id)
	best.special = "gia_chu"
	best.city_id = str(rv["city"])
	rv["head"] = best.id
	rv["prestige"] = maxf(0.0, float(rv["prestige"]) - 20.0)
	w.add_news("%s có gia chủ mới: %s." % [rv["name"], best.name], [best.id], "the_gia")


static func _economy(w: World, rv: Dictionary) -> void :
	var mem: = members(w, rv)
	var ids: Array = []
	for c: Character in mem:
		ids.append(c.id)
	rv["retainers"] = ids
	var offs: = officials(w, str(rv["id"]))
	rv["money"] = float(rv["money"]) + income(w, rv) - expense(w, rv)
	if float(rv["money"]) < 0.0:
		rv["broke_m"] = int(rv.get("broke_m", 0)) + 1
		rv["prestige"] = maxf(0.0, float(rv["prestige"]) - 5.0)
		if not mem.is_empty():
			var gone: Character = mem[mem.size() - 1]
			_free(w, rv, gone)
			gone.add_log(w.m, "Bỏ %s vì nhà ấy nợ lương" % rv["name"])
			mem.erase(gone)
		if int(rv["broke_m"]) >= BROKE_MONTHS and mem.is_empty() and offs.is_empty():
			fall(w, rv, "phá sản: nợ nần, môn khách bỏ đi hết")
			return
	else:
		rv["broke_m"] = 0
	rv["prestige"] = maxf(0.0, float(rv["prestige"]) + 0.3 * offs.size() - 0.05)
	rv["tier"] = clampi(1 + int(float(rv["prestige"]) / 110.0), 1, 5)



static func _scout(w: World, rv: Dictionary, r: RandomNumberGenerator, initial: bool) -> void :
	if (rv["retainers"] as Array).size() >= cap(rv):
		return
	var cities: = _cities(w, rv)
	var best: Character = null
	var bv: = 52.0 + float(rv["tier"]) * 2.0 if not initial else 45.0
	for c: Character in w.living():
		if c.is_player or c.office_key != "" or c.nation_id != "" or c.patron != "" or c.clan_retainer:
			continue
		if not cities.has(c.city_id) or c.age(w.m) < 16 or c.age(w.m) > 60 or not c.crisis.is_empty():
			continue
		var v: = estimate(w, rv, c) + r.randf_range(-4.0, 4.0)
		if v > bv:
			bv = v
			best = c
	if best == null:
		return
	var pv: = PlayerOps.perceived_best(w, best)
	var fee: = (50.0 + pv * 4.0) * (2.0 if float(rv["money"]) > 3000.0 else 1.0)
	if float(rv["money"]) < fee and not initial:
		return
	var s: = 45.0 + (float(rv["tier"]) - 1.0) * 8.0 + float(rv["prestige"]) / 20.0 + (30.0 - best.fame) / 2.0 - best.tham_vong / 4.0
	s += 15.0 if float(rv["money"]) > 3000.0 else 0.0
	if best.has_trait("an_dat"):
		s -= 25.0
	if s + r.randf_range(-10.0, 10.0) < 50.0:
		return
	if not initial:
		rv["money"] = float(rv["money"]) - fee
	take(w, rv, best)



static func take(w: World, rv: Dictionary, c: Character) -> void :
	c.patron = str(rv["id"])
	c.city_id = str(rv["city"])
	c.loyalty = maxf(c.loyalty, 60.0)
	c.env = STAT_ENV[c.top_pot()]
	c.focus = [c.top_pot()]
	(rv["retainers"] as Array).append(c.id)
	c.add_log(w.m, "Nhận lời làm môn khách của %s" % rv["name"])
	if c.fame >= 35.0:
		w.add_news("%s về làm môn khách của %s." % [c.name, rv["name"]], [c.id], "the_gia")
	if not w.play.is_empty():
		var had_lead: = false
		var keep: Array = []
		for l in w.play.get("leads", []):
			if str(l["id"]) == c.id:
				had_lead = true
			else:
				keep.append(l)
		w.play["leads"] = keep
		if had_lead or w.notebook.has(c.id) or PlayerOps.is_starred(w, c.id):
			PlayerOps.report(w, "%s đã nhận lời về dưới trướng %s, nhanh chân hơn bạn." % [c.name, rv["name"]] if not w.notebook.has(c.id) else "%s, người bạn từng gặp, đã về dưới trướng %s." % [c.name, rv["name"]])



static func _recommend(w: World, rv: Dictionary, r: RandomNumberGenerator) -> void :
	var nid: = str(rv["nation"])
	var offices: Dictionary = w.nations[nid]["offices"]
	var bonus: = float(KINDS[str(rv["kind"])]["rec"]) + float(rv["tier"]) * 2.0 + float(rv["prestige"]) / 40.0
	var best: Array = []
	var bm: = 0.0
	for c: Character in members(w, rv):
		if c.age(w.m) < 18 or c.max_real() < 45.0 or c.id == str(rv["head"]):
			continue
		for key in offices:
			var oid: = Appointment.office_of_key(key)
			var inc: = w.office_holder(nid, key)
			if inc != null and inc.recommender == "clan:" + str(rv["id"]):
				continue
			if Appointment.shamed(w, c):
				continue
			var cand: = Appointment.score(w, c, nid, oid) + bonus
			var inc_s: = Appointment.MIN_SCORE if inc == null else Appointment.score(w, inc, nid, oid) + Appointment.incumbency(inc)
			if inc != null and backer(inc) != "" and w.rivals.has(backer(inc)):
				inc_s += float(w.rivals[backer(inc)]["tier"]) * 2.0
			var margin: = (cand - inc_s) * float(Defs.OFFICES[oid]["weight"])
			if cand > inc_s and margin > bm:
				bm = margin
				best = [c, key]
	if best.is_empty():
		return
	var c: Character = best[0]
	var key: String = best[1]
	if Appointment.snubbed(w, c):
		return
	var inc: = w.office_holder(nid, key)
	(rv["retainers"] as Array).erase(c.id)
	c.patron = ""
	c.recommender = "clan:" + str(rv["id"])
	if inc != null:
		var was_mine: = inc.recommender == w.player_id
		Appointment.vacate(w, inc, "bị thay thế nhờ %s tiến cử %s" % [rv["name"], c.name])
		if was_mine and not w.play.is_empty():
			rv["rel"] = float(rv["rel"]) - 10.0
			PlayerOps.report(w, "%s tiến cử %s, hất cẳng %s (người của bạn) khỏi ghế." % [rv["name"], c.name, inc.name])
		elif backer(inc) != "" and w.rivals.has(backer(inc)):
			var other: Dictionary = w.rivals[backer(inc)]
			other["prestige"] = maxf(0.0, float(other["prestige"]) - 3.0)
	Appointment.appoint(w, nid, key, c)
	c.add_log(w.m, "Được %s tiến cử" % rv["name"])
	rv["prestige"] = float(rv["prestige"]) + 3.0
	w.count("rival_rec")



static func _poach(w: World, rv: Dictionary, r: RandomNumberGenerator) -> void :
	if is_ally(rv) or r.randf() > (0.06 if float(rv["rel"]) < 0.0 else 0.03):
		return
	var best: Character = null
	var bv: = 0.0
	for c: Character in PlayerOps.retainers(w):
		var poor: = c.purse < float(w.play["salary"].get(c.id, 0)) * 3.0
		if c.loyalty >= POACH_LOYALTY + (10.0 if poor else 0.0) or PlayerOps._has_choice_for(w, c.id):
			continue
		var v: = estimate(w, rv, c)
		if v > bv:
			bv = v
			best = c
	if best == null:
		return
	PlayerOps.push_choice(w, "loi_keo", best.id, "%s ngầm mời %s (Trung thành %d) về làm môn khách, hứa bổng lộc hậu hĩnh." % [rv["name"], best.name, roundi(best.loyalty)], 
		[["giu", "Giữ lại", "Tăng lương 50%, Trung thành +15"], ["de_di", "Để đi", "%s sang %s; quan hệ với họ +5" % [best.name, rv["name"]]]], {"rid": str(rv["id"])})



static func _share_lead(w: World, rv: Dictionary, r: RandomNumberGenerator) -> void :
	if not is_ally(rv) or r.randf() > 0.3:
		return
	var best: Character = null
	var bv: = 55.0
	for c: Character in w.living():
		if c.is_player or c.office_key != "" or c.nation_id != "" or c.patron != "" or c.clan_retainer or w.notebook.has(c.id):
			continue
		if not _cities(w, rv).has(c.city_id) or c.age(w.m) < 16:
			continue
		var v: = estimate(w, rv, c)
		if v > bv:
			bv = v
			best = c
	if best == null:
		return
	for l in w.play["leads"]:
		if str(l["id"]) == best.id:
			return
	(w.play["leads"] as Array).append({"id": best.id, "city": best.city_id, "m": w.m, "text": PlayerOps._lead_text(w, best, r) + " (tin từ %s)" % rv["name"]})
	PlayerOps.report(w, "%s báo tin: ở %s có người đáng để mắt tới." % [rv["name"], w.city_name(best.city_id)])





static func detect_chance(w: World, rv: Dictionary) -> float:
	var d: = 0.15
	for c: Character in PlayerOps.retainers(w):
		if str(w.play["tasks"].get(c.id, "")) == "mat_tham" and PlayerOps.task_pause(w, c) == "":
			d = maxf(d, 0.15 + float(c.real[Defs.TRI]) / 150.0 + float(c.real[Defs.CHINH]) / 300.0)
	if int(rv.get("spy", 0)) > 0:
		d += 0.4
	return clampf(d, 0.0, 0.9)


static func _plot_vs_player(w: World, rv: Dictionary, r: RandomNumberGenerator) -> void :
	if is_ally(rv) or w.m - int(rv["plot_m"]) < 4:
		return
	var hostile: = clampf( - float(rv["rel"]) / 100.0, 0.0, 1.0)
	var mine_here: = 0
	for c: Character in w.living():
		if c.recommender == w.player_id and c.office_key.begins_with(str(rv["nation"]) + "/"):
			mine_here += 1
	if mine_here >= 2:
		hostile += 0.15
	if hostile <= 0.0 or r.randf() >= float(KINDS[str(rv["kind"])]["aggr"]) * hostile * 0.3:
		return
	var plots: Array = KINDS[str(rv["kind"])]["plots"].duplicate()
	if float(rv["rel"]) <= -50.0:
		plots.append("am_sat")
		plots.append("dung_doc")
	var plot: String = Rng.pick(r, plots)
	var target: = _pick_target(w, rv, plot, r)
	if target == null:
		return
	rv["plot_m"] = w.m
	if r.randf() < detect_chance(w, rv):
		PlayerOps.push_choice(w, "am_muu", target.id, "Mật báo: %s đang ngầm %s nhắm vào %s." % [rv["name"], str(PLOTS[plot]["name"]).to_lower(), "bạn" if target.is_player else target.name], 
			[["phong", "Đề phòng", "Âm mưu thất bại; tốn 80 lượng"], ["phan_don", "Phản đòn", "Âm mưu thất bại, họ bị vạch mặt: Danh vọng của họ −15, quan hệ −15"], ["mac_ke", "Mặc kệ", "Để âm mưu diễn ra"]], 
			{"rid": str(rv["id"]), "plot": plot}, 1)
		return
	run_vs_player(w, rv, plot, target, r)


static func _pick_target(w: World, rv: Dictionary, plot: String, r: RandomNumberGenerator) -> Character:
	var p: = w.player()
	match plot:
		"vu_cao":
			var pool: Array = []
			for c: Character in w.living():
				if c.recommender == w.player_id and c.office_key.begins_with(str(rv["nation"]) + "/"):
					pool.append(c)
			return null if pool.is_empty() else Rng.pick(r, pool)
		"bom_deu":
			var pool2: Array = []
			for c: Character in w.living():
				if c.city_id == p.city_id and not c.is_player and c.office_key == "" and c.nation_id == "" and c.patron == ""\
				and not c.clan_retainer and c.max_pot() < 55.0 and c.age(w.m) >= 16 and not c.has_disguise() and not w.notebook.has(c.id):
					pool2.append(c)
			return null if pool2.is_empty() else Rng.pick(r, pool2)
		"am_sat", "dung_doc":
			if float(rv["rel"]) <= -70.0 and r.randf() < 0.25:
				return p
			var best: Character = null
			var bv: = 0.0
			for c: Character in PlayerOps.retainers(w):
				var v: = c.max_real()
				if v > bv:
					bv = v
					best = c
			return best
	return null



static func run_vs_player(w: World, rv: Dictionary, plot: String, target: Character, r: RandomNumberGenerator) -> void :
	if target == null or not target.alive:
		return
	var exposed: = r.randf() < float(PLOTS[plot]["expose"])
	var who: = ("Người ta đồn %s đứng sau." % rv["name"]) if exposed else ""
	if exposed:
		rv["rel"] = float(rv["rel"]) - 5.0
	match plot:
		"vu_cao":
			PlayerOps.choice_framed(w, target)
			if exposed:
				PlayerOps.report(w, "Vụ gièm pha %s: %s" % [target.name, who])
		"bom_deu":
			pump(w, target, r)
			var text: = PlayerOps._lead_text(w, target, r)
			if r.randf() < detect_chance(w, rv):
				text += " (nghe nói do người của %s tung ra)" % rv["name"]
			(w.play["leads"] as Array).append({"id": target.id, "city": target.city_id, "m": w.m, "text": text})
		"am_sat":
			var atk: = 45.0 + float(rv["tier"]) * 5.0 + (15.0 if str(rv["kind"]) == "vo_gia" else 0.0) + r.randf_range(-15.0, 15.0)
			var guard: = Items.eff_vo(target) + (PlayerOps.guard_power(w) if target.is_player or PlayerOps.is_following(w, target) else 0.0) * 0.5
			if target.is_player:
				guard += 10.0 if float(w.clan.get("troops", 0)) >= 100.0 else 0.0
			if atk > guard + r.randf_range(0.0, 20.0):
				Life.die(w, target, "bị ám sát")
				PlayerOps.report(w, "%s bị thích khách ám sát. %s" % ["Bạn" if target.is_player else target.name, who])
			else:
				PlayerOps.report(w, "%s thoát một vụ ám sát. %s" % ["Bạn" if target.is_player else target.name, who])
		"dung_doc":
			var dmg: = 45.0 * (0.6 if _has_healer(w) else 1.0)
			target.health -= dmg
			if target.health <= 0.0:
				Life.die(w, target, "trúng độc")
				PlayerOps.report(w, "%s trúng độc qua đời. %s" % ["Bạn" if target.is_player else target.name, who])
			else:
				target.set_mood("sa_sut", 3)
				PlayerOps.report(w, "%s trúng độc, Sức khỏe −%d. %s" % ["Bạn" if target.is_player else target.name, roundi(dmg), who])
	w.count("rival_plot:" + plot)


static func _has_healer(w: World) -> bool:
	for c: Character in PlayerOps.retainers(w):
		if c.profession == "thay_thuoc" or c.has_talent("y_thuat"):
			return true
	return w.has_feature(PlayerOps.here(w), "y_quan")



static func pump(w: World, c: Character, r: RandomNumberGenerator) -> void :
	var order: Array = [0, 1, 2, 3, 4, 5]
	order.sort_custom( func(a: int, b: int) -> bool: return float(c.pot[a]) > float(c.pot[b]))
	c.disguise_mul = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
	c.disguise_add = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	c.disguise_add[order[0]] = r.randf_range(20.0, 28.0)
	c.disguise_add[order[1]] = r.randf_range(10.0, 16.0)
	c.fame = minf(60.0, c.fame + 20.0)
	if c.special == "":
		c.special = "hu_danh"
	c.add_log(w.m, "Bỗng nổi danh khắp vùng")





static func _feud(w: World, rv: Dictionary, r: RandomNumberGenerator) -> void :
	if r.randf() > 0.012 * float(KINDS[str(rv["kind"])]["aggr"]) * 2.0:
		return
	var pool: Array = []
	for c: Character in w.living():
		var b: = backer(c)
		if c.office_key != "" and b != "" and b != str(rv["id"]) and c.office_key.begins_with(str(rv["nation"]) + "/"):
			pool.append(c)
	if pool.is_empty():
		return
	var t: Character = Rng.pick(r, pool)
	var other: Dictionary = w.rivals.get(backer(t), {})
	Events.framed_apply(w, t)
	if not other.is_empty():
		other["prestige"] = maxf(0.0, float(other["prestige"]) - 5.0)
	w.add_news("%s bị gièm pha mất chức; người ta đồn là tay %s." % [t.name, rv["name"]], [t.id], "the_gia")



static func _coup(w: World, rv: Dictionary, r: RandomNumberGenerator) -> void :
	var nid: = str(rv["nation"])
	var nat: Dictionary = w.nations[nid]
	if float(nat["stability"]) >= 35.0 or w.m - int(rv["coup_m"]) < 24:
		return
	var keys: = Endings.key_offices(w, nid)
	if keys.is_empty():
		return
	var held: = 0
	for key in keys:
		var h: = w.office_holder(nid, key)
		if h != null and backer(h) == str(rv["id"]):
			held += 1
	if float(held) / float(keys.size()) < 0.5 or r.randf() > 0.04:
		return
	rv["coup_m"] = w.m
	var head: = head_of(w, rv)
	if head == null:
		return
	if r.randf() < 0.45 + float(rv["tier"]) * 0.05:
		nat["ruler_id"] = head.id
		nat["ruler"] = head.name
		rv["prestige"] = float(rv["prestige"]) + 80.0
		w.add_news("Chính biến ở %s: %s của %s đoạt ngôi!" % [nat["name"], head.name, rv["name"]], [head.id], "bien_co")
	else:
		w.add_news("%s mưu phản bất thành." % rv["name"], [head.id], "bien_co")
		confiscate(w, rv, "mưu phản bất thành")
	w.count("rival_coup")



static func _dominance(w: World, rv: Dictionary) -> void :
	var held: = 0
	var total: = 0
	for nid in w.nations:
		for key in Endings.key_offices(w, nid):
			total += 1
			var h: = w.office_holder(nid, key)
			if h != null and backer(h) == str(rv["id"]):
				held += 1
	if total > 0 and float(held) / float(total) >= Endings.SHADOW_SHARE:
		rv["dom_m"] = int(rv.get("dom_m", 0)) + 1
		if int(rv["dom_m"]) == Endings.SHADOW_MONTHS:
			w.add_news("%s nắm quá nửa triều chính thiên hạ, trở thành thế lực đứng sau ngai vàng các nước." % rv["name"], [], "bien_co")
	else:
		rv["dom_m"] = 0




static func is_fallen(rv: Dictionary) -> bool:
	return str(rv.get("fallen", "")) != ""


static func income(w: World, rv: Dictionary) -> float:
	var city: Dictionary = w.cities[str(rv["city"])]
	var v: = 25.0 * float(rv["tier"]) + float(city["kinh_te"]) * 0.6 + 12.0 * officials(w, str(rv["id"])).size()
	if str(rv["kind"]) == "thuong_gia":
		v += 60.0
	return v


static func expense(w: World, rv: Dictionary) -> float:
	return 10.0 * members(w, rv).size() + 15.0 * float(rv["tier"])


static func _free(w: World, rv: Dictionary, c: Character) -> void :
	c.patron = ""
	c.env = ""
	c.set_profession(c.profession)
	(rv["retainers"] as Array).erase(c.id)
	if not rv.has("former"):
		rv["former"] = []
	(rv["former"] as Array).append(c.id)



static func fall(w: World, rv: Dictionary, reason: String) -> void :
	if is_fallen(rv):
		return
	for c: Character in members(w, rv):
		_free(w, rv, c)
		c.add_log(w.m, "%s sụp đổ, thành người tự do" % rv["name"])
	var head: = head_of(w, rv)
	if head != null and head.alive:
		head.patron = ""
		head.special = ""
	rv["fallen"] = reason
	rv["fall_m"] = w.m
	rv["retainers"] = []
	w.add_news("%s sụp đổ (%s)." % [rv["name"], reason], [], "bien_co")
	w.count("rival_fall")
	if not w.play.is_empty():
		PlayerOps.report(w, "%s sụp đổ (%s). Môn khách cũ của họ nay là người tự do, đang dễ mời." % [rv["name"], reason])
		if bool(rv.get("blame", false)):
			for rid in w.rivals:
				var o: Dictionary = w.rivals[rid]
				if not is_fallen(o) and not bool(o.get("kin", false)):
					o["rel"] = clampf(float(o["rel"]) - 10.0, -100.0, 100.0)
			PlayerOps.report(w, "Các thế gia khác dè chừng bạn hơn (quan hệ −10).")



static func confiscate(w: World, rv: Dictionary, why: String) -> void :
	for c: Character in officials(w, str(rv["id"])):
		Appointment.vacate(w, c, "bị liên lụy vụ %s" % rv["name"])
	var head: = head_of(w, rv)
	if head != null and head.alive:
		Life.die(w, head, "bị xử tử vì mưu phản")
	if w.nations.has(str(rv["nation"])):
		var nat: Dictionary = w.nations[str(rv["nation"])]
		nat["treasury"] = float(nat["treasury"]) + maxf(0.0, float(rv["money"]))
	rv["money"] = 0.0
	fall(w, rv, "bị tịch biên: " + why)



static func _stateless(w: World, rv: Dictionary) -> void :
	var offs: = officials(w, str(rv["id"]))
	if offs.is_empty():
		fall(w, rv, "mất nước, không còn chỗ dựa")
		return
	rv["nation"] = (offs[0] as Character).nation_id
	w.add_news("%s mất nước cũ, quay sang phụng sự %s." % [rv["name"], w.nation_name(str(rv["nation"]))], [], "the_gia")


static func active_count(w: World) -> int:
	var n: = 0
	for rid in w.rivals:
		if not is_fallen(w.rivals[rid]):
			n += 1
	return n



static func _rise(w: World) -> void :
	if active_count(w) >= MIN_HOUSES:
		return
	var r: = w.rng(["rival_rise"])
	if r.randf() > 0.05:
		return
	var homes: = {}
	for rid in w.rivals:
		if not is_fallen(w.rivals[rid]):
			homes[str(w.rivals[rid]["city"])] = true
	var best: Character = null
	for c: Character in w.living():
		if c.is_player or c.office_key != "" or c.nation_id != "" or c.patron != "" or c.clan_retainer or homes.has(c.city_id):
			continue
		if c.age(w.m) < 30 or not w.nations.has(w.city_nation(c.city_id)):
			continue
		if best == null or c.fame > best.fame:
			best = c
	if best == null or best.fame < 20.0:
		return
	var seq: = int(w.counters.get("rival_rise", 0))
	var rid2: = "moi_%d" % seq
	var surname: = best.name.split(" ")[0]
	if best.name.split(" ").size() >= 3 and ["Hách", "Thác", "Vũ", "Độc", "Hô", "Khất", "Mộ", "Âu", "Thượng"].has(surname):
		surname = best.name.split(" ")[0] + " " + best.name.split(" ")[1]
	var kind: String = Rng.pick(r, KINDS.keys())
	best.patron = rid2
	best.special = "gia_chu"
	w.rivals[rid2] = {
		"id": rid2, "name": surname + " gia", "kind": kind, "nation": w.city_nation(best.city_id), "city": best.city_id, 
		"desc": "Gia tộc mới nổi ở %s, dựng nghiệp từ danh tiếng của %s." % [w.city_name(best.city_id), best.name], 
		"head": best.id, "tier": 1, "prestige": 40.0, "money": 800.0, "eye": int(KINDS[kind]["eye"]), "rel": 0.0, "base": 0.0, 
		"met": false, "kin": false, "spy": 0, "retainers": [], "visit_m": -99, "plot_m": -99, "dom_m": 0, "coup_m": -99, 
	}
	w.count("rival_rise")
	w.add_news("%s trỗi dậy ở %s, gia chủ là %s." % [w.rivals[rid2]["name"], w.city_name(best.city_id), best.name], [best.id], "the_gia")



static func orphan(w: World, c: Character) -> bool:
	for rid in w.rivals:
		var rv: Dictionary = w.rivals[rid]
		if is_fallen(rv) and w.m - int(rv.get("fall_m", -999)) <= ORPHAN_MONTHS and (rv.get("former", []) as Array).has(c.id):
			return true
	return false



static func remnant_penalty(w: World, c: Character) -> float:
	var b: = backer(c)
	if b != "" and w.rivals.has(b) and is_fallen(w.rivals[b]):
		return REMNANT_PENALTY
	return 0.0



static func strongest(w: World) -> Array:
	var best: = ""
	var bh: = -1
	var total: = 0
	for nid in w.nations:
		total += Endings.key_offices(w, nid).size()
	for rid in w.rivals:
		if is_fallen(w.rivals[rid]):
			continue
		var held: = 0
		for nid in w.nations:
			for key in Endings.key_offices(w, nid):
				var h: = w.office_holder(nid, key)
				if h != null and backer(h) == rid:
					held += 1
		if held > bh:
			bh = held
			best = rid
	return [best, bh, total]





static func ally_bonus(w: World, nid: String) -> float:
	var b: = 0.0
	for rid in w.rivals:
		var rv: Dictionary = w.rivals[rid]
		if str(rv["nation"]) == nid and is_ally(rv) and not is_fallen(rv):
			b += 5.0
	return minf(10.0, b)


static func visit_block(w: World, rv: Dictionary) -> String:
	if is_fallen(rv):
		return "%s đã sụp đổ." % rv["name"]
	if PlayerOps.here(w) != str(rv["city"]):
		return "Phải tới %s (quê %s)." % [w.city_name(str(rv["city"])), rv["name"]]
	if int(rv["visit_m"]) == w.m:
		return "Đã bái phỏng %s tháng này." % rv["name"]
	return ""


static func visit_gain(w: World, rv: Dictionary, gift: int) -> float:
	var g: = float(GIFTS[gift][1]) + PlayerOps.charm(w) / 20.0
	match str(rv["kind"]):
		"thuong_gia":
			g += float(GIFTS[gift][1]) * 0.5 if gift > 0 else 0.0
		"kieu_ngao":
			if PlayerOps.clan_tier(w) < int(rv["tier"]) - 1:
				g *= 0.5
	return g



static func visit(w: World, rid: String, gift: int) -> Dictionary:
	var rv: Dictionary = w.rivals.get(rid, {})
	if rv.is_empty():
		return PlayerOps._fail("Không có thế gia này.")
	var err: = visit_block(w, rv)
	if err != "":
		return PlayerOps._fail(err)
	var cost: = int(GIFTS[gift][0])
	if PlayerOps.money(w) < float(cost):
		return PlayerOps._fail("Cần %d lượng." % cost)
	PlayerOps._spend(w, VISIT_DAYS)
	var g: = visit_gain(w, rv, gift)
	w.clan["money"] = PlayerOps.money(w) - float(cost)
	rv["rel"] = clampf(float(rv["rel"]) + g, -100.0, 100.0)
	rv["visit_m"] = w.m
	rv["met"] = true
	var head: = head_of(w, rv)
	if head != null and head.alive:
		var n: = PlayerOps.note(w, head.id)
		n["met_m"] = w.m
		n["met_t"] = PlayerOps.now(w)
	var t: = "Bái phỏng %s (%s): quan hệ +%.0f → %.0f (%s). Họ là %s." % [rv["name"], "tay không" if cost == 0 else "%d lượng lễ" % cost, g, float(rv["rel"]), stance(rv), str(KINDS[str(rv["kind"])]["name"]).to_lower()]
	PlayerOps.log_line(w, t)
	return PlayerOps._ok(t)


static func marry_block(w: World, rv: Dictionary) -> String:
	if is_fallen(rv):
		return "%s đã sụp đổ." % rv["name"]
	if bool(rv.get("kin", false)):
		return "Đã là thông gia."
	var n: = 0
	for rid in w.rivals:
		if bool(w.rivals[rid].get("kin", false)):
			n += 1
	if n >= KIN_MAX:
		return "Đã có %d nhà thông gia." % KIN_MAX
	if float(rv["rel"]) < KIN_REL:
		return "Quan hệ phải từ %d (hiện %d)." % [int(KIN_REL), roundi(float(rv["rel"]))]
	if PlayerOps.here(w) != str(rv["city"]):
		return "Phải tới %s." % w.city_name(str(rv["city"]))
	if PlayerOps.money(w) < float(KIN_COST):
		return "Cần %d lượng sính lễ." % KIN_COST
	return ""



static func marry(w: World, rid: String) -> Dictionary:
	var rv: Dictionary = w.rivals.get(rid, {})
	var err: = "Không có thế gia này." if rv.is_empty() else marry_block(w, rv)
	if err != "":
		return PlayerOps._fail(err)
	PlayerOps._spend(w, 5)
	w.clan["money"] = PlayerOps.money(w) - float(KIN_COST)
	rv["kin"] = true
	rv["rel"] = 100.0
	w.clan["prestige"] = PlayerOps.prestige(w) + 10.0
	var t: = "%s và %s kết thông gia: từ nay chung một thuyền." % [w.clan["name"], rv["name"]]
	w.add_news(t, [], "the_gia")
	PlayerOps.log_line(w, t)
	return PlayerOps._ok(t)



static func on_competition(w: World, nid: String) -> void :
	for rid in w.rivals:
		var rv: Dictionary = w.rivals[rid]
		if str(rv["nation"]) == nid and not bool(rv.get("kin", false)):
			rv["rel"] = clampf(float(rv["rel"]) - 3.0, -100.0, 100.0)



static func on_offended(w: World, rid: String, amount: float, why: String) -> void :
	if not w.rivals.has(rid):
		return
	var rv: Dictionary = w.rivals[rid]
	if bool(rv.get("kin", false)):
		amount *= 0.3
	rv["rel"] = clampf(float(rv["rel"]) - amount, -100.0, 100.0)
	if amount >= 5.0:
		PlayerOps.report(w, "%s phật ý vì %s (quan hệ −%d)." % [rv["name"], why, roundi(amount)])





static func plots_for(w: World, target: Character, rid: String) -> Array:
	var res: Array = []
	if rid != "":
		return ["noi_gian", "to_giac"]
	if target == null or not target.alive or target.is_player or PlayerOps.is_retainer(w, target):
		return res
	if target.office_key != "":
		res.append("vu_cao")
	if target.office_key == "" and target.nation_id == "" and target.patron == "":
		res.append("bom_deu")
	res.append("am_sat")
	res.append("dung_doc")
	return res



static func best_agent(w: World, plot: String, target: Character, rid: String = "") -> Array:
	var best: Character = null
	var bp: = -1.0
	for c: Character in PlayerOps.retainers(w):
		if not PlayerOps.with_me(w, c):
			continue
		var p: = chance(w, plot, c, target, rid)
		if p > bp:
			bp = p
			best = c
	return [best, maxf(0.0, bp)]


static func chance(w: World, plot: String, agent: Character, target: Character, rid: String) -> float:
	if agent == null:
		return 0.0
	match plot:
		"bom_deu":
			return clampf(0.5 + (Items.eff_mi(agent) + float(agent.real[Defs.CHINH])) / 250.0, 0.1, 0.9)
		"vu_cao":
			var inf: = float(w.play["influence"].get(target.nation_id, 0.0))
			return clampf(0.25 + (float(agent.real[Defs.CHINH]) + float(agent.real[Defs.TRI])) / 250.0 + inf / 200.0 - target.fame / 300.0, 0.05, 0.85)
		"am_sat":
			var def: = Items.eff_vo(target) + (25.0 if target.special == "gia_chu" else 0.0) + (10.0 if target.office_key != "" else 0.0)
			def += float(w.cities[target.city_id]["an_ninh"]) / 5.0
			return clampf(0.5 + (Items.eff_vo(agent) - def) / 60.0, 0.05, 0.9)
		"dung_doc":
			var p: = 0.35 + (float(agent.real[Defs.TRI]) + float(agent.real[Defs.SX])) / 300.0
			if w.has_feature(target.city_id, "y_quan"):
				p -= 0.2
			return clampf(p, 0.05, 0.85)
		"noi_gian":
			return clampf(0.3 + float(agent.real[Defs.TRI]) / 150.0, 0.1, 0.85)
		"to_giac":
			var rv: Dictionary = w.rivals.get(rid, {})
			if rv.is_empty():
				return 0.0
			var inf: = float(w.play["influence"].get(str(rv["nation"]), 0.0))
			return clampf(0.2 + float(agent.real[Defs.CHINH]) / 200.0 + inf / 150.0 - float(rv["tier"]) * 0.05, 0.05, 0.85)
	return 0.0


static func plot_block(w: World, plot: String, target: Character, rid: String) -> String:
	var cost: = int(PLOTS[plot]["cost"])
	if PlayerOps.money(w) < float(cost):
		return "Cần %d lượng." % cost
	if plot == "to_giac":
		var rvt: Dictionary = w.rivals.get(rid, {})
		if rvt.is_empty() or is_fallen(rvt):
			return "Không có thế gia này."
		if int(rvt.get("spy", 0)) <= 0:
			return "Cần có nội gián đang cài trong %s để có chứng cứ." % rvt["name"]
		if not w.nations.has(str(rvt["nation"])) or not PlayerOps.capital_nations(w).has(str(rvt["nation"])):
			return "Phải đứng ở kinh đô %s." % w.nation_name(str(rvt["nation"]))
	elif plot == "noi_gian":
		var rv: Dictionary = w.rivals.get(rid, {})
		if rv.is_empty() or is_fallen(rv):
			return "Không có thế gia này."
		if PlayerOps.here(w) != str(rv["city"]):
			return "Phải tới %s (quê %s)." % [w.city_name(str(rv["city"])), rv["name"]]
		if int(rv.get("spy", 0)) > 0:
			return "Đã có nội gián ở %s." % rv["name"]
	else:
		if target == null or not target.alive:
			return "Mục tiêu không còn."
		if plot == "vu_cao":
			if not PlayerOps.capital_nations(w).has(target.nation_id):
				return "Phải đứng ở kinh đô %s." % w.nation_name(target.nation_id)
		elif target.city_id != PlayerOps.here(w):
			return "%s không ở %s." % [target.name, w.city_name(PlayerOps.here(w))]
	if best_agent(w, plot, target, rid)[0] == null:
		return "Cần một môn khách theo hầu hoặc ở tư trạch nơi này để giao việc."
	return ""



static func plot(w: World, plot_id: String, target_id: String, rid: String = "") -> Dictionary:
	if not PLOTS.has(plot_id):
		return PlayerOps._fail("Không có mưu này.")
	var target: = w.ch(target_id) if target_id != "" else null
	var err: = plot_block(w, plot_id, target, rid)
	if err != "":
		return PlayerOps._fail(err)
	var pd: Dictionary = PLOTS[plot_id]
	var ag: Array = best_agent(w, plot_id, target, rid)
	var agent: Character = ag[0]
	var p: = float(ag[1])
	PlayerOps._spend(w, int(pd["days"]))
	w.clan["money"] = PlayerOps.money(w) - float(pd["cost"])
	var seq: = int(w.play.get("plot_seq", 0))
	w.play["plot_seq"] = seq + 1
	var r: = w.rng(["plot", seq])
	var ok: = r.randf() < p
	var victim_clan: = rid
	if target != null:
		victim_clan = target.patron if target.patron != "" else backer(target)
	var t: = ""
	match plot_id:
		"bom_deu":
			if ok:
				pump(w, target, r)
				t = "%s tung tin khắp nơi: %s bỗng thành \"kỳ tài\" trong miệng thiên hạ." % [agent.name, target.name]
			else:
				t = "Lời đồn %s tung ra không ai tin." % agent.name
		"vu_cao":
			var dv: = Repute.open_case(w, {"kind": "vu_cao", "id": target.id, "rid": victim_clan, "ok": ok, "title": "Kết quả vu cáo %s" % target.name})
			t = "%s đã đưa lời gièm pha về %s tới tai triều đình; khoảng %d ngày nữa có kết quả." % [agent.name, target.name, dv]
		"am_sat":
			if ok:
				Life.die(w, target, "bị ám sát")
				t = "%s ra tay: %s bỏ mạng." % [agent.name, target.name]
			else:
				t = "%s ám sát %s bất thành." % [agent.name, target.name]
				if r.randf() < 0.5:
					PlayerOps._release(w, agent)
					Life.die(w, agent, "bị bắt khi hành thích")
					t += " %s bị bắt và xử tử." % agent.name
		"dung_doc":
			if ok:
				target.health -= 45.0
				if target.health <= 0.0:
					Life.die(w, target, "trúng độc")
					t = "%s trúng độc qua đời." % target.name
				else:
					target.set_mood("sa_sut", 3)
					t = "%s trúng độc, nằm liệt giường (Sức khỏe −45)." % target.name
			else:
				t = "Chén độc không tới được miệng %s." % target.name
		"noi_gian":
			var rv: Dictionary = w.rivals[rid]
			if ok:
				rv["spy"] = SPY_MONTHS
				rv["met"] = true
				t = "Đã cài được người vào %s (%d tháng)." % [rv["name"], SPY_MONTHS]
			else:
				t = "Người của %s phát hiện kẻ lạ mặt, việc cài nội gián thất bại." % rv["name"]
		"to_giac":
			var rv2: Dictionary = w.rivals[rid]
			var dt: = Repute.open_case(w, {"kind": "to_giac", "id": "", "rid": rid, "ok": ok, "title": "Kết quả tố giác %s" % rv2["name"]})
			t = "Đơn tố giác %s mưu phản đã tới triều đình; khoảng %d ngày nữa xét xong." % [rv2["name"], dt]
	if agent.alive and not agent.has_trait("gian_xao"):
		agent.loyalty = maxf(0.0, agent.loyalty - 5.0)
	var expose: = float(pd["expose"]) * (1.0 if ok else 1.8)
	if r.randf() < minf(0.95, expose):
		w.clan["prestige"] = maxf(0.0, PlayerOps.prestige(w) - float(pd["prestige"]))
		t += " Việc bị lộ, thiên hạ chê trách (Danh vọng −%d)." % int(pd["prestige"])
		if target != null and (plot_id == "vu_cao" or plot_id == "dung_doc" or plot_id == "am_sat"):
			target.hates_player = true
		if victim_clan != "":
			on_offended(w, victim_clan, float(pd["rel"]), "bị bạn %s" % str(pd["name"]).to_lower())
	w.count("player_plot:" + plot_id)
	PlayerOps.log_line(w, t)
	return PlayerOps._ok(t, {"success": ok})
