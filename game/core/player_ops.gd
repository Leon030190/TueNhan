class_name PlayerOps
extends RefCounted



const MONTH_DAYS: = 30
const EYE_REGEN: = 4
const TIER_UNLOCK: = [0, 0, 0, 25, 80]
const LEAD_LIFE: = 6
const BEFRIEND_COST: = 100
const END_MONTH: = 120
const BASE_INCOME: = 40.0
const CLAN_TIER_NAMES: = ["", "Hàn môn", "Thế gia", "Danh môn", "Hào tộc", "Vương tộc"]
const MAX_TIER_SLICE: = 3
const TASK_ORDER: = ["", "quan_doanh", "hoc_vien", "thuong_hoi", "cong_xuong", "giao_du", "kinh_doanh", "quan_gia", "ho_ve", "thuyet_khach", "mat_tham", "day_do"]
const TROOP_BATCH: = 100
const TROOP_COST: = 200
const TROOP_UPKEEP: = 0.3
const TRADE_STAKE: = 300
const WORKSHOP_COST: = 800
const WORKSHOP_MAX: = 3
const TASKS: = {
	"": {"name": "Rảnh rỗi", "env": "", "cost": 0, "desc": "Sống theo nghề cũ."}, 
	"quan_doanh": {"name": "Rèn luyện ở Quân doanh", "env": "quan_doanh", "cost": 10, "desc": "Võ lực, Quân sự tăng nhanh. Có nguy cơ thương tích."}, 
	"hoc_vien": {"name": "Theo học Học viện", "env": "hoc_vien", "cost": 15, "desc": "Trí lực, Chính trị tăng nhanh."}, 
	"thuong_hoi": {"name": "Học việc ở Thương hội", "env": "thuong_hoi", "cost": 10, "desc": "Thương nghiệp tăng nhanh."}, 
	"cong_xuong": {"name": "Làm ở Công xưởng", "env": "cong_xuong", "cost": 10, "desc": "Sản xuất tăng nhanh."}, 
	"giao_du": {"name": "Giao du văn đàn, tửu lâu", "env": "van_dan", "cost": 20, "desc": "Mị lực tăng nhanh (×1,8), Chính trị tăng theo. Tốn kém; ăn chơi lâu ngày có khi nhiễm thói tham tài."}, 
	"kinh_doanh": {"name": "Kinh doanh cho gia tộc", "env": "thuong_hoi", "cost": 0, "desc": "Mang tiền về theo Điểm Thương nhân; Thương nghiệp tăng."}, 
	"mat_tham": {"name": "Làm mật thám", "env": "", "cost": 5, "desc": "Dò xét âm mưu của các thế gia nhắm vào bạn (theo Trí lực, Chính trị)."}, 
	"quan_gia": {"name": "Làm quản gia", "env": "", "cost": 0, "desc": "Làm mọi việc nhanh hơn 10% nếu Điểm Quan văn ≥ 50."}, 
	"ho_ve": {"name": "Hộ vệ", "env": "quan_doanh", "cost": 0, "desc": "Theo sát bảo vệ bạn: đánh cướp đường, giảm nguy cơ mất mạng khi chính biến hỏng (tính theo Võ lực). Võ lực tăng dần."}, 
	"thuyet_khach": {"name": "Thuyết khách", "env": "trieu_dinh", "cost": 0, "desc": "Đi thuyết phục thay bạn: chiêu mộ, khuyên nhủ, kết giao, tìm danh sư dùng Mị lực của họ (×0,9) nếu cao hơn của bạn."}, 
	"day_do": {"name": "Dạy dỗ môn khách khác", "env": "", "cost": 0, "desc": "Kèm một môn khách trẻ: thầy giỏi hơn tiềm năng của trò thì trò lớn nhanh ×1,6, giỏi hơn trò thì ×1,3."}, 
}
const SEEK_COST: = 300

const BRANCH_ORDER: = ["phan_tich", "du_doan", "nhan_qua"]
const BRANCHES: = {
	"phan_tich": {"name": "Phân tích", "cost": 1, "desc": "Từ kết quả thẩm định, thấy người này hợp vai trò, chức vụ và môi trường nào."}, 
	"du_doan": {"name": "Dự đoán", "cost": 2, "desc": "Thấy năng lực dự kiến sau 5 và 10 năm (nếu không có biến cố), tính từ kết quả thẩm định."}, 
	"nhan_qua": {"name": "Nhân quả", "cost": 2, "desc": "Thấy nhật ký biến đổi của người đã thẩm định: vì sao tiềm năng của họ thay đổi."}, 
}
const LOYALTY_WORDS: = [[80.0, "Tận tụy"], [60.0, "Hài lòng"], [40.0, "Bình thường"], [25.0, "Bất mãn"], [-1.0, "Muốn rời đi"]]
const LEAD_HINTS: = [
	["khỏe như trâu, vác hai bao gạo không thở dốc", "đánh nhau chưa từng thua ai trong xóm", "một mình đuổi được cả toán cướp"], 
	["đọc sách một lần là thuộc", "hay hỏi những câu khiến thầy đồ cứng họng", "giải được câu đố treo thưởng ở tửu lâu"], 
	["chơi cờ chưa ai thắng nổi", "hay bày trận giả cho lũ trẻ, đánh đâu thắng đó", "nhìn địa thế là đoán được đường cướp sẽ đi"], 
	["dàn xếp tranh chấp trong phường rất khéo", "nói gì cả xóm cũng nghe", "chép sổ sách cho quan huyện chưa sai chữ nào"], 
	["sửa nông cụ khéo nhất vùng", "ruộng nhà ấy năm nào cũng được mùa", "đóng được chiếc xe chở nặng gấp đôi"], 
	["tính nhẩm nhanh hơn bàn tính", "buôn gì lãi nấy", "chỉ nhìn qua là biết hàng thật hàng giả"], 
]

const PROBE_TIERS: = [
	{"name": "Ít", "cost": 30, "delay": 2, "half": 20.0, "wrong": 0.3, "events": 1, 
		"desc": "Thuê kẻ nhàn rỗi: tin về chậm, mơ hồ, đôi khi sai."}, 
	{"name": "Vừa", "cost": 80, "delay": 0, "half": 12.0, "wrong": 0.1, "events": 2, 
		"desc": "Thuê người buôn chuyến: tin về theo đường đi, khá đáng tin."}, 
	{"name": "Hậu", "cost": 200, "delay": -1, "half": 6.0, "wrong": 0.0, "events": 3, 
		"desc": "Thuê người tin cẩn, ngựa tốt: tin về nhanh, chính xác."}, 
]
const PUBLIC_EVENT_PREFIX: = ["Nhậm chức", "Rời chức", "Đỗ ", "Được thăng", "Qua đời", "Tay phải", "Chân bị", "Hỏng một", "Trọng thương", "Lâm bệnh", "Chuyển hướng", "Từ bỏ", "Sa ngã", "Chọn con đường", "Nhận lời làm môn khách", "Bỏ "]
const PATH_HINT: = {
	"phuc_hoi": "Khuyên kiên trì, đừng bỏ con đường cũ", 
	"chuyen_huong": "Khuyên tìm một con đường mới hợp với mình", 
	"truyen_thu": "Khuyên truyền lại sở học cho người sau", 
	"binh_thuong": "Khuyên buông bỏ, sống yên ổn", 
	"sa_nga": "(Không ai khuyên điều này)", 
}


static func init_play(w: World) -> void :
	var inf: = {}
	var p: = w.player()
	for nid in w.nations:
		inf[nid] = 10.0 if p != null and nid == p.nation_id else 0.0
	w.play = {
		"day": 0, "pending": [], "eye": 10, "eye_max": 10, "ngo_dao": 0, 
		"leads": [], "lead_seq": 0, "tasks": {}, "salary": {}, "influence": inf, "suspicion": 0.0, 
		"refused": {}, "report": [], "log": [], "last_income": 0.0, "recommended": [], "stars": [], 
		"probes": [], "intel": {}, "probe_seq": 0, 
		"teach": {}, "exam": {}, "seek": {}, "choices": [], "choice_seq": 0, "payouts": [], "branches": {}, 
		"end_m": END_MONTH, "home": "" if p == null else p.nation_id, "book": {}, "memory": 0, "ending": "", "shadow_m": 0, 
		"stats": {"met": 0, "appraised": 0, "recruited": 0, "recommended": 0, "foreign": 0, "predicted": 0}, 
		"over": "", 
	}
	w.play["last_income"] = clan_cashflow(w)[0]




static func _ok(msg: String, extra: Dictionary = {}) -> Dictionary:
	_settle()
	var d: = {"ok": true, "msg": msg}
	d.merge(extra)
	return d


static func _fail(msg: String) -> Dictionary:
	_owed = 0
	_owed_w = null
	return {"ok": false, "msg": msg}


static func log_line(w: World, text: String) -> void :
	var lg: Array = w.play["log"]
	lg.append({"m": w.m, "t": text})
	if lg.size() > 300:
		lg.pop_front()


static func report(w: World, text: String) -> void :
	(w.play["report"] as Array).append(text)



static func end_m(w: World) -> int:
	return int(w.play.get("end_m", END_MONTH))








const DAYS: = {
	"scout": 4, "meet": 1, "visit": 2, "recruit": 2, "recommend": 3, "counsel": 2, "train": 7, 
	"befriend": 3, "trade": 3, "seek_office": 3, "troops": 3, "workshop": 5, "seek_master": 5, 
	"join_war": 10, "craft": 4, "coup": 5, "career": 2, "expose": 3, "showcase": 5, 
	"observe": 2, "meditate": 4, "teahouse": 2, "odd_job": 5, "chat": 2, "court_chat": 3, "deed": 4, "tutor": 5, 
}
const DAY_NAMES: = {
	"scout": "Dò la", "meet": "Gặp gỡ", "visit": "Thăm hỏi", "recruit": "Chiêu mộ", "recommend": "Tiến cử", 
	"counsel": "Khuyên nhủ", "train": "Tu dưỡng", "befriend": "Kết giao", "trade": "Buôn chuyến", 
	"seek_office": "Xin chức", "troops": "Mộ tư binh", "workshop": "Mở xưởng", "seek_master": "Tìm danh sư", 
	"join_war": "Theo quân", "craft": "Chế tác", "coup": "Chính biến", "career": "Khuyên đổi nghề", "expose": "Vạch trần", "showcase": "Thi tài", 
	"observe": "Quan sát kỹ", "meditate": "Tĩnh tâm", "teahouse": "Ngồi trà quán", "odd_job": "Làm thuê", "chat": "Đàm đạo", 
	"court_chat": "Hầu chuyện quan lại", "deed": "Việc nghĩa", "tutor": "Tự tay chỉ dạy", 
}
const LAND_DAYS: = 5
const SEA_DAYS: = 4
const HORSE_SPEED: = [1.0, 0.9, 0.75, 0.6]
const OFFICE_DAYS: = 6
const REST_HEAL: = 10.0
const MEET_WINDOW: = 15
const SPEED_MIN: = 0.65

static var _owed: = 0
static var _owed_w: World = null


static func day(w: World) -> int:
	return int(w.play.get("day", 0))



static func now(w: World) -> int:
	return w.m * MONTH_DAYS + day(w)



static func days_left(w: World) -> int:
	return MONTH_DAYS - day(w)



static func speed_breakdown(w: World, steward: bool) -> Array:
	var parts: Array = []
	if steward:
		parts.append(["Quản gia", 10])
	if clan_tier(w) >= 3:
		parts.append(["Gia thế %s" % CLAN_TIER_NAMES[clan_tier(w)], 10])
	if int(w.play.get("ap_bonus", 0)) > 0:
		parts.append(["Cần mẫn (Thiên Cơ)", 15])
	var t: = 0
	for x in parts:
		t += int(x[1])
	return [maxf(SPEED_MIN, 1.0 - t / 100.0), parts]


static func speed_mult(w: World) -> float:
	return float(speed_breakdown(w, bool(clan_cashflow(w)[1]))[0])



static func act_days(w: World, key: String) -> int:
	return maxi(1, roundi(float(DAYS[key]) * speed_mult(w)))



static func travel_days(w: World, to: String) -> int:
	var p: = w.player()
	var links: Dictionary = w.cities[p.city_id]["links"]
	if not links.has(to):
		return -1
	var n: = int(links[to])
	if World.is_sea(p.city_id, to):
		return n * SEA_DAYS
	return maxi(1, roundi(n * LAND_DAYS * float(HORSE_SPEED[Items.gear_q(p, "toa_ky")])))



static func _spend(w: World, n: int) -> bool:
	_owed_w = w
	_owed += n
	return true


static func _settle() -> void :
	var w: = _owed_w
	var n: = _owed
	_owed = 0
	_owed_w = null
	if w != null and n > 0:
		pass_days(w, n)



static func pass_days(w: World, n: int) -> void :
	var d: = day(w) + n
	while d >= MONTH_DAYS and str(w.play["over"]) == "":
		var carry: = d - MONTH_DAYS
		var rep: = end_month(w)
		if not w.play.has("pending"):
			w.play["pending"] = []
		(w.play["pending"] as Array).append(rep)
		d = day(w) + carry
	if str(w.play["over"]) == "":
		w.play["day"] = d
		_arrivals(w)
		Repute.process_cases(w)
		Exam.day_tick(w)



static func take_reports(w: World) -> Array:
	var res: Array = w.play.get("pending", [])
	w.play["pending"] = []
	return res



static func rest(w: World) -> Dictionary:
	var n: = MONTH_DAYS - day(w)
	var t: = "Nghỉ ngơi %d ngày tới hết tháng." % n
	if w.has_feature(here(w), "y_quan"):
		var p: = w.player()
		p.health = minf(p.max_health(), p.health + REST_HEAL)
		t += " Y quán %s chăm sóc, Sức khỏe +%d." % [w.city_name(here(w)), int(REST_HEAL)]
	log_line(w, t)
	_spend(w, n)
	return _ok(t)


static func money(w: World) -> float:
	return float(w.clan["money"])


static func prestige(w: World) -> float:
	return float(w.clan["prestige"])


static func clan_tier(w: World) -> int:
	return int(w.clan["tier"])


static func here(w: World) -> String:
	return w.player().city_id


static func eye_tier(w: World) -> int:
	var t: = 2
	for k in range(3, 5):
		if int(w.play["ngo_dao"]) >= int(TIER_UNLOCK[k]):
			t = k
	return t


static func note(w: World, id: String) -> Dictionary:
	if not w.notebook.has(id):
		w.notebook[id] = {"first_m": w.m, "met_m": -99, "tiers": [], "pred": []}
	return w.notebook[id]


static func is_retainer(w: World, c: Character) -> bool:
	return c.clan_retainer and (w.clan["retainers"] as Array).has(c.id)



static func is_known(w: World, c: Character) -> bool:
	if c.is_player:
		return false
	return w.notebook.has(c.id) or c.office_key != "" or is_retainer(w, c) or c.fame >= 60.0 or c.special == "gia_chu" or (w.play.get("book", {}) as Dictionary).has(c.id)



static func is_starred(w: World, id: String) -> bool:
	return (w.play.get("stars", []) as Array).has(id)


static func toggle_star(w: World, id: String) -> Dictionary:
	var c: = w.ch(id)
	if c == null:
		return _fail("Không có người này.")
	if not w.play.has("stars"):
		w.play["stars"] = []
	var st: Array = w.play["stars"]
	if st.has(id):
		st.erase(id)
		return _ok("Bỏ lưu tâm %s." % c.name)
	st.append(id)
	return _ok("Lưu tâm %s: ghim lên đầu Sổ nhân vật; khi bạn ở cùng thành, bạn sẽ hay tin biến động của họ." % c.name)



static func met_now(w: World, c: Character) -> bool:
	if is_retainer(w, c):
		return true
	if not w.notebook.has(c.id) or c.city_id != here(w):
		return false
	var n: Dictionary = w.notebook[c.id]
	if n.has("met_t"):
		return int(n["met_t"]) >= now(w) - MEET_WINDOW
	return int(n["met_m"]) == w.m


static func capital_nations(w: World) -> Array:
	var res: Array = []
	for nid in w.nations:
		if str(w.nations[nid]["capital"]) == here(w):
			res.append(nid)
	return res



static func capitals_text(w: World) -> String:
	var caps: Array = []
	for nid in w.nations:
		caps.append(w.city_name(str(w.nations[nid]["capital"])))
	if caps.size() <= 1:
		return "".join(caps)
	return ", ".join(caps.slice(0, caps.size() - 1)) + " hoặc " + str(caps[caps.size() - 1])


static func retainers(w: World) -> Array:
	var res: Array = []
	for id in w.clan["retainers"]:
		var c: = w.ch(str(id))
		if c != null:
			res.append(c)
	return res


static func _add_ngo(w: World, n: int) -> void :
	if n <= 0:
		return
	var before: = eye_tier(w)
	w.play["ngo_dao"] = int(w.play["ngo_dao"]) + n
	var after: = eye_tier(w)
	if after > before:
		var t: = "Đôi Mắt đột phá: mở tầng %s!" % Defs.TIER_NAMES[after]
		log_line(w, t)
		report(w, t)




static func travel(w: World, to: String) -> Dictionary:
	var p: = w.player()
	var links: Dictionary = w.cities[p.city_id]["links"]
	if to == p.city_id:
		return _fail("Bạn đang ở %s." % w.city_name(to))
	if not links.has(to):
		return _fail("Không có đường đi thẳng tới %s." % w.city_name(to))
	var horse: = Items.gear_q(p, "toa_ky")
	var sea: = World.is_sea(p.city_id, to)
	var cost: = travel_days(w, to)
	_spend(w, cost)
	p.city_id = to
	for rc: Character in retainers(w):
		if is_following(w, rc):
			rc.city_id = to
		elif at_inn(w, rc) and str(loc(w, rc)["city"]) == to:
			loc(w, rc)["met"] = true
	var t: = "%s tới %s (%d ngày)." % ["Đi thuyền" if sea else "Lên đường", w.city_name(to), cost]
	var seq: = int(w.play.get("travel_seq", 0))
	w.play["travel_seq"] = seq + 1
	var r: = w.rng(["bandit", seq])
	var an_ninh: = float(w.cities[to]["an_ninh"])
	if r.randf() < clampf(0.06 + (60.0 - an_ninh) / 400.0, 0.02, 0.2) * (0.5 if sea else float(Items.HORSE_BANDIT[horse])):
		var foe: = r.randf_range(20.0, 70.0)
		var guard: = guard_power(w) + (10.0 if float(w.clan.get("troops", 0.0)) >= 100.0 else 0.0)
		if guard + r.randf_range(-10.0, 10.0) >= foe:
			w.clan["prestige"] = prestige(w) + 2.0
			t += " Gặp cướp giữa đường, đánh tan chúng (Danh vọng +2)."
		else:
			var lost: = minf(300.0, money(w) * 0.15)
			w.clan["money"] = money(w) - lost
			p.health = maxf(1.0, p.health - 10.0)
			t += " Gặp cướp giữa đường, bị cướp %d lượng." % roundi(lost)
	log_line(w, t)
	return _ok(t)



static func charm(w: World) -> float:
	var m: = Items.eff_mi(w.player())
	for c: Character in retainers(w):
		if str(w.play["tasks"].get(c.id, "")) == "thuyet_khach" and is_following(w, c):
			m = maxf(m, Items.eff_mi(c) * 0.9)
	return m



static func guard_power(w: World) -> float:
	var g: = Items.eff_vo(w.player())
	for c: Character in retainers(w):
		if str(w.play["tasks"].get(c.id, "")) == "ho_ve" and is_following(w, c):
			g = maxf(g, Items.eff_vo(c))
	return g


static func scout(w: World) -> Dictionary:
	var p: = w.player()
	if not _spend(w, act_days(w, "scout")):
		pass
	var cid: = here(w)
	var seq: = int(w.play["lead_seq"])
	w.play["lead_seq"] = seq + 1
	var r: = w.rng(["scout", seq])
	var existing: Array = []
	for l in w.play["leads"]:
		existing.append(str(l["id"]))
	var cands: Array = []
	var wts: Array = []
	for c: Character in w.living():
		if c.is_player or c.city_id != cid or c.office_key != "" or is_retainer(w, c) or c.patron != "":
			continue
		if w.notebook.has(c.id) or existing.has(c.id) or c.age(w.m) < 14:
			continue
		cands.append(c)
		wts.append(1.0 + maxf(0.0, c.max_pot() - c.max_real()) / 15.0 * scout_focus(w) + (0.5 if ProfTree.rank(c) >= 4 else 0.0))
	var tri: = float(p.real[Defs.TRI])
	var n: = 1 + (1 if tri >= 35.0 else 0) + (1 if tri >= 70.0 else 0) + (1 if r.randf() < 0.4 else 0)
	var found: Array = []
	for k in n:
		if cands.is_empty():
			break
		var i: = Rng.pick_weighted(r, wts)
		var c: Character = cands[i]
		cands.remove_at(i)
		wts.remove_at(i)
		var lead: = {"id": c.id, "city": cid, "m": w.m, "text": _lead_text(w, c, r)}
		(w.play["leads"] as Array).append(lead)
		found.append(lead)
	var rumor: = _known_rumor(w, cid, r)
	if found.is_empty():
		var t0: = "Ở %s không còn ai đáng chú ý mà bạn chưa gặp. Người mới tới hoặc mới trưởng thành sẽ xuất hiện dần; thử thành khác." % w.city_name(cid)
		if rumor != "":
			t0 = "Dò la ở %s: không có ai mới. %s" % [w.city_name(cid), rumor]
		log_line(w, t0)
		return _ok(t0, {"leads": [], "exhausted": true})
	var t: = "Dò la ở %s: nghe được %d lời đồn." % [w.city_name(cid), found.size()]
	if rumor != "":
		t += " " + rumor
	log_line(w, t)
	return _ok(t, {"leads": found})



const RUMOR_GAIN: = 8.0



static func _known_rumor(w: World, cid: String, r: RandomNumberGenerator) -> String:
	var best: Character = null
	var bg: = 0.0
	for c: Character in w.living():
		if c.city_id != cid or c.is_player or is_retainer(w, c) or not w.notebook.has(c.id):
			continue
		var n: Dictionary = w.notebook[c.id]
		if int(n.get("met_m", -99)) < 0:
			continue
		var g: = c.max_real() - float(n.get("seen", c.max_real()))
		if g >= RUMOR_GAIN and g + r.randf() > bg:
			best = c
			bg = g
	if best == null:
		return ""
	var nb: Dictionary = w.notebook[best.id]
	nb["seen"] = best.max_real()
	var t: = "Nghe nói %s dạo này tiến bộ trông thấy về %s, khác hẳn hồi bạn gặp." % [best.name, Defs.STAT_NAMES[best.top_real()].to_lower()]
	return t



static func scout_focus(w: World) -> float:
	return 0.5 + float(w.player().real[Defs.TRI]) / 50.0


static func _lead_text(w: World, c: Character, r: RandomNumberGenerator) -> String:
	var stat: = c.top_pot() if r.randf() < 0.65 else r.randi_range(0, 5)
	var hint: String = Rng.pick(r, LEAD_HINTS[stat])
	if c.special == "an_cao_nhan" and r.randf() < 0.5:
		hint = "trông tầm thường, nhưng ánh mắt rất sắc, chẳng ai rõ lai lịch"
	elif c.special == "hu_danh":
		hint = "nổi danh khắp vùng, ai cũng khen là " + Defs.STAT_NAMES[c.top_real()].to_lower() + " hơn người"
	var age: = c.age(w.m)
	var noun: = Defs.prof_name(c.profession).to_lower()
	var tag: = " trẻ" if age < 22 else (" đứng tuổi" if age >= 45 else "")
	var g: = "nữ " if c.female else ""
	var sharp: = float(w.player().real[Defs.TRI]) >= 50.0
	if sharp and c.special == "hu_danh":
		hint += " (nghe có vẻ phóng đại)"
	elif sharp and c.special == "an_cao_nhan":
		hint += " (người này không tầm thường)"
	return "Một %s%s%s: %s" % [g, noun, tag, hint]


static func meet(w: World, id: String) -> Dictionary:
	var c: = w.ch(id)
	if c == null or not c.alive:
		return _fail("Người này không còn trên đời.")
	if c.city_id != here(w):
		return _fail("%s hiện không ở %s." % [c.name, w.city_name(here(w))])
	if met_now(w, c):
		return _fail("Vừa gặp %s mấy hôm trước." % c.name)
	if not _spend(w, act_days(w, "meet")):
		pass
	var lead: = lead_of(w, id)
	if not lead.is_empty() and not w.notebook.has(id):
		var seq: = int(w.play.get("meet_seq", 0))
		w.play["meet_seq"] = seq + 1
		if w.rng(["meet_miss", id, seq]).randf() < lead_miss_chance(w, lead):
			var tm: = "Lần theo lời đồn khắp %s mà không tìm ra người ấy. Có thể thử lại." % w.city_name(here(w))
			log_line(w, tm)
			return _ok(tm, {"missed": true})
	var first: = not w.notebook.has(id)
	var n: = note(w, id)
	n["met_m"] = w.m
	n["met_t"] = now(w)
	if not n.has("first_city"):
		n["first_city"] = c.city_id
	n["seen"] = maxf(float(n.get("seen", 0.0)), c.max_real())
	if first and c.has_talent("tuc_tue") and w.life > 1:
		log_line(w, "%s nhìn bạn rất lâu, như đã quen từ một kiếp nào." % c.name)
	var keep: Array = []
	for l in w.play["leads"]:
		if str(l["id"]) != id:
			keep.append(l)
	w.play["leads"] = keep
	if first:
		w.play["stats"]["met"] = int(w.play["stats"]["met"]) + 1
	var t: = "Gặp %s (%s, %d tuổi, %s)." % [c.name, "nữ" if c.female else "nam", c.age(w.m), Defs.prof_name(c.profession).to_lower()]
	log_line(w, t)
	return _ok(t)



static func lead_of(w: World, id: String) -> Dictionary:
	for l in w.play["leads"]:
		if str(l["id"]) == id and str(l["city"]) == here(w):
			return l
	return {}



static func lead_miss_chance(w: World, lead: Dictionary) -> float:
	var old: = w.m - int(lead.get("m", w.m))
	var tri: = float(w.player().real[Defs.TRI])
	return clampf(0.15 + 0.1 * old - (tri - 30.0) / 300.0, 0.05, 0.5)




const VISIT_CAP: = 40.0
const AN_DAT_VISITS: = 3
const VISIT_GIFTS: = [
	{"name": "Tay không", "mult": 0.0, "gain": 0.0}, 
	{"name": "Lễ mọn", "mult": 1.0, "gain": 4.0}, 
	{"name": "Hậu lễ", "mult": 3.0, "gain": 9.0}, 
]


static func visits(w: World, id: String) -> int:
	return int(w.notebook.get(id, {}).get("visits", 0))



const CAREER_COST: = 30
const CAREER_COOLDOWN: = 12

const CAREERS: = ["thu_sinh", "lai_vien", "thay_thuoc", "binh_si", "vo_sinh", "thuong_nhan", "tieu_thuong", "tho_thu_cong", "tho_ren", "nong_dan", "nghe_nhan", "bien_si"]

const MI_ENVS: = {"van_dan": 1.8, "trieu_dinh": 1.3, "thuong_hoi": 1.3}

const CAREER_PLACE: = {"thu_sinh": "hoc_vien", "lai_vien": "hoc_vien", "binh_si": "quan_doanh", "vo_sinh": "quan_doanh", 
	"thuong_nhan": "thuong_hoi", "tho_thu_cong": "cong_xuong", "tho_ren": "cong_xuong", "nghe_nhan": "giao_du", "bien_si": "giao_du"}


static func career_block(w: World, c: Character) -> String:
	if c == null or not c.alive:
		return "Người này không còn trên đời."
	var ret: = is_retainer(w, c)
	if c.is_player:
		return "Không khuyên chính mình."
	if c.office_key != "" or c.patron != "":
		return "Người đang làm quan / thuộc thế gia khác không bỏ nghề theo lời bạn."
	if not w.notebook.has(c.id) or not w.notebook[c.id].has("appr"):
		return "Phải thẩm định trước mới biết nên khuyên nghề gì."
	if ret and not with_me(w, c):
		return "%s phải đang ở cùng bạn (theo hầu, hoặc ở tư trạch thành này)." % c.name
	if not ret and not met_now(w, c):
		return "Phải đang gặp %s (trong %d ngày, cùng thành)." % [c.name, MEET_WINDOW]
	var age: = c.age(w.m)
	if age < 12 or age > 50:
		return "Tuổi này (%d) không còn đổi nghề được." % age if age > 50 else "Còn quá nhỏ."
	if not c.career_try.is_empty():
		return "%s đang thử nghề mới." % c.name
	var until: = int(w.notebook[c.id].get("career_until", -1))
	if until > w.m:
		return "Vừa khuyên gần đây; đợi tới %s." % World.date_of(until)
	if money(w) < float(CAREER_COST):
		return "Cần %d lượng giúp vốn." % CAREER_COST
	return ""



static func career_chance(w: World, c: Character, pid: String) -> Dictionary:
	var parts: Array = []
	var p: = 0.45
	var mi: = (charm(w) - 40.0) / 300.0
	p += mi
	parts.append(["Mị lực của bạn", mi])
	if is_retainer(w, c):
		var lv: = (c.loyalty - 40.0) / 150.0
		p += lv
		parts.append(["Trung thành với bạn", lv])
	else:
		var fv: = c.favor / 200.0
		p += fv
		parts.append(["Ân tình", fv])
	var ag: = - maxf(0.0, float(c.age(w.m) - 25)) * 0.01
	p += ag
	parts.append(["Tuổi", ag])
	var yc: = - (c.y_chi - 50.0) / 300.0
	p += yc
	parts.append(["Ý chí (người cứng cỏi khó lay)", yc])
	var tr: = 0.0
	if c.has_trait("dung_cam") or c.has_trait("tham_vong"):
		tr += 0.1
	if c.has_trait("nhut_nhat") or c.has_trait("an_dat"):
		tr -= 0.1
	if tr != 0.0:
		p += tr
		parts.append(["Tính cách", tr])
	if CAREER_PLACE.has(pid):
		var pl: = 0.1 if study_place_ok(w, str(CAREER_PLACE[pid]), c.city_id) else -0.1
		p += pl
		parts.append(["Thành có cơ sở cho nghề" if pl > 0 else "Thành không có cơ sở cho nghề", pl])
	return {"p": clampf(p, 0.05, 0.9), "parts": parts}



static func career_quit_chance(c: Character, pid: String) -> float:
	var best: = 0.0
	for i in Defs.PROFESSIONS[pid]["focus"]:
		best = maxf(best, float(c.pot[int(i)]))
	if MI_ENVS.has(str(Defs.PROFESSIONS[pid]["env"])):
		best = maxf(best, c.mi_pot)
	var q: = 0.4 - maxf(0.0, best - 50.0) / 100.0 + (0.1 if c.y_chi < 40.0 else 0.0)
	return clampf(q, 0.08, 0.6)


static func advise_career(w: World, id: String, pid: String) -> Dictionary:
	var c: = w.ch(id)
	var err: = career_block(w, c)
	if err != "":
		return _fail(err)
	if not CAREERS.has(pid) or pid == c.profession:
		return _fail("Nghề không hợp lệ.")
	_spend(w, act_days(w, "career"))
	var n: = note(w, id)
	var ch: float = career_chance(w, c, pid)["p"]
	var old: = c.profession
	if w.rng(["career", id, w.m, pid]).randf() >= ch:
		c.favor = maxf(0.0, c.favor - 3.0)
		n["career_until"] = w.m + 3
		var tf: = "%s nghe xong chỉ lắc đầu: đã quen nghề %s, không muốn đổi sang %s." % [c.name, Defs.prof_name(old).to_lower(), Defs.prof_name(pid).to_lower()]
		log_line(w, tf)
		return _ok(tf, {"advised": false})
	w.clan["money"] = money(w) - float(CAREER_COST)
	_change_prof(w, c, pid)
	c.favor = minf(100.0, c.favor + 8.0)
	var check: = w.m + 6 + w.rng(["career_m", id, w.m]).randi_range(0, 6)
	c.career_try = {"from": old, "to": pid, "m": w.m, "check": check}
	n["uplift"] = true
	c.add_log(w.m, "Chuyển nghề %s → %s theo lời khuyên của %s" % [Defs.prof_name(old), Defs.prof_name(pid), w.player().name])
	var t: = "%s nhận lời bỏ nghề %s, theo nghề %s (giúp vốn %d lượng, ân tình +8). Vài tháng tới mới biết có trụ được không." % [c.name, Defs.prof_name(old).to_lower(), Defs.prof_name(pid).to_lower(), CAREER_COST]
	log_line(w, t)
	return _ok(t, {"advised": true})



static func _change_prof(w: World, c: Character, pid: String) -> void :
	if is_retainer(w, c):
		c.profession = pid
		setup_growth(w, c)
	else:
		c.set_profession(pid)



static func path_chance(w: World, c: Character) -> float:
	return clampf(float(career_chance(w, c, c.profession)["p"]) + 0.2, 0.05, 0.95)


static func advise_path(w: World, id: String, node_id: String) -> Dictionary:
	var c: = w.ch(id)
	var err: = career_block(w, c)
	if err != "":
		return _fail(err)
	var ok: = false
	for n in ProfTree.next_options(c):
		if str(n["id"]) == node_id:
			ok = true
	if not ok:
		return _fail("Nhánh này không đi tới được từ nghề hiện tại.")
	_spend(w, act_days(w, "career"))
	var nm: = str(ProfTree.node(c.profession, node_id)["name"])
	if w.rng(["advise_path", id, w.m, node_id]).randf() >= path_chance(w, c):
		note(w, id)["career_until"] = w.m + 3
		var tf: = "%s nghe nhưng vẫn muốn theo ý mình, không chắc sẽ theo hướng %s." % [c.name, nm]
		log_line(w, tf)
		return _ok(tf)
	c.prof_hint = node_id
	var t: = "%s nghe lời bạn: lần lên bậc tới sẽ hướng tới %s (còn khoảng %d tháng)." % [c.name, nm, ProfTree.months_to_next(c)]
	log_line(w, t)
	return _ok(t)



static func _career_checks(w: World) -> void :
	for c: Character in w.living():
		var ct: = c.career_try
		if ct.is_empty() or int(ct["check"]) > w.m:
			continue
		c.career_try = {}
		if c.office_key != "" or c.profession != str(ct["to"]):
			continue
		var name_to: = Defs.prof_name(str(ct["to"])).to_lower()
		if w.rng(["career_quit", c.id, int(ct["m"])]).randf() < career_quit_chance(c, str(ct["to"])):
			_change_prof(w, c, str(ct["from"]))
			c.add_log(w.m, "Bỏ dở nghề %s, quay về nghề cũ" % name_to)
			note(w, c.id)["career_until"] = w.m + CAREER_COOLDOWN
			report(w, "%s bỏ dở nghề %s, quay về làm %s." % [c.name, name_to, Defs.prof_name(str(ct["from"])).to_lower()])
		else:
			c.add_log(w.m, "Đã vững nghề %s" % name_to)
			report(w, "%s đã trụ vững với nghề %s mà bạn khuyên." % [c.name, name_to])


static func visit_block(w: World, c: Character) -> String:
	if c == null or not c.alive:
		return "Người này không còn trên đời."
	if c.is_player or is_retainer(w, c):
		return "Chỉ thăm hỏi người ngoài; môn khách đã ở trong nhà."
	if not w.notebook.has(c.id) or int(w.notebook[c.id].get("met_m", -99)) < 0:
		return "Phải Gặp gỡ %s lần đầu trước." % c.name
	if c.city_id != here(w):
		return "Phải đến %s." % w.city_name(c.city_id)
	if int(w.notebook[c.id].get("visit_m", -99)) == w.m:
		return "Đã thăm %s tháng này." % c.name
	return ""


static func gift_cost(w: World, c: Character, gift: int) -> int:
	return roundi((20.0 + perceived_best(w, c)) * float(VISIT_GIFTS[gift]["mult"]))




static func visit_gain(w: World, c: Character, gift: int, item_uid: int = -1) -> float:
	var g: = 3.0 + charm(w) / 25.0
	if c.has_trait("kieu_ngao") and clan_tier(w) < 2:
		g *= 0.5
	if c.has_trait("trung_hau"):
		g += 1.0
	var gg: = float(VISIT_GIFTS[gift]["gain"])
	var it: = Items.find_item(w, item_uid) if item_uid >= 0 else {}
	if not it.is_empty():
		gg = Items.gift_gain(c, it)
	if c.has_trait("tham_tai"):
		gg *= 1.5
	g += gg
	if int(w.notebook.get(c.id, {}).get("visit_m", -99)) == w.m - 1:
		g *= 0.6
	return clampf(minf(g, VISIT_CAP - c.favor), 0.0, 100.0)



static func visit(w: World, id: String, gift: int, item_uid: int = -1) -> Dictionary:
	var c: = w.ch(id)
	var err: = visit_block(w, c)
	if err != "":
		return _fail(err)
	if gift < 0 or gift >= VISIT_GIFTS.size():
		return _fail("Lễ vật không hợp lệ.")
	if item_uid >= 0:
		if Items.find_item(w, item_uid).is_empty():
			return _fail("Không có món này trong kho.")
		gift = 0
	var cost: = gift_cost(w, c, gift)
	if money(w) < float(cost):
		return _fail("Không đủ ngân lượng (cần %d)." % cost)
	if not _spend(w, act_days(w, "visit")):
		pass
	var gain: = visit_gain(w, c, gift, item_uid)
	w.clan["money"] = money(w) - float(cost)
	var what: = str(VISIT_GIFTS[gift]["name"]).to_lower()
	if item_uid >= 0:
		var it: = Items.give(w, item_uid, c)
		what = "tặng " + Items.name_of(str(it["k"]), int(it["q"]))
		if Items.likes(c, str(it["k"])):
			what += ", đúng thứ họ thích"
	c.favor = minf(100.0, c.favor + gain)
	var n: = note(w, id)
	n["met_m"] = w.m
	n["met_t"] = now(w)
	n["visit_m"] = w.m
	n["visits"] = int(n.get("visits", 0)) + 1
	var until: = int(w.play["refused"].get(id, -1))
	if until > w.m:
		w.play["refused"][id] = until - 2
	var t: = ""
	if gain > 0.0:
		t = "Thăm hỏi %s (%s): ân tình +%.0f → %.0f." % [c.name, what, gain, c.favor]
	else:
		t = "Thăm hỏi %s (%s). Ân tình %.0f, thăm hỏi không nâng thêm được; muốn thân hơn phải giúp họ việc lớn." % [c.name, what, c.favor]
	if c.has_trait("an_dat") and int(n["visits"]) == AN_DAT_VISITS:
		t += " Ba lần tới cửa, %s cảm động trước thành ý, chịu nghe lời mời ra giúp đời." % c.name
		report(w, t)
	log_line(w, t)
	return _ok(t, {"gain": gain})






static func appraise_redundant(w: World, c: Character, tier: int) -> String:
	var rec: Dictionary = w.notebook.get(c.id, {}).get("appr", {})
	if not rec.is_empty() and int(rec["m"]) == w.m and int(rec["tier"]) >= tier:
		return "Tháng này đã thẩm định %s ở tầng %s; thẩm định lại không thấy gì mới." % [c.name, Defs.TIER_NAMES[int(rec["tier"])]]
	return ""


static func appraise(w: World, id: String, tier: int) -> Dictionary:
	var c: = w.ch(id)
	if c == null or not c.alive:
		return _fail("Người này không còn trên đời.")
	if not met_now(w, c):
		return _fail("Phải gặp mặt %s (trong %d ngày qua) mới thẩm định được." % [c.name, MEET_WINDOW])
	if tier > eye_tier(w):
		return _fail("Đôi Mắt chưa đạt tầng %s (cần %d Ngộ đạo)." % [Defs.TIER_NAMES[tier], int(TIER_UNLOCK[tier])])
	var again: = appraise_redundant(w, c, tier)
	if again != "":
		return _fail(again)
	var cost: int = Defs.TIER_COST[tier]
	if int(w.play["eye"]) < cost:
		return _fail("Không đủ Nhãn lực (cần %d)." % cost)
	w.play["eye"] = int(w.play["eye"]) - cost
	var rec: = Appraisal.appraise(w, c, tier, w.player())
	var n: = note(w, id)
	var tiers: Array = n["tiers"]
	var gain: = 0
	if not tiers.has(tier):
		tiers.append(tier)
		gain += 1 + (2 if tier >= 3 else 0)
	if c.has_disguise() and not bool(rec["fake"]) and tier >= 2 and not n.get("exposed", false):
		n["exposed"] = true
		gain += 5
		var tx: = "Nhìn thấu lớp ngụy trang của %s!" % c.name
		log_line(w, tx)
		report(w, tx)
	rec.erase("fake")
	rec.erase("masked")
	n["appr"] = rec
	n["seen"] = c.max_real()
	var pred: Array = n["pred"]
	for i in Defs.N_STATS:
		var pb: Array = rec["pot"][i]
		var rb: Array = rec["real"][i]
		if not pb.is_empty() and int(pb[1]) >= 75 and int(rb[1]) < 60 and not pred.has(i):
			pred.append(i)
	w.play["stats"]["appraised"] = int(w.play["stats"]["appraised"]) + 1
	_add_ngo(w, gain)
	var t: = "Thẩm định %s tầng %s (−%d Nhãn lực)." % [c.name, Defs.TIER_NAMES[tier], cost]
	log_line(w, t)
	return _ok(t, {"rec": rec})



static func impression(w: World, c: Character) -> Dictionary:
	var rec: = Appraisal.appraise(w, c, 0, w.player())
	var obs: Dictionary = w.notebook.get(c.id, {}).get("obs", {})
	for k in obs:
		var i: = int(k)
		var ob: Array = obs[k]
		var cur: Array = rec["mi_real"] if i == Defs.N_STATS else rec["real"][i]
		var nb: Array = ob
		if not cur.is_empty() and maxi(int(cur[0]), int(ob[0])) <= mini(int(cur[1]), int(ob[1])):
			nb = [maxi(int(cur[0]), int(ob[0])), mini(int(cur[1]), int(ob[1]))]
		if i == Defs.N_STATS:
			rec["mi_real"] = nb
		else:
			rec["real"][i] = nb
	return rec




static func perceived_best(w: World, c: Character) -> float:
	var best: = 0.0
	for i in Defs.N_STATS:
		best = maxf(best, Appraisal.perceived_real(w, c, i))
	return best


static func recruit_block(w: World, c: Character) -> String:
	if c == null or not c.alive:
		return "Người này không còn trên đời."
	if c.is_player:
		return "Không thể tự chiêu mộ mình."
	if is_retainer(w, c):
		return "%s đã là môn khách của bạn." % c.name
	if c.hates_player:
		return "%s biết bạn đứng sau việc hãm hại mình, không đời nào theo bạn." % c.name
	if c.office_key != "" or (c.nation_id != "" and c.idle_until < 0):
		return "%s đang phục vụ triều đình %s, không chiêu mộ được." % [c.name, w.nation_name(c.nation_id)]
	if c.age(w.m) < 14:
		return "Còn quá nhỏ."
	if not met_now(w, c):
		return "Phải Gặp gỡ %s trước (gặp trong %d ngày qua và còn ở cùng thành)." % [c.name, MEET_WINDOW]
	if c.special == "gia_chu":
		return "%s là gia chủ %s, không thể mời làm môn khách." % [c.name, Rivals.of(w, c).get("name", "một thế gia")]
	if free_slot(w) == "":
		return "Hết chỗ: %s, theo hầu đã đủ %d người. Mua / mở rộng tư trạch ở đây, sắm xe ngựa, hoặc tiến cử bớt." % ["tư trạch ở %s đã đầy" % w.city_name(here(w)) if house_cap(w, here(w)) > 0 else "chưa có tư trạch ở %s" % w.city_name(here(w)), follow_cap(w)]
	var until: = int(w.play["refused"].get(c.id, -1))
	if until > w.m:
		return "%s vừa từ chối bạn, phải đợi tới %s." % [c.name, World.date_of(until)]
	return ""




static func recruit_factors(w: World, c: Character, lavish: bool) -> Array:
	var f: Array = []
	var ct: = clan_tier(w)
	_fac(f, "Gia thế %s" % CLAN_TIER_NAMES[ct], (ct - 1) * 8.0, false)
	_fac(f, "Uy tín gia tộc", prestige(w) / 20.0, false)
	var ch: = charm(w)
	_fac(f, "Mị lực của bạn" if ch == Items.eff_mi(w.player()) else "Mị lực (môn khách Thuyết khách)", (ch - 25.0) / 3.0, false)
	_fac(f, "Danh vọng của họ" + (" (người có tiếng khó mời)" if c.fame > 30.0 else " (vô danh, dễ mời)"), (30.0 - c.fame) / 2.0, false)
	if lavish:
		_fac(f, "Hậu đãi", 15.0, false)
	_fac(f, "Ân tình với bạn", c.favor / 2.0, false)
	if is_martial(c):
		_fac(f, "Võ lực của bạn (họ trọng võ)", martial_recruit_bonus(w), false)
	_fac(f, "Tham vọng của họ", - c.tham_vong / 4.0, true)
	_fac(f, "Mị lực cao, được nhiều nơi săn đón", - maxf(0.0, c.mi_real - 60.0) / 5.0, true)
	if c.has_trait("tham_tai") and lavish:
		_fac(f, "Tham tài: ham lễ hậu", 10.0, true)
	if c.has_trait("an_dat") and c.favor < 30.0 and visits(w, c.id) < AN_DAT_VISITS:
		_fac(f, "Ẩn dật: không muốn ra (đã thăm hỏi %d/%d lần, hoặc ân tình ≥ 30)" % [visits(w, c.id), AN_DAT_VISITS], -25.0, true)
	if c.has_trait("kieu_ngao") and ct < 2:
		_fac(f, "Kiêu ngạo: chê nhà bạn Hàn môn", -10.0, true)
	if c.has_trait("trung_hau"):
		_fac(f, "Trung hậu", 5.0, true)
	if c.patron != "":
		_fac(f, "Đang là môn khách của %s" % Rivals.of(w, c).get("name", "thế gia khác"), - (15.0 + maxf(0.0, c.loyalty - 50.0) / 2.0), false)
	elif Rivals.orphan(w, c):
		_fac(f, "Vừa mất chủ, đang tìm nơi nương tựa", 15.0, false)
	if c.office_key == "" and Appointment.shamed(w, c):
		_fac(f, "Bị hãm hại mất chức, chán quan trường", 15.0, false)
	elif c.office_key == "" and c.nation_id != "" and c.idle_until >= 0:
		_fac(f, "Cựu quan còn mong được dùng lại", -5.0, false)
	return f


static func _fac(f: Array, t: String, v: float, hid: bool) -> void :
	if v != 0.0:
		f.append({"t": t, "v": v, "hid": hid})


const RECRUIT_BASE: = 45.0


static func recruit_preview(w: World, c: Character, lavish: bool) -> Dictionary:
	var pv: = perceived_best(w, c)
	var fee: = roundi((50.0 + pv * 4.0) * (2.0 if lavish else 1.0))
	var salary: = roundi(3.0 + pv / 8.0)
	var s: = RECRUIT_BASE
	for x in recruit_factors(w, c, lavish):
		s += float(x["v"])
	var chance: = clampf((s - 40.0) / 20.0, 0.0, 1.0)
	return {"fee": fee, "salary": salary, "score": s, "chance": chance}


static func is_martial(c: Character) -> bool:
	return c.top_pot() == Defs.VO or c.top_pot() == Defs.QUAN or Events.RISKY_PROF.has(c.profession)



static func martial_recruit_bonus(w: World) -> float:
	return maxf(0.0, (Items.eff_vo(w.player()) - 30.0) / 3.0)


static func chance_words(ch: float) -> String:
	if ch >= 0.85:
		return "gần như chắc chắn nhận lời"
	if ch >= 0.6:
		return "có vẻ sẵn lòng"
	if ch >= 0.35:
		return "còn do dự"
	if ch > 0.0:
		return "khó lay chuyển"
	return "sẽ không nhận lời"











const HOUSE_CAP: = 4
const HOUSE_CAP_BIG: = 6
const HOUSE_UPKEEP: = 10.0
const FOLLOW_BASE: = 2
const CART_MAX: = 2
const CART_COST: = 300
const CART_UPKEEP: = 5.0
const HOUSE_DAYS: = 2
const INN_DAYS: = 15
const INN_COST_DAY: = 3
const LETDOWN_LOYALTY: = 10.0


const STUDY_TASKS: = ["quan_doanh", "hoc_vien", "thuong_hoi", "cong_xuong", "giao_du"]


const BOTH_MULT: = 0.75



static func studies(w: World) -> Dictionary:
	if not w.play.has("study"):
		var st: = {}
		for id in w.play["tasks"].keys():
			if STUDY_TASKS.has(str(w.play["tasks"][id])):
				st[id] = str(w.play["tasks"][id])
				w.play["tasks"][id] = ""
		w.play["study"] = st
	return w.play["study"]


static func study_of(w: World, c: Character) -> String:
	return str(studies(w).get(c.id, ""))


static func job_of(w: World, c: Character) -> String:
	studies(w)
	return str(w.play["tasks"].get(c.id, ""))



static func study_pause(w: World, c: Character) -> String:
	var st: = study_of(w, c)
	if st == "":
		return ""
	if on_road(w, c):
		return "đang trên đường"
	if not at_house(w, c):
		return "đang ở trọ" if at_inn(w, c) else "đang theo hầu, không ở tư trạch"
	if not study_place_ok(w, st, task_city(w, c)):
		return "%s không có %s" % [w.city_name(task_city(w, c)), str(STUDY_PLACES[st]["what"]).split(" (")[0]]
	return ""


static func study_on(w: World, c: Character) -> bool:
	return study_of(w, c) != "" and study_pause(w, c) == ""


static func job_on(w: World, c: Character) -> bool:
	return job_of(w, c) != "" and task_pause(w, c) == ""



static func both_on(w: World, c: Character) -> bool:
	return study_on(w, c) and job_on(w, c) and HOUSE_TASKS.has(job_of(w, c))


static func task_focus(task: String) -> Array:
	match task:
		"kinh_doanh":
			return [Defs.THUONG, Defs.TRI]
		"giao_du":
			return [Defs.CHINH]
		"quan_gia":
			return [Defs.CHINH, Defs.TRI]
		"ho_ve":
			return [Defs.VO]
		"thuyet_khach":
			return [Defs.TRI, Defs.CHINH]
		"day_do", "mat_tham":
			return [Defs.TRI] if task == "day_do" else [Defs.TRI, Defs.CHINH]
	var f: Array = []
	for x in Defs.ENVS[str(TASKS[task]["env"])]["stats"]:
		f.append(int(x))
	return f



const TASK_PROF: = {
	"hoc_vien": ["thu_sinh", "lai_vien", "thay_thuoc"], "quan_doanh": ["binh_si", "vo_sinh", "kiem_khach"], 
	"thuong_hoi": ["thuong_nhan", "tieu_thuong"], "cong_xuong": ["tho_thu_cong", "tho_ren"], "giao_du": ["nghe_nhan", "bien_si"], 
	"kinh_doanh": ["thuong_nhan", "tieu_thuong"], "ho_ve": ["vo_sinh", "kiem_khach", "binh_si"], "thuyet_khach": ["bien_si"], 
	"quan_gia": ["lai_vien"], "day_do": ["thu_sinh", "vo_sinh"], "mat_tham": ["lai_vien"], 
}



static func setup_growth(w: World, c: Character) -> void :
	c.env_bonus = 1.0
	var active: = ""
	if study_on(w, c):
		active = study_of(w, c)
	elif job_on(w, c):
		active = job_of(w, c)
	c.task_stats = task_focus(active) if active != "" else []
	c.prof_on = active == "" or (TASK_PROF.get(active, []) as Array).has(c.profession)
	if active == "":
		c.set_profession(c.profession)
		return
	c.env = task_env(active)
	c.focus = task_focus(active)
	if at_house(w, c):
		for f in TASK_FEATURE.get(active, []):
			if w.has_feature(str(loc(w, c)["city"]), str(f)):
				c.env_bonus = TASK_FEATURE_MULT
	if both_on(w, c):
		c.env_bonus *= BOTH_MULT


static func set_study(w: World, id: String, task: String) -> Dictionary:
	var c: = w.ch(id)
	if c == null or not is_retainer(w, c):
		return _fail("Chỉ cho môn khách đi học.")
	if task == "":
		studies(w).erase(id)
		setup_growth(w, c)
		var t0: = "Cho %s thôi học." % c.name
		log_line(w, t0)
		return _ok(t0)
	if not STUDY_TASKS.has(task):
		return _fail("Việc học không hợp lệ.")
	var sb: = study_block(w, c, task)
	if sb != "":
		return _fail(sb + " Điều %s tới thành có cơ sở rồi cho đi học." % c.name)
	studies(w)[id] = task
	setup_growth(w, c)
	var t: = "Cho %s đi học: %s%s." % [c.name, TASKS[task]["name"], " (vừa học vừa làm: cả hai ×0,75)" if both_on(w, c) else ""]
	log_line(w, t)
	return _ok(t)



static func task_list(study: bool) -> Array:
	return TASK_ORDER.filter( func(t: String) -> bool: return t == "" or STUDY_TASKS.has(t) == study)


const HOUSE_TASKS: = ["quan_doanh", "hoc_vien", "thuong_hoi", "cong_xuong", "giao_du", "kinh_doanh", "quan_gia"]
const FOLLOW_TASKS: = ["ho_ve", "thuyet_khach"]

const TASK_FEATURE: = {"quan_doanh": ["vo_duong"], "hoc_vien": ["hoc_phu"], "thuong_hoi": ["cang", "tram_dich"], 
	"kinh_doanh": ["cang", "tram_dich"], "cong_xuong": ["mo_sat", "xuong_lua", "bai_ngua"]}
const TASK_FEATURE_MULT: = 1.3

const STUDY_PLACES: = {
	"hoc_vien": {"feat": ["hoc_phu"], "stat": "giao_duc", "min": 60, "what": "học viện (Học phủ, hoặc Giáo dục ≥ 60)"}, 
	"quan_doanh": {"feat": ["vo_duong"], "stat": "quan_su", "min": 60, "front": true, "what": "quân doanh (Võ đường, Quân sự ≥ 60, hoặc tiền tuyến)"}, 
	"thuong_hoi": {"feat": ["cang"], "stat": "kinh_te", "min": 60, "what": "thương hội (Bến cảng, hoặc Kinh tế ≥ 60)"}, 
	"cong_xuong": {"feat": ["mo_sat", "xuong_lua"], "stat": "sx", "min": 60, "what": "công xưởng (Mỏ sắt / Xưởng lụa, hoặc Sản xuất ≥ 60)"}, 
	"giao_du": {"feat": [], "stat": "kinh_te", "min": 65, "capital": true, "what": "văn đàn, tửu lâu (kinh đô, hoặc Kinh tế ≥ 65)"}, 
}



static func study_place_ok(w: World, task: String, cid: String) -> bool:
	if not STUDY_PLACES.has(task):
		return true
	var sp: Dictionary = STUDY_PLACES[task]
	for f in sp["feat"]:
		if w.has_feature(cid, str(f)):
			return true
	if float(w.cities[cid].get(str(sp["stat"]), 0)) >= float(sp["min"]):
		return true
	if bool(sp.get("capital", false)):
		for nid in w.nations:
			if str(w.nations[nid]["capital"]) == cid:
				return true
	if bool(sp.get("front", false)):
		for nid in w.nations:
			for wr in War.wars_of(w, nid):
				if str(wr["front"]) == cid:
					return true
	return false



static func task_city(w: World, c: Character) -> String:
	var l: = loc(w, c)
	return str(l.get("city", here(w))) if str(l.get("st", "")) != "road" else str(l.get("to", here(w)))



static func study_block(w: World, c: Character, task: String) -> String:
	if not STUDY_PLACES.has(task):
		return ""
	var cid: = task_city(w, c)
	if study_place_ok(w, task, cid):
		return ""
	return "%s không có %s." % [w.city_name(cid), STUDY_PLACES[task]["what"]]



static func study_places_near(w: World, task: String, from: String, n: int = 3) -> Array:
	var res: Array = []
	for cid in w.cities:
		if str(cid) != from and study_place_ok(w, task, str(cid)):
			res.append([str(cid), path_days(w, from, str(cid))])
	res.sort_custom( func(a: Array, b: Array) -> bool: return int(a[1]) < int(b[1]))
	return res.slice(0, n)



static func ensure_houses(w: World) -> void :
	if not w.clan.has("houses"):
		w.clan["houses"] = {str(w.clan["city"]): {"cap": HOUSE_CAP}}
		w.clan["carts"] = 0
	if not w.play.has("ret"):
		w.play["ret"] = {}
	var ret: Dictionary = w.play["ret"]
	for id in w.clan["retainers"]:
		if not ret.has(id):
			ret[id] = {"st": "house", "city": str(w.clan["city"])}
	for id in ret.keys():
		if not (w.clan["retainers"] as Array).has(id):
			ret.erase(id)


static func loc(w: World, c: Character) -> Dictionary:
	ensure_houses(w)
	return w.play["ret"].get(c.id, {})


static func is_following(w: World, c: Character) -> bool:
	return str(loc(w, c).get("st", "")) == "follow"


static func at_house(w: World, c: Character) -> bool:
	return str(loc(w, c).get("st", "")) == "house"


static func on_road(w: World, c: Character) -> bool:
	return str(loc(w, c).get("st", "")) == "road"


static func at_inn(w: World, c: Character) -> bool:
	return str(loc(w, c).get("st", "")) == "inn"



static func with_me(w: World, c: Character) -> bool:
	var l: = loc(w, c)
	var st: = str(l.get("st", ""))
	return st == "follow" or ((st == "house" or st == "inn") and str(l["city"]) == here(w))


static func houses(w: World) -> Dictionary:
	ensure_houses(w)
	return w.clan["houses"]


static func house_cap(w: World, cid: String) -> int:
	return int(houses(w).get(cid, {}).get("cap", 0))



static func house_count(w: World, cid: String) -> int:
	var n: = 0
	for id in w.play["ret"]:
		var l: Dictionary = w.play["ret"][id]
		if (str(l["st"]) == "house" and str(l["city"]) == cid) or (str(l["st"]) == "road" and str(l["to"]) == cid and not bool(l.get("inn", false))):
			n += 1
	return n


static func follow_cap(w: World) -> int:
	ensure_houses(w)
	return FOLLOW_BASE + int(w.clan.get("carts", 0))


static func follow_count(w: World) -> int:
	var n: = 0
	for c: Character in retainers(w):
		if is_following(w, c):
			n += 1
	return n



static func free_slot(w: World) -> String:
	var cid: = here(w)
	if house_cap(w, cid) > house_count(w, cid):
		return "house"
	if follow_count(w) < follow_cap(w):
		return "follow"
	return ""


static func house_price(w: World, cid: String) -> int:
	var city: Dictionary = w.cities[cid]
	return roundi(300.0 + float(city["kinh_te"]) * 10.0 + float(city["pop"]) / 1000.0)


static func buy_house(w: World) -> Dictionary:
	var cid: = here(w)
	if house_cap(w, cid) > 0:
		return _fail("Đã có tư trạch ở %s." % w.city_name(cid))
	var price: = house_price(w, cid)
	if money(w) < float(price):
		return _fail("Cần %d lượng." % price)
	_spend(w, HOUSE_DAYS)
	w.clan["money"] = money(w) - float(price)
	houses(w)[cid] = {"cap": HOUSE_CAP}
	var t: = "Mua tư trạch ở %s (%d lượng, ở được %d môn khách, phí giữ nhà %d lượng/tháng)." % [w.city_name(cid), price, HOUSE_CAP, int(HOUSE_UPKEEP)]
	log_line(w, t)
	return _ok(t)


static func expand_house(w: World) -> Dictionary:
	var cid: = here(w)
	var cap: = house_cap(w, cid)
	if cap == 0:
		return _fail("Chưa có tư trạch ở %s." % w.city_name(cid))
	if cap >= HOUSE_CAP_BIG:
		return _fail("Tư trạch ở %s đã mở rộng rồi." % w.city_name(cid))
	var price: = roundi(house_price(w, cid) / 2.0)
	if money(w) < float(price):
		return _fail("Cần %d lượng." % price)
	_spend(w, HOUSE_DAYS)
	w.clan["money"] = money(w) - float(price)
	houses(w)[cid]["cap"] = HOUSE_CAP_BIG
	var t: = "Mở rộng tư trạch ở %s: ở được %d môn khách (%d lượng)." % [w.city_name(cid), HOUSE_CAP_BIG, price]
	log_line(w, t)
	return _ok(t)


static func buy_cart(w: World) -> Dictionary:
	ensure_houses(w)
	if int(w.clan["carts"]) >= CART_MAX:
		return _fail("Đã có đủ %d xe ngựa." % CART_MAX)
	if money(w) < float(CART_COST):
		return _fail("Cần %d lượng." % CART_COST)
	w.clan["money"] = money(w) - float(CART_COST)
	w.clan["carts"] = int(w.clan["carts"]) + 1
	var t: = "Sắm xe ngựa: thêm 1 người theo hầu (nay %d)." % follow_cap(w)
	log_line(w, t)
	return _ok(t)



static func take_along(w: World, id: String) -> Dictionary:
	var c: = w.ch(id)
	if c == null or not is_retainer(w, c):
		return _fail("Không phải môn khách.")
	var l: = loc(w, c)
	if not (str(l["st"]) == "house" or str(l["st"]) == "inn") or str(l["city"]) != here(w):
		return _fail("%s không ở %s." % [c.name, w.city_name(here(w))])
	if follow_count(w) >= follow_cap(w):
		return _fail("Đã đủ %d người theo hầu (sắm thêm xe ngựa để mang nhiều người hơn)." % follow_cap(w))
	w.play["ret"][id] = {"st": "follow"}
	var t: = "%s theo hầu bạn.%s" % [c.name, _task_pause_note(w, c)]
	log_line(w, t)
	return _ok(t)



static func leave_here(w: World, id: String) -> Dictionary:
	var c: = w.ch(id)
	if c == null or not is_retainer(w, c) or not (is_following(w, c) or (at_inn(w, c) and str(loc(w, c)["city"]) == here(w))):
		return _fail("Người này không theo hầu bạn.")
	var cid: = here(w)
	if house_cap(w, cid) == 0:
		return _fail("Chưa có tư trạch ở %s." % w.city_name(cid))
	if house_count(w, cid) >= house_cap(w, cid):
		return _fail("Tư trạch ở %s đã đầy (%d người)." % [w.city_name(cid), house_cap(w, cid)])
	w.play["ret"][id] = {"st": "house", "city": cid}
	c.city_id = cid
	var t: = "%s ở lại tư trạch %s.%s" % [c.name, w.city_name(cid), _task_pause_note(w, c)]
	log_line(w, t)
	return _ok(t)



static func path_days(w: World, a: String, b: String) -> int:
	if a == b:
		return 0
	var dist: = {a: 0}
	var todo: Array = [a]
	while not todo.is_empty():
		var bi: = 0
		for i in todo.size():
			if int(dist[todo[i]]) < int(dist[todo[bi]]):
				bi = i
		var cur: String = todo[bi]
		todo.remove_at(bi)
		var links: Dictionary = w.cities[cur]["links"]
		for nb in links:
			if not w.cities.has(nb):
				continue
			var d: = int(dist[cur]) + int(links[nb]) * (SEA_DAYS if World.is_sea(cur, nb) else LAND_DAYS)
			if not dist.has(nb) or d < int(dist[nb]):
				dist[nb] = d
				todo.append(nb)
	return int(dist.get(b, -1))



static func letter_days(w: World, to: String) -> int:
	var d: = path_days(w, here(w), to)
	if w.has_feature(here(w), "tram_dich"):
		d = ceili(d / 2.0)
	return maxi(0, d)



static func _ret_city(w: World, c: Character) -> String:
	var l: = loc(w, c)
	return here(w) if str(l["st"]) == "follow" else str(l["city"])



static func send_days(w: World, c: Character, to: String) -> Array:
	var from: = _ret_city(w, c)
	var letter: = 0 if is_following(w, c) else letter_days(w, from)
	return [letter, path_days(w, from, to)]



static func sends_to_inn(w: World, to: String) -> bool:
	return house_cap(w, to) <= house_count(w, to)


static func inn_cost() -> int:
	return INN_DAYS * INN_COST_DAY


static func send_block(w: World, c: Character, to: String) -> String:
	if c == null or not is_retainer(w, c):
		return "Không phải môn khách."
	if on_road(w, c):
		return "%s đang trên đường." % c.name
	if _ret_city(w, c) == to:
		return "%s đang ở %s rồi." % [c.name, w.city_name(to)]
	if path_days(w, _ret_city(w, c), to) < 0:
		return "Không có đường tới %s." % w.city_name(to)
	if sends_to_inn(w, to) and money(w) < float(inn_cost()):
		return "Cần %d lượng tiền trọ (không có chỗ ở tư trạch)." % inn_cost()
	return ""



static func _home_of(w: World, c: Character) -> String:
	var l: = loc(w, c)
	if str(l["st"]) == "house":
		return str(l["city"])
	if l.has("home") and house_cap(w, str(l["home"])) > 0:
		return str(l["home"])
	return str(w.clan["city"])




static func send(w: World, id: String, to: String) -> Dictionary:
	var c: = w.ch(id)
	var err: = send_block(w, c, to)
	if err != "":
		return _fail(err)
	var sd: = send_days(w, c, to)
	var inn: = sends_to_inn(w, to)
	var at: = now(w) + int(sd[0]) + int(sd[1])
	var home: = _home_of(w, c)
	w.play["ret"][id] = {"st": "road", "city": _ret_city(w, c), "to": to, "at": at, "home": home, "inn": inn}
	var t: = "Điều %s tới %s: thư đi %d ngày, đường đi %d ngày, tới khoảng %s." % [c.name, w.city_name(to), int(sd[0]), int(sd[1]), date_of_day(at)]
	if inn:
		w.clan["money"] = money(w) - float(inn_cost())
		t += " Không có chỗ ở tư trạch nên sẽ ở trọ chờ bạn %d ngày (%d lượng); quá hạn không gặp thì thất vọng, quay về %s." % [INN_DAYS, inn_cost(), w.city_name(home)]
	log_line(w, t)
	return _ok(t)


static func date_of_day(t: int) -> String:
	return "ngày %d %s" % [t % MONTH_DAYS + 1, World.date_of(floori(t / float(MONTH_DAYS)))]




static func _arrivals(w: World) -> void :
	if not w.play.has("ret"):
		return
	var t_now: = now(w)
	for id in w.play["ret"].keys():
		var l: Dictionary = w.play["ret"][id]
		var c: = w.ch(str(id))
		if str(l["st"]) == "road" and int(l["at"]) <= t_now:
			var to: = str(l["to"])
			if house_cap(w, to) > house_count(w, to) or ( not bool(l.get("inn", false)) and house_cap(w, to) > 0):
				w.play["ret"][id] = {"st": "house", "city": to}
				if c != null:
					c.city_id = to
					report(w, "%s đã tới tư trạch %s." % [c.name, w.city_name(to)])
			else:
				var until: = int(l["at"]) + INN_DAYS
				w.play["ret"][id] = {"st": "inn", "city": to, "until": until, "home": str(l.get("home", w.clan["city"])), "met": here(w) == to}
				if c != null:
					c.city_id = to
					var tx: = "%s đã tới %s, ở trọ chờ bạn tới %s." % [c.name, w.city_name(to), date_of_day(until)]
					log_line(w, tx)
					report(w, tx)
		elif str(l["st"]) == "inn":
			if str(l["city"]) == here(w):
				l["met"] = true
			if int(l["until"]) <= t_now:
				var home: = str(l["home"]) if house_cap(w, str(l["home"])) > 0 else str(w.clan["city"])
				var back: = maxi(0, path_days(w, str(l["city"]), home))
				w.play["ret"][id] = {"st": "road", "city": str(l["city"]), "to": home, "at": int(l["until"]) + back, "home": home, "inn": false}
				if c != null:
					var t2: = "%s chờ ở %s hết %d ngày, quay về tư trạch %s." % [c.name, w.city_name(str(l["city"])), INN_DAYS, w.city_name(home)]
					if not bool(l["met"]):
						c.loyalty = maxf(0.0, c.loyalty - LETDOWN_LOYALTY)
						t2 = "%s chờ ở %s %d ngày mà không gặp được bạn, thất vọng quay về tư trạch %s (Trung thành −%d)." % [c.name, w.city_name(str(l["city"])), INN_DAYS, w.city_name(home), int(LETDOWN_LOYALTY)]
					log_line(w, t2)
					report(w, t2)



static func _sync_retainers(w: World) -> void :
	ensure_houses(w)
	for c: Character in retainers(w):
		var l: = loc(w, c)
		match str(l.get("st", "")):
			"follow":
				c.city_id = here(w)
			"house", "inn":
				c.city_id = str(l["city"])



static func task_pause(w: World, c: Character) -> String:
	var task: = str(w.play["tasks"].get(c.id, ""))
	if task == "":
		return ""
	if on_road(w, c):
		return "đang trên đường"
	if HOUSE_TASKS.has(task) and not at_house(w, c):
		return "đang ở trọ" if at_inn(w, c) else "đang theo hầu, không ở tư trạch"
	if FOLLOW_TASKS.has(task) and not is_following(w, c):
		return "không theo hầu bạn"
	if task == "day_do":
		var st: = w.ch(str(w.play.get("teach", {}).get(c.id, "")))
		if st == null or on_road(w, st) or st.city_id != c.city_id:
			return "trò không ở cùng nơi"
	if STUDY_PLACES.has(task) and not study_place_ok(w, task, task_city(w, c)):
		return "%s không có %s" % [w.city_name(task_city(w, c)), str(STUDY_PLACES[task]["what"]).split(" (")[0]]
	return ""


static func _task_pause_note(w: World, c: Character) -> String:
	var ps: = task_pause(w, c)
	return "" if ps == "" else " Việc \"%s\" tạm ngưng (%s)." % [TASKS[str(w.play["tasks"].get(c.id, ""))]["name"], ps]



static func task_env(task: String) -> String:
	match task:
		"kinh_doanh":
			return "thuong_hoi"
		"ho_ve":
			return "quan_doanh"
		"thuyet_khach":
			return "trieu_dinh"
		"giao_du":
			return "van_dan"
		"", "quan_gia", "day_do", "mat_tham":
			return ""
	return str(TASKS[task]["env"])



static func _apply_task_env(w: World) -> void :
	for c: Character in retainers(w):
		setup_growth(w, c)


static func loc_text(w: World, c: Character) -> String:
	var l: = loc(w, c)
	match str(l.get("st", "")):
		"follow":
			return "theo hầu"
		"house":
			return "ở %s" % w.city_name(str(l["city"]))
		"road":
			return "→ %s (%s)" % [w.city_name(str(l["to"])), date_of_day(int(l["at"]))]
		"inn":
			return "ở trọ %s (chờ tới %s)" % [w.city_name(str(l["city"])), date_of_day(int(l["until"]))]
	return "?"


static func recruit(w: World, id: String, lavish: bool) -> Dictionary:
	var c: = w.ch(id)
	var err: = recruit_block(w, c)
	if err != "":
		return _fail(err)
	var pr: = recruit_preview(w, c, lavish)
	if money(w) < float(pr["fee"]):
		return _fail("Không đủ ngân lượng (cần %d)." % int(pr["fee"]))
	if not _spend(w, act_days(w, "recruit")):
		pass
	var r: = w.rng(["recruit", id])
	if float(pr["score"]) + r.randf_range(-10.0, 10.0) < 50.0:
		w.play["refused"][id] = w.m + 6
		var tf: = "%s khéo léo từ chối lời mời của %s." % [c.name, w.clan["name"]]
		log_line(w, tf)

		var worst: Dictionary = {}
		for f in recruit_factors(w, c, lavish):
			if float(f["v"]) < 0.0 and (worst.is_empty() or float(f["v"]) < float(worst["v"])):
				worst = f
		var known: = (w.notebook.get(id, {}).get("appr", {}) as Dictionary).has("traits")
		var why: = ""
		if not worst.is_empty():
			why = str(worst["t"]) if ( not bool(worst["hid"]) or known) else "có điều gì đó trong tính cách hay chí hướng của họ (thẩm định Cao cấp để biết)"
		return _ok(tf, {"accepted": false, "until": int(w.play["refused"][id]), "why": why, "score": float(pr["score"])})
	w.clan["money"] = money(w) - float(pr["fee"])
	if c.patron != "":
		var rv: Dictionary = Rivals.of(w, c)
		if not rv.is_empty():
			(rv["retainers"] as Array).erase(c.id)
			Rivals.on_offended(w, str(rv["id"]), 20.0, "bạn lôi kéo %s" % c.name)
		c.patron = ""
	var slot: = free_slot(w)
	c.nation_id = ""
	c.faction_id = ""
	c.idle_until = -1
	c.clan_retainer = true
	c.city_id = here(w)
	w.play["ret"][id] = {"st": "house", "city": here(w)} if slot == "house" else {"st": "follow"}
	c.loyalty = minf(100.0, 60.0 + c.favor / 4.0)
	c.favor = minf(100.0, c.favor + 10.0)
	(w.clan["retainers"] as Array).append(id)
	w.play["tasks"][id] = ""
	w.play["salary"][id] = int(pr["salary"])
	c.purse += float(pr["fee"]) * 0.5
	note(w, id)
	c.add_log(w.m, "Nhận lời làm môn khách của %s" % w.clan["name"])
	w.play["stats"]["recruited"] = int(w.play["stats"]["recruited"]) + 1
	var t: = "%s nhận lời làm môn khách (lễ vật %d lượng, lương %d/tháng), %s." % [c.name, int(pr["fee"]), int(pr["salary"]), "ở tư trạch %s" % w.city_name(here(w)) if slot == "house" else "theo hầu bạn"]
	log_line(w, t)
	return _ok(t, {"accepted": true, "fee": int(pr["fee"]), "salary": int(pr["salary"]), "slot": slot})


static func assign(w: World, id: String, task: String, student: String = "") -> Dictionary:
	var c: = w.ch(id)
	if c == null or not is_retainer(w, c):
		return _fail("Chỉ giao việc được cho môn khách.")
	if not TASKS.has(task):
		return _fail("Việc không hợp lệ.")
	if STUDY_TASKS.has(task):
		return set_study(w, id, task)
	studies(w)
	if task == "day_do":
		var st: = w.ch(student)
		if st == null or not is_retainer(w, st) or student == id:
			return _fail("Phải chọn một môn khách khác làm học trò.")
	if not w.play.has("teach"):
		w.play["teach"] = {}
	w.play["teach"].erase(id)
	w.play["tasks"][id] = task
	var td: Dictionary = TASKS[task]
	if task == "day_do":
		w.play["teach"][id] = student
	setup_growth(w, c)
	var t: = "Giao cho %s: %s." % [c.name, td["name"]]
	if study_of(w, c) != "" and task != "":
		t += " Việc học (%s) vẫn giữ: %s." % [TASKS[study_of(w, c)]["name"], "vừa học vừa làm, cả hai ×0,75" if both_on(w, c) else ("học khi về tư trạch" if not at_house(w, c) or FOLLOW_TASKS.has(task) else "đang học")]
	if task == "day_do":
		var eff: = mentor_effect(w, c, w.ch(student))
		t = "%s nhận kèm %s về %s (hiệu quả: %s)." % [c.name, w.ch(student).name, Defs.STAT_NAMES[int(eff["stat"])], eff["word"]]
		apply_teaching(w)
	log_line(w, t)
	return _ok(t)


static func dismiss(w: World, id: String) -> Dictionary:
	var c: = w.ch(id)
	if c == null or not is_retainer(w, c):
		return _fail("Người này không phải môn khách.")
	_release(w, c)
	Items.reclaim(w, c)
	c.loyalty = maxf(0.0, c.loyalty - 20.0)
	var t: = "Cho %s rời khỏi gia tộc." % c.name
	log_line(w, t)
	return _ok(t)


static func _release(w: World, c: Character) -> void :
	var teach: Dictionary = w.play.get("teach", {})
	teach.erase(c.id)
	for tid in teach.keys():
		if str(teach[tid]) == c.id:
			teach.erase(tid)
			w.play["tasks"][tid] = ""
	w.play.get("exam", {}).erase(c.id)
	c.clan_retainer = false
	(w.clan["retainers"] as Array).erase(c.id)
	w.play["tasks"].erase(c.id)
	studies(w).erase(c.id)
	w.play["salary"].erase(c.id)
	if w.play.has("ret"):
		w.play["ret"].erase(c.id)
	c.env = ""
	c.env_bonus = 1.0
	c.skim = 0.0
	c.skimmed = 0.0
	c.prof_on = true
	c.task_stats = []
	Purse.debts(w).erase(c.id)
	c.set_profession(c.profession)




static func rec_bonus(w: World, nid: String) -> float:
	var p: = w.player()
	var b: = 5.0 + float(p.real[Defs.CHINH]) * 0.15 + prestige(w) / 40.0 + float(w.play["influence"].get(nid, 0.0)) / 4.0
	b += minf(12.0, 3.0 * network(w, nid))
	b += Rivals.ally_bonus(w, nid)
	if nid != p.nation_id:
		b *= 0.7
	return minf(30.0, b)



static func network(w: World, nid: String) -> int:
	var n: = 0
	for id in w.play.get("recommended", []):
		var c: = w.ch(str(id))
		if c != null and c.alive and c.office_key.begins_with(nid + "/") and c.favor >= 50.0:
			n += 1
	return n



static func general_bonus(w: World) -> float:
	return float(w.player().real[Defs.QUAN]) * 0.1


static func recommend_block(w: World, c: Character) -> String:
	if c != null and Appointment.shamed(w, c):
		return "%s đang mang tiếng (tới %s): triều đình chưa dùng lại. Cho Thi tài để rửa tiếng, hoặc chờ hết hạn." % [c.name, World.date_of(c.shame_until)]
	if c == null or not c.alive:
		return "Người này không còn trên đời."
	if c.office_key != "" or (c.nation_id != "" and not is_retainer(w, c)):
		return "%s đã thuộc về triều đình %s." % [c.name, w.nation_name(c.nation_id)]
	if c.age(w.m) < 16:
		return "Còn quá trẻ để ra làm quan (cần 16 tuổi)."
	if capital_nations(w).is_empty():
		return "Phải đứng ở một kinh đô (♛ trên bản đồ)."
	if not is_retainer(w, c) and not met_now(w, c):
		return "Phải Gặp gỡ %s trước (trong %d ngày qua), hoặc chiêu mộ trước." % [c.name, MEET_WINDOW]
	if is_retainer(w, c) and not with_me(w, c):
		return "%s đang %s; phải theo hầu bạn hoặc ở tư trạch tại kinh đô này mới tiến cử được." % [c.name, loc_text(w, c)]
	return ""


static func _best_perceived_role(w: World, c: Character) -> Array:
	var pv: = Appraisal.perceived_vals(w, c)
	var best: = ""
	var bs: = -1.0
	for role in Defs.ROLE_ORDER:
		var s: = c.role_score(role, pv)
		if s > bs:
			bs = s
			best = role
	return [best, bs]



const REC_TIERS: = [
	[0.6, 0.0, "Vào triều · Huyện lệnh · Đô úy"], 
	[1.5, 40.0, "Thái thú · Tướng quân"], 
	[2.5, 100.0, "Lục bộ · Đại tướng quân"], 
	[3.0, 200.0, "Thừa tướng"], 
]


static func rec_tier(key: String) -> int:
	if key == "":
		return 0
	var wt: = float(Defs.OFFICES[Appointment.office_of_key(key)]["weight"])
	for k in REC_TIERS.size():
		if wt <= float(REC_TIERS[k][0]):
			return k
	return REC_TIERS.size() - 1



static func rec_tier_block(w: World, nid: String, tier: int) -> String:
	var need: = float(REC_TIERS[tier][1])
	if prestige(w) >= need:
		return ""
	var p: = w.player()
	if p.office_key != "" and p.nation_id == nid and Appointment.weight_of(p) >= float(REC_TIERS[tier][0]) - 0.01:
		return ""
	return "Cần Danh vọng ≥ %d (hiện %d), hoặc chính bạn làm quan ở nước này với chức ngang bậc." % [roundi(need), roundi(prestige(w))]



static func rec_cap(w: World) -> int:
	return 1 + clan_tier(w)


static func rec_used(w: World, nid: String) -> int:
	var d: Dictionary = w.play.get("rec_year", {}).get(nid, {})
	return int(d.get("n", 0)) if int(d.get("y", -1)) == w.year() else 0


static func _rec_count(w: World, nid: String) -> void :
	if not w.play.has("rec_year"):
		w.play["rec_year"] = {}
	w.play["rec_year"][nid] = {"y": w.year(), "n": rec_used(w, nid) + 1}


static func recommend_options(w: World, c: Character, vouch: bool = false) -> Array:
	var res: Array = []
	if recommend_block(w, c) != "":
		return res
	var p: = w.player()
	for nid in capital_nations(w):
		var bonus: = rec_bonus(w, nid) + (Repute.VOUCH_BONUS if vouch else 0.0)
		var pr: = _best_perceived_role(w, c)
		var snub: = Appointment.snub_chance(w, c)
		var cand0: = float(pr[1]) + (Repute.VOUCH_BONUS if vouch else 0.0)
		res.append({"nid": nid, "key": "", "label": "Vào triều, chờ bổ nhiệm", "holder": "", "mine": false, 
			"cand": cand0, "inc": 35.0, "ok": cand0 >= 35.0, "foreign": nid != p.nation_id, "snub": snub})
		var offices: Dictionary = w.nations[nid]["offices"]
		for key in offices:
			var oid: = Appointment.office_of_key(key)
			var inc: = w.office_holder(nid, key)
			var cand: = Appointment.score(w, c, nid, oid) + bonus + (general_bonus(w) if bool(Defs.OFFICES[oid]["military"]) else 0.0)
			var inc_s: = Appointment.MIN_SCORE if inc == null else Appointment.score(w, inc, nid, oid) + Appointment.incumbency(inc) - Rivals.remnant_penalty(w, inc)
			res.append({"nid": nid, "key": key, "label": Appointment.office_label(w, nid, key), 
				"holder": "" if inc == null else inc.name, "mine": inc != null and inc.recommender == p.id, 
				"cand": cand, "inc": inc_s, "ok": cand > inc_s, "foreign": nid != p.nation_id, "snub": snub})
	for o in res:
		o["tier"] = rec_tier(str(o["key"]))
		var lock: = rec_tier_block(w, str(o["nid"]), int(o["tier"]))
		if lock == "" and rec_used(w, str(o["nid"])) >= rec_cap(w):
			lock = "Năm nay triều đình %s đã nhận đủ %d lời tiến cử của bạn (Gia thế càng cao càng được nhiều)." % [w.nation_name(str(o["nid"])), rec_cap(w)]
		o["lock"] = lock
		if lock != "":
			o["ok"] = false
	return res



static func reward_estimate(w: World, c: Character, key: String, foreign: bool) -> Array:
	var perc: = float(_best_perceived_role(w, c)[1])
	if key != "":
		perc = Appraisal.perceived_office_score(w, c, Appointment.office_of_key(key))
	var gold: = roundi(perc * (8.0 if key != "" else 4.0) * (1.5 if foreign else 1.0))
	return [gold, perc / (9.0 if foreign else 5.0)]


static func recommend(w: World, id: String, nid: String, key: String, vouch: bool = false) -> Dictionary:
	var c: = w.ch(id)
	var err: = recommend_block(w, c)
	if err != "":
		return _fail(err)
	if vouch and Repute.vouch_block(w) != "":
		return _fail(Repute.vouch_block(w))
	var opt: Dictionary = {}
	for o in recommend_options(w, c, vouch):
		if str(o["nid"]) == nid and str(o["key"]) == key:
			opt = o
	if opt.is_empty():
		return _fail("Không tiến cử được vào vị trí này từ đây.")
	if not _spend(w, act_days(w, "recommend")):
		pass
	var p: = w.player()
	if str(opt.get("lock", "")) != "":
		return _fail(str(opt["lock"]))
	_rec_count(w, nid)
	if not bool(opt["ok"]):
		w.clan["prestige"] = maxf(0.0, prestige(w) - 2.0)
		var tf: = "Triều đình %s bác lời tiến cử %s (Danh vọng −2)." % [w.nation_name(nid), c.name]
		log_line(w, tf)
		return _ok(tf, {"accepted": false})
	if Appointment.snubbed(w, c):
		var ts: = "Triều đình %s chê %s dung mạo, ăn nói kém cỏi, không chịu dùng dù tài năng đến đâu. (Mị lực thấp – thử lại năm sau, hoặc nuôi Mị lực cho họ.)" % [w.nation_name(nid), c.name]
		log_line(w, ts)
		return _ok(ts, {"accepted": false, "snubbed": true})
	var foreign: = bool(opt["foreign"])
	var rw: = reward_estimate(w, c, key, foreign)
	var gold: int = rw[0]
	var prest: float = rw[1]
	if is_retainer(w, c):
		_release(w, c)
	c.recommender = p.id
	c.favor = minf(100.0, c.favor + 30.0)
	var where: = ""
	if key == "":
		var role: = str(_best_perceived_role(w, c)[0])
		c.nation_id = nid
		c.faction_id = ""
		c.city_id = str(w.nations[nid]["capital"])
		c.set_profession("vo_cu_nhan" if role == "tuong" or role == "ho_ve" else "tan_khoa")
		where = "vào triều %s" % w.nation_name(nid)
	else:
		var inc: = w.office_holder(nid, key)
		if inc != null:
			if Rivals.backer(inc) != "":
				Rivals.on_offended(w, Rivals.backer(inc), 15.0, "bạn hất %s khỏi ghế" % inc.name)
			Appointment.vacate(w, inc, "bị thay thế nhờ %s tiến cử %s" % [w.clan["name"], c.name])
		Appointment.appoint(w, nid, key, c)
		where = "làm %s của %s" % [Appointment.office_label(w, nid, key), w.nation_name(nid)]
	c.add_log(w.m, "Được %s tiến cử %s" % [p.name, where])
	Rivals.on_competition(w, nid)
	w.clan["money"] = money(w) + gold
	w.clan["prestige"] = prestige(w) + prest
	w.play["influence"][nid] = float(w.play["influence"].get(nid, 0.0)) + 5.0
	if foreign:
		w.play["suspicion"] = float(w.play["suspicion"]) + 20.0
		w.play["stats"]["foreign"] = int(w.play["stats"]["foreign"]) + 1
	w.play["stats"]["recommended"] = int(w.play["stats"]["recommended"]) + 1
	(w.play["recommended"] as Array).append(id)
	var t: = "Tiến cử %s %s: nhận %d lượng, Danh vọng +%.0f." % [c.name, where, gold, prest]
	if vouch:
		Repute.start_vouch(w, c)
		t += " Bạn đứng ra bảo cử (cược %d Danh vọng): một năm sau, làm tốt thì được gấp đôi." % roundi(Repute.VOUCH_STAKE)
	log_line(w, t)
	return _ok(t, {"accepted": true})


static func on_merit_year(w: World, c: Character, merit_y: float) -> void :
	if w.play.is_empty():
		return
	var gold: = roundi(merit_y * 8.0)
	var prest: = merit_y * 0.8
	w.clan["money"] = money(w) + gold
	w.clan["prestige"] = prestige(w) + prest
	report(w, "Công lao năm nay của %s: +%d lượng, Danh vọng +%.1f." % [c.name, gold, prest])


static func on_vacate(w: World, c: Character, label: String, reason: String) -> void :
	if w.play.is_empty():
		return
	var pen: = 0.0
	if reason.begins_with("bỏ sang"):
		pen = 20.0
	elif reason.contains("tịch biên"):
		pen = 10.0
	elif reason.contains("hãm hại") or reason.contains("biệt tích"):
		pen = 5.0
	var t: = "%s, người bạn tiến cử, rời chức %s: %s." % [c.name, label, reason]
	if pen > 0.0:
		w.clan["prestige"] = maxf(0.0, prestige(w) - pen)
		t += " Bạn bị liên đới, Danh vọng −%d." % roundi(pen)
	report(w, t)




static func loyalty_word(c: Character) -> String:
	for pr in LOYALTY_WORDS:
		if c.loyalty >= float(pr[0]):
			return str(pr[1])
	return "Muốn rời đi"




static func trade_mult(c: Character) -> float:
	return 1.2 if ProfTree.rank(c) >= 3 and (c.profession == "thuong_nhan" or c.profession == "tieu_thuong") else 1.0


static func mentor_effect(w: World, t: Character, st: Character) -> Dictionary:
	var stats: Array = st.focus.duplicate() if not st.focus.is_empty() else [st.top_pot()]
	var best: = int(stats[0])
	for i in stats:
		if float(t.real[int(i)]) - float(st.real[int(i)]) > float(t.real[best]) - float(st.real[best]):
			best = int(i)
	var tr: = float(t.real[best])
	if tr >= float(st.pot[best]) - 10.0:
		return {"stat": best, "mult": 1.6, "word": "mạnh (×1,6)"}
	if tr >= float(st.real[best]) + 10.0:
		return {"stat": best, "mult": 1.3, "word": "vừa (×1,3)"}
	if ProfTree.rank(t) >= 4 and tr > float(st.real[best]):
		return {"stat": best, "mult": 1.3, "word": "vừa (×1,3, thầy là bậc thầy trong nghề)"}
	return {"stat": best, "mult": 1.0, "word": "vô ích, thầy không giỏi hơn trò"}


static func apply_teaching(w: World) -> void :
	var teach: Dictionary = w.play.get("teach", {})
	for tid in teach.keys():
		var t: = w.ch(str(tid))
		var st: = w.ch(str(teach[tid]))
		if t == null or st == null or not t.alive or not st.alive or not is_retainer(w, t) or not is_retainer(w, st):
			teach.erase(tid)
			continue
		if task_pause(w, t) != "":
			continue
		var eff: = mentor_effect(w, t, st)
		if float(eff["mult"]) > 1.0 and (st.mentor_m <= 2 or st.mentor_mult <= float(eff["mult"])):
			st.mentor_m = 2
			st.mentor_stat = int(eff["stat"])
			st.mentor_mult = float(eff["mult"])
		t.fame = minf(100.0, t.fame + 0.1)


static func exam_flag(w: World, id: String) -> bool:
	return w.play.get("exam", {}).has(id)


static func toggle_exam(w: World, id: String) -> Dictionary:
	var c: = w.ch(id)
	if c == null or not is_retainer(w, c):
		return _fail("Chỉ cho môn khách đi thi.")
	if not w.play.has("exam"):
		w.play["exam"] = {}
	if exam_flag(w, id):
		w.play["exam"].erase(id)
		return _ok("%s sẽ không dự thi nữa." % c.name)
	w.play["exam"][id] = true
	return _ok("%s sẽ dự thi ở khoa tới (Khoa cử / Võ cử, 2 năm một mùa). Tháng 2 phải ở thành thi Hương, tháng 3 ở kinh thành; đỗ đạt thì danh tiếng vang dội, nhưng triều đình sẽ muốn giành người." % c.name)


static func seek_block(w: World, c: Character) -> String:
	if c == null or not is_retainer(w, c):
		return "Chỉ tìm danh sư cho môn khách."
	if int(w.play.get("seek", {}).get(c.id, -99)) > w.m - 12:
		return "Mỗi năm chỉ tìm thầy cho một người một lần."
	if money(w) < SEEK_COST:
		return "Cần %d lượng." % SEEK_COST
	return ""


static func seek_chance(w: World) -> float:
	var place: = 0.15 if (w.has_feature(here(w), "hoc_phu") or w.has_feature(here(w), "vo_duong")) else 0.0
	return clampf(0.35 + charm(w) / 300.0 + prestige(w) / 1000.0 + place, 0.0, 0.9)



static func seek_master(w: World, id: String) -> Dictionary:
	var c: = w.ch(id)
	var err: = seek_block(w, c)
	if err != "":
		return _fail(err)
	if not _spend(w, act_days(w, "seek_master")):
		pass
	w.clan["money"] = money(w) - SEEK_COST
	if not w.play.has("seek"):
		w.play["seek"] = {}
	w.play["seek"][id] = w.m
	var r: = w.rng(["seek", id])
	var t: = ""
	if r.randf() < seek_chance(w):
		var i: = Events._path_stat(c)
		c.mentor_m = 12
		c.mentor_stat = i
		c.mentor_mult = Defs.MENTOR_MULT
		t = "Tìm được danh sư dạy %s cho %s trong 12 tháng." % [Defs.STAT_NAMES[i], c.name]
		if r.randf() < 0.3:
			var cur: float = c.pot[i]
			c.pot[i] = maxf(cur, minf(c.pot_cap(), cur + r.randf_range(3.0, 6.0)))
			t += " Được chân truyền, tiềm năng %s tăng thêm." % Defs.STAT_NAMES[i]
		c.add_log(w.m, "Được danh sư chỉ dạy %s (do %s tìm cho)" % [Defs.STAT_NAMES[i], w.clan["name"]])
	else:
		t = "Kẻ tự xưng danh sư hóa ra là bịp bợm, mất trắng %d lượng." % SEEK_COST
	log_line(w, t)
	return _ok(t)




static func branch_points(w: World) -> int:
	var spent: = 0
	for b in w.play.get("branches", {}):
		spent += int(BRANCHES[b]["cost"])
	return floori(int(w.play["ngo_dao"]) / 20.0) - spent


static func has_branch(w: World, b: String) -> bool:
	return w.play.get("branches", {}).has(b)


static func unlock_branch(w: World, b: String) -> Dictionary:
	if not BRANCHES.has(b) or has_branch(w, b):
		return _fail("Không mở được nhánh này.")
	if branch_points(w) < int(BRANCHES[b]["cost"]):
		return _fail("Cần %d điểm ngộ (mỗi 20 Ngộ đạo được 1 điểm)." % int(BRANCHES[b]["cost"]))
	if not w.play.has("branches"):
		w.play["branches"] = {}
	w.play["branches"][b] = w.m
	var t: = "Đôi Mắt khai mở nhánh %s." % BRANCHES[b]["name"]
	log_line(w, t)
	return _ok(t)



static func role_fit(rec: Dictionary) -> Array:
	var res: Array = []
	for role in Defs.ROLE_ORDER:
		var wts: Array = Defs.ROLES[role]["w"]
		var lo: = 0.0
		var hi: = 0.0
		var plo: = 0.0
		var phi: = 0.0
		var has_pot: = true
		for i in Defs.N_STATS:
			var rb: Array = rec["real"][i]
			var pb: Array = rec["pot"][i]
			lo += float(rb[0]) * float(wts[i])
			hi += float(rb[1]) * float(wts[i])
			if pb.is_empty():
				has_pot = false
			else:
				plo += float(pb[0]) * float(wts[i])
				phi += float(pb[1]) * float(wts[i])
		var rd: Dictionary = Defs.ROLES[role]
		if rd.has("mi") and rec.has("mi_real"):
			var mw: = float(rd["mi"])
			var mr: Array = rec["mi_real"]
			var mp: Array = rec.get("mi_pot", [])
			lo += float(mr[0]) * mw
			hi += float(mr[1]) * mw
			if mp.is_empty():
				has_pot = false
			else:
				plo += float(mp[0]) * mw
				phi += float(mp[1]) * mw
		res.append({"role": role, "lo": lo, "hi": hi, "plo": plo if has_pot else -1.0, "phi": phi if has_pot else -1.0})
	res.sort_custom( func(a: Dictionary, b: Dictionary) -> bool: return float(a["phi"]) + float(a["hi"]) > float(b["phi"]) + float(b["hi"]))
	return res



static func project_from_record(w: World, c: Character, rec: Dictionary, months: int) -> Array:
	var tmp: = Character.new()
	tmp.birth_m = c.birth_m
	tmp.ngo = int(rec.get("ngo", 3))
	tmp.focus = c.focus.duplicate()
	tmp.env = c.env
	tmp.talents = (rec.get("talents", []) as Array).duplicate()
	for i in Defs.N_STATS:
		var rb: Array = rec["real"][i]
		var pb: Array = rec["pot"][i]
		tmp.real[i] = (float(rb[0]) + float(rb[1])) / 2.0
		tmp.pot[i] = maxf(float(tmp.real[i]), (float(pb[0]) + float(pb[1])) / 2.0) if not pb.is_empty() else float(tmp.real[i])
	return Growth.project(tmp, w.m, months)



static func causal_log(c: Character) -> Array:
	var keys: = ["Tiềm năng", "khủng hoảng", "Chuyển hướng", "Thức tỉnh", "chuyển hóa", "Tránh được", "lệch hướng", "phế", "tật", "Phục hồi", "truyền thụ", "Sa ngã", "Từ bỏ", "danh sư", "cao nhân"]
	var res: Array = []
	for e in c.history:
		var t: = str(e["t"])
		for k in keys:
			if t.contains(k):
				res.append({"m": int(e["m"]), "t": t.replace("[Định mệnh] ", "")})
				break
	return res




static func duel_chance(w: World) -> float:
	return clampf(0.15 + (Items.eff_vo(w.player()) - 20.0) / 80.0, 0.05, 0.9)


static func push_choice(w: World, kind: String, id: String, text: String, opts: Array, data: Dictionary = {}, months: int = 2) -> void :
	if not w.play.has("choices"):
		w.play["choices"] = []
	var seq: = int(w.play.get("choice_seq", 0))
	w.play["choice_seq"] = seq + 1
	(w.play["choices"] as Array).append({"uid": seq, "kind": kind, "id": id, "text": text, "opts": opts, "data": data, "until": w.m + months})


static func choices(w: World) -> Array:
	return w.play.get("choices", [])


static func _has_choice_for(w: World, id: String) -> bool:
	for ch in choices(w):
		if str(ch["id"]) == id:
			return true
	return false


static func choice_court_invite(w: World, c: Character, nid: String, title: String) -> void :
	if w.play.is_empty():
		return
	push_choice(w, "trieu_moi", c.id, "%s, môn khách của bạn, đỗ %s. Triều đình %s muốn bổ dụng ngay." % [c.name, title, w.nation_name(nid)], 
		[["dong_y", "Đồng ý", "Họ ra làm quan; bạn được tính là người tiến cử, nhận thưởng"], ["tu_choi", "Giữ lại", "Danh vọng −3, môn khách cảm kích (Trung thành +5)"]], 
		{"nid": nid})


static func choice_framed(w: World, c: Character) -> void :
	if _has_choice_for(w, c.id):
		return
	push_choice(w, "vu_oan", c.id, "%s (%s), người bạn tiến cử, bị gièm pha hãm hại trong triều." % [c.name, Appointment.office_label_of(w, c)], 
		[["bao_ve", "Ra mặt bảo vệ", "Danh vọng −8; ~65% giữ được chức cho họ"], ["im_lang", "Im lặng", "Họ mất chức, ân tình −30"]])


static func _roll_choices(w: World) -> void :
	var r: = w.rng(["choice"])
	if choices(w).size() >= 2 or r.randf() > 0.3:
		return
	var p: = w.player()
	var kinds: Array = []
	var rs: Array = []
	for c: Character in retainers(w):
		if c.alive and not _has_choice_for(w, c.id):
			rs.append(c)
	var strong: Array = rs.filter( func(c: Character) -> bool: return c.max_real() >= 55.0)
	var decent: Array = rs.filter( func(c: Character) -> bool: return c.max_real() >= 45.0)
	var fighters: Array = rs.filter( func(c: Character) -> bool: return Items.eff_vo(c) >= 40.0)
	var foreign: Array = []
	for nid in w.nations:
		if nid != p.nation_id:
			foreign.append(nid)
	if not strong.is_empty() and not foreign.is_empty():
		kinds.append("loi_moi_ngoai")
	if not rs.is_empty():
		kinds.append("xin_tien")
	if not decent.is_empty() and w.nations.has(p.nation_id):
		kinds.append("quan_muon")
	if not fighters.is_empty():
		kinds.append("thach_dau")
	if money(w) >= 400.0:
		kinds.append("dau_tu")
	if kinds.is_empty():
		return
	match str(Rng.pick(r, kinds)):
		"loi_moi_ngoai":
			var c: Character = Rng.pick(r, strong)
			var nid: String = Rng.pick(r, foreign)
			push_choice(w, "loi_moi_ngoai", c.id, "Triều đình %s ngỏ ý mời %s về làm quan, hứa bổng lộc hậu hĩnh." % [w.nation_name(nid), c.name], 
				[["giu", "Giữ lại", "Tăng lương 50%, Trung thành +10"], ["de_di", "Để họ đi", "Họ sang %s; bạn được tính là người tiến cử, ân tình +20" % w.nation_name(nid)], ["mac_ke", "Mặc kệ", "Để họ tự quyết (người kém trung thành sẽ đi)"]], 
				{"nid": nid})
		"xin_tien":
			var c: Character = Rng.pick(r, rs)
			var amt: = r.randi_range(10, 30) * 10
			push_choice(w, "xin_tien", c.id, "Gia đình %s gặp nạn, xin gia tộc giúp %d lượng." % [c.name, amt], 
				[["cho", "Giúp đỡ", "−%d lượng, Trung thành +15, ân tình +10" % amt], ["khong", "Từ chối", "Trung thành −10"]], {"amt": amt})
		"quan_muon":
			var c: Character = Rng.pick(r, decent)
			var bigs: Array = []
			for key in w.nations[p.nation_id]["offices"]:
				var o: = w.office_holder(p.nation_id, key)
				if o != null and Appointment.weight_of(o) >= 2.0:
					bigs.append(o)
			if bigs.is_empty():
				return
			var o2: Character = Rng.pick(r, bigs)
			push_choice(w, "quan_muon", c.id, "%s (%s) muốn mời %s về phủ giúp việc triều chính." % [o2.name, Appointment.office_label_of(w, o2), c.name], 
				[["dong_y", "Đồng ý", "Họ vào triều %s (bạn là người tiến cử), Ảnh hưởng +10, Danh vọng +5" % w.nation_name(p.nation_id)], ["tu_choi", "Từ chối", "Ảnh hưởng −5"]])
		"thach_dau":
			var c: Character = Rng.pick(r, fighters)
			push_choice(w, "thach_dau", c.id, "Một cao thủ giang hồ đến tận cửa thách đấu %s." % c.name, 
				[["cho_phep", "Cho phép", "Thắng: Võ lực và tiềm năng tăng, nổi danh; thua: mất mặt; có thể bị thương"], 
				["tu_dau", "Tự mình ra đấu", "Khả năng thắng ~%d%% theo Võ lực của bạn; thắng thì Danh vọng +6, môn khách nể phục" % roundi(duel_chance(w) * 100.0)], 
				["ngan", "Ngăn lại", "Không có gì xảy ra"]])
		"dau_tu":
			push_choice(w, "dau_tu", "", "Một thương nhân rủ %s góp 300 lượng buôn chuyến hàng xa, hẹn 6 tháng chia lãi." % w.clan["name"], 
				[["gop_von", "Góp vốn", "−300 lượng; 6 tháng sau ~60% được 650 lượng, ~40% mất trắng"], ["thoi", "Thôi", "Không có gì xảy ra"]])


static func resolve_choice(w: World, uid: int, key: String) -> Dictionary:
	var ch: Dictionary = {}
	for x in choices(w):
		if int(x["uid"]) == uid:
			ch = x
	if ch.is_empty():
		return _fail("Việc này đã qua.")
	(w.play["choices"] as Array).erase(ch)
	var t: = _apply_choice(w, ch, key)
	log_line(w, t)
	return _ok(t)


static func _join_court(w: World, c: Character, nid: String, credit: bool) -> void :
	_release(w, c)
	var role: = str(_best_perceived_role(w, c)[0])
	c.nation_id = nid
	c.faction_id = ""
	c.city_id = str(w.nations[nid]["capital"])
	c.set_profession("vo_cu_nhan" if role == "tuong" or role == "ho_ve" else "tan_khoa")
	if credit:
		c.recommender = w.player_id
		(w.play["recommended"] as Array).append(c.id)
		w.play["stats"]["recommended"] = int(w.play["stats"]["recommended"]) + 1


static func _apply_choice(w: World, ch: Dictionary, key: String) -> String:
	var c: = w.ch(str(ch["id"]))
	var r: = w.rng(["choice_do", int(ch["uid"])])
	var data: Dictionary = ch.get("data", {})
	var kind: = str(ch["kind"])
	if kind != "dau_tu" and (c == null or not c.alive):
		return "Việc đã không còn ý nghĩa: người trong cuộc không còn."
	if kind == "bien_thu":
		return Purse.on_choice(w, c, key)
	match kind + ":" + key:
		"loi_moi_ngoai:giu":
			w.play["salary"][c.id] = ceili(float(w.play["salary"].get(c.id, 5)) * 1.5)
			c.loyalty = minf(100.0, c.loyalty + 10.0)
			return "Giữ %s lại, tăng lương lên %d/tháng." % [c.name, int(w.play["salary"][c.id])]
		"loi_moi_ngoai:de_di":
			var nid: = str(data["nid"])
			if not w.nations.has(nid) or not is_retainer(w, c):
				return "Lời mời đã không còn."
			var gold: = roundi(perceived_best(w, c) * 3.0)
			_join_court(w, c, nid, true)
			c.favor = minf(100.0, c.favor + 20.0)
			w.clan["money"] = money(w) + gold
			w.clan["prestige"] = prestige(w) + 2.0
			return "%s sang %s làm quan, mang ơn bạn (+%d lượng)." % [c.name, w.nation_name(nid), gold]
		"loi_moi_ngoai:mac_ke":
			var nid2: = str(data["nid"])
			if c.loyalty < 60.0 or r.randf() < 0.5:
				if w.nations.has(nid2) and is_retainer(w, c):
					_join_court(w, c, nid2, false)
				return "%s nhận lời mời, rời gia tộc sang %s." % [c.name, w.nation_name(nid2)]
			c.loyalty = maxf(0.0, c.loyalty - 5.0)
			return "%s từ chối lời mời, ở lại nhưng có phần chạnh lòng." % c.name
		"xin_tien:cho":
			var amt: = float(data["amt"])
			if money(w) < amt:
				c.loyalty = maxf(0.0, c.loyalty - 10.0)
				return "Gia tộc không đủ tiền giúp %s (Trung thành −10)." % c.name
			w.clan["money"] = money(w) - amt
			c.loyalty = minf(100.0, c.loyalty + 15.0)
			c.favor = minf(100.0, c.favor + 10.0)
			return "Giúp gia đình %s %d lượng. Họ cảm kích vô cùng." % [c.name, int(amt)]
		"xin_tien:khong":
			c.loyalty = maxf(0.0, c.loyalty - 10.0)
			return "Từ chối giúp %s (Trung thành −10)." % c.name
		"quan_muon:dong_y":
			var nid3: = w.player().nation_id
			if not w.nations.has(nid3) or not is_retainer(w, c):
				return "Lời mời đã không còn."
			_join_court(w, c, nid3, true)
			w.play["influence"][nid3] = float(w.play["influence"].get(nid3, 0.0)) + 10.0
			w.clan["prestige"] = prestige(w) + 5.0
			return "%s vào triều %s. Ảnh hưởng +10, Danh vọng +5." % [c.name, w.nation_name(nid3)]
		"quan_muon:tu_choi":
			var nid4: = w.player().nation_id
			w.play["influence"][nid4] = maxf(0.0, float(w.play["influence"].get(nid4, 0.0)) - 5.0)
			return "Khước từ lời mời mượn %s (Ảnh hưởng −5)." % c.name
		"thach_dau:cho_phep":
			var x: = r.randf()
			if x < 0.15:
				Events.injure(w, c, r, false, "nang", "", " khi tỉ thí")
				return "%s bị trọng thương trong trận tỉ thí." % c.name
			if x < 0.6:
				c.real[Defs.VO] = minf(float(c.pot[Defs.VO]), float(c.real[Defs.VO]) + 3.0)
				var cur: float = c.pot[Defs.VO]
				c.pot[Defs.VO] = maxf(cur, minf(c.pot_cap(), cur + 4.0))
				c.fame = minf(100.0, c.fame + 8.0)
				c.add_log(w.m, "Thắng trận tỉ thí, Võ lực và tiềm năng tăng")
				return "%s thắng trận tỉ thí, danh tiếng nổi như cồn." % c.name
			c.fame = maxf(0.0, c.fame - 3.0)
			return "%s thua trận tỉ thí, mất chút thể diện." % c.name
		"thach_dau:tu_dau":
			var p: = w.player()
			if r.randf() < duel_chance(w):
				w.clan["prestige"] = prestige(w) + 6.0
				p.fame = minf(100.0, p.fame + 5.0)
				c.loyalty = minf(100.0, c.loyalty + 5.0)
				p.real[Defs.VO] = minf(float(p.pot[Defs.VO]), float(p.real[Defs.VO]) + 1.0)
				return "Bạn tự ra đấu thay %s và thắng. Danh vọng +6, %s nể phục." % [c.name, c.name]
			p.health = maxf(1.0, p.health - 15.0)
			w.clan["prestige"] = maxf(0.0, prestige(w) - 2.0)
			return "Bạn ra đấu thay %s nhưng thua, mang thương tích (Danh vọng −2)." % c.name
		"thach_dau:ngan":
			return "Ngăn %s nhận lời thách đấu." % c.name
		"dau_tu:gop_von":
			if money(w) < 300.0:
				return "Không đủ 300 lượng để góp vốn."
			w.clan["money"] = money(w) - 300.0
			var win: = r.randf() < 0.6
			(w.play["payouts"] as Array).append({"m": w.m + 6, "amt": 650 if win else 0, 
				"t": "Chuyến buôn trở về: chia lãi 650 lượng." if win else "Chuyến buôn gặp cướp biển, mất trắng 300 lượng góp vốn."})
			return "Góp 300 lượng vào chuyến buôn, 6 tháng nữa biết kết quả."
		"dau_tu:thoi":
			return "Khước từ chuyến buôn."
		"vu_oan:bao_ve":
			w.clan["prestige"] = maxf(0.0, prestige(w) - 8.0)
			if c.office_key == "":
				return "%s đã không còn giữ chức." % c.name
			if r.randf() < 0.65:
				c.favor = minf(100.0, c.favor + 15.0)
				return "Bạn ra mặt minh oan, %s giữ được chức (Danh vọng −8)." % c.name
			Events.framed_apply(w, c)
			c.favor = minf(100.0, c.favor + 10.0)
			return "Dù bạn bảo vệ, %s vẫn bị cách chức. Họ ghi nhớ ân tình của bạn." % c.name
		"vu_oan:im_lang":
			if c.office_key != "":
				Events.framed_apply(w, c)
			c.favor = maxf(0.0, c.favor - 30.0)
			return "Bạn im lặng, %s bị cách chức và oán trách bạn." % c.name
		"trieu_moi:dong_y":
			var nid5: = str(data["nid"])
			if not w.nations.has(nid5) or not is_retainer(w, c):
				return "Lời mời đã không còn."
			var gold2: = roundi(perceived_best(w, c) * 4.0)
			_join_court(w, c, nid5, true)
			w.clan["money"] = money(w) + gold2
			w.clan["prestige"] = prestige(w) + 5.0
			return "%s ra làm quan cho %s (+%d lượng, Danh vọng +5)." % [c.name, w.nation_name(nid5), gold2]
		"loi_keo:giu":
			w.play["salary"][c.id] = ceili(float(w.play["salary"].get(c.id, 5)) * 1.5)
			c.loyalty = minf(100.0, c.loyalty + 15.0)
			return "Giữ %s lại, tăng lương lên %d/tháng." % [c.name, int(w.play["salary"][c.id])]
		"loi_keo:de_di":
			var rv: Dictionary = w.rivals.get(str(data.get("rid", "")), {})
			if rv.is_empty() or not is_retainer(w, c):
				return "Lời mời đã không còn."
			_release(w, c)
			Items.reclaim(w, c)
			Rivals.take(w, rv, c)
			rv["rel"] = float(rv["rel"]) + 5.0
			return "%s sang làm môn khách của %s." % [c.name, rv["name"]]
		"am_muu:phong":
			w.clan["money"] = maxf(0.0, money(w) - 80.0)
			return "Tăng canh phòng: âm mưu nhắm vào %s không thành." % ("bạn" if c.is_player else c.name)
		"am_muu:phan_don":
			var rv2: Dictionary = w.rivals.get(str(data.get("rid", "")), {})
			if not rv2.is_empty():
				rv2["prestige"] = maxf(0.0, float(rv2["prestige"]) - 15.0)
				rv2["rel"] = float(rv2["rel"]) - 15.0
				w.add_news("%s bị vạch mặt âm mưu %s." % [rv2["name"], str(Rivals.PLOTS[str(data["plot"])]["name"]).to_lower()], [], "the_gia")
			return "Phản đòn: âm mưu bị vạch trần, %s mất mặt." % rv2.get("name", "kẻ chủ mưu")
		"am_muu:mac_ke":
			var rv3: Dictionary = w.rivals.get(str(data.get("rid", "")), {})
			if rv3.is_empty():
				return "Không có gì xảy ra."
			Rivals.run_vs_player(w, rv3, str(data["plot"]), c, r)
			return "Để mặc %s ra tay." % rv3["name"]
		"trieu_moi:tu_choi":
			w.clan["prestige"] = maxf(0.0, prestige(w) - 3.0)
			c.loyalty = minf(100.0, c.loyalty + 5.0)
			return "Giữ %s lại gia tộc, khước từ triều đình (Danh vọng −3)." % c.name
	return "Không có gì xảy ra."


static func _expire_choices(w: World) -> void :
	for ch in choices(w).duplicate():
		if int(ch["until"]) <= w.m:
			var opts: Array = ch["opts"]
			var key: = str(opts[opts.size() - 1][0])
			(w.play["choices"] as Array).erase(ch)
			report(w, "Không kịp quyết định, mặc định \"%s\": %s" % [str(opts[opts.size() - 1][1]), _apply_choice(w, ch, key)])





static func troop_cap(w: World) -> int:
	return 500 * clan_tier(w)


static func recruit_troops(w: World) -> Dictionary:
	var cur: = int(w.clan.get("troops", 0))
	if cur + TROOP_BATCH > troop_cap(w):
		return _fail("Gia thế hiện tại chỉ nuôi được %d tư binh." % troop_cap(w))
	if money(w) < TROOP_COST:
		return _fail("Cần %d lượng." % TROOP_COST)
	if not _spend(w, act_days(w, "troops")):
		pass
	w.clan["money"] = money(w) - TROOP_COST
	w.clan["troops"] = cur + TROOP_BATCH
	var t: = "Mộ thêm %d tư binh (hiện %d, nuôi %d lượng/tháng)." % [TROOP_BATCH, cur + TROOP_BATCH, roundi((cur + TROOP_BATCH) * TROOP_UPKEEP)]
	log_line(w, t)
	return _ok(t)



static func troop_coup_bonus(w: World) -> float:
	var tr: = float(w.clan.get("troops", 0))
	return minf(0.2, tr / 2500.0 * (0.5 + float(w.player().real[Defs.QUAN]) / 100.0))



static func campaign_war(w: World) -> Dictionary:
	var p: = w.player()
	var cid: = p.city_id
	for wr in War.wars_of(w, p.nation_id):
		var front: = str(wr["front"])
		if cid == front or (w.cities[cid]["links"] as Dictionary).has(front):
			if int(w.play.get("campaign_m", -1)) == w.m:
				return {}
			return wr
	return {}


static func campaign_block(w: World) -> String:
	var p: = w.player()
	if War.wars_of(w, p.nation_id).is_empty():
		return "Bản quốc không có chiến tranh."
	if int(w.play.get("campaign_m", -1)) == w.m:
		return "Tháng này bạn đã ra trận."
	if campaign_war(w).is_empty():
		return "Phải đứng ở thành tiền tuyến hoặc thành kề tiền tuyến."
	return ""


static func campaign_push(w: World) -> float:
	return maxf(0.0, (float(w.player().real[Defs.QUAN]) - 25.0) / 8.0) + float(w.clan.get("troops", 0)) / 400.0


static func join_war(w: World) -> Dictionary:
	var err: = campaign_block(w)
	if err != "":
		return _fail(err)
	if not _spend(w, act_days(w, "join_war")):
		pass
	var p: = w.player()
	var wr: = campaign_war(w)
	w.play["campaign_m"] = w.m
	var push: = campaign_push(w)
	var sign: = 1.0 if str(wr["a"]) == p.nation_id else -1.0
	wr["score"] = float(wr["score"]) + sign * push
	p.real[Defs.QUAN] = minf(float(p.pot[Defs.QUAN]), float(p.real[Defs.QUAN]) + 0.8)
	w.clan["prestige"] = prestige(w) + 2.0
	w.play["influence"][p.nation_id] = float(w.play["influence"].get(p.nation_id, 0.0)) + 2.0
	var t: = "Theo quân ra tiền tuyến %s, bày mưu giúp chiến cục +%.1f cho %s." % [w.city_name(str(wr["front"])), push, w.nation_name(p.nation_id)]
	var r: = w.rng(["campaign"])
	if r.randf() < 0.005:
		Life.die(w, p, "tử trận")
		t += " Bạn trúng tên lạc, tử trận."
		w.play["over"] = "death"
	elif r.randf() < 0.05:
		p.health = maxf(1.0, p.health - 20.0)
		t += " Bạn bị thương nhẹ."
	log_line(w, t)
	return _ok(t)



static func trade_expect(w: World) -> float:
	var kt: = float(w.cities[here(w)]["kinh_te"])
	return TRADE_STAKE * (0.8 + float(w.player().real[Defs.THUONG]) / 100.0 * kt / 70.0)


static func trade_run(w: World) -> Dictionary:
	if money(w) < TRADE_STAKE:
		return _fail("Cần %d lượng vốn." % TRADE_STAKE)
	if not _spend(w, act_days(w, "trade")):
		pass
	var seq: = int(w.play.get("trade_seq", 0))
	w.play["trade_seq"] = seq + 1
	var r: = w.rng(["trade", seq])
	var back: = maxi(0, roundi(trade_expect(w) * r.randf_range(0.7, 1.3)))
	w.clan["money"] = money(w) - TRADE_STAKE
	if not w.play.has("payouts"):
		w.play["payouts"] = []
	(w.play["payouts"] as Array).append({"m": w.m + 3, "amt": back, "t": "Chuyến buôn từ %s về: thu %d lượng (vốn %d)." % [w.city_name(here(w)), back, TRADE_STAKE]})
	var t: = "Bỏ %d lượng buôn chuyến từ %s, 3 tháng sau thu về (dự kiến ~%d)." % [TRADE_STAKE, w.city_name(here(w)), roundi(trade_expect(w))]
	log_line(w, t)
	return _ok(t)



static func workshop_income(w: World) -> float:
	return 5.0 + maxf(0.0, float(w.player().real[Defs.SX]) - 20.0) * 0.8


static func build_workshop(w: World) -> Dictionary:
	var n: = int(w.clan.get("workshops", 0))
	if n >= WORKSHOP_MAX:
		return _fail("Đã có đủ %d xưởng." % WORKSHOP_MAX)
	if money(w) < WORKSHOP_COST:
		return _fail("Cần %d lượng." % WORKSHOP_COST)
	if not _spend(w, act_days(w, "workshop")):
		pass
	w.clan["money"] = money(w) - WORKSHOP_COST
	w.clan["workshops"] = n + 1
	var t: = "Mở xưởng thứ %d ở %s: thu ~%d lượng/tháng." % [n + 1, w.city_name(str(w.clan["city"])), roundi(workshop_income(w))]
	log_line(w, t)
	return _ok(t)



static func office_options(w: World) -> Array:
	var p: = w.player()
	var nid: = p.nation_id
	var res: Array = []
	if not w.nations.has(nid) or w.city_nation(p.city_id) != nid:
		return res
	var at_cap: = str(w.nations[nid]["capital"]) == p.city_id
	var bonus: = rec_bonus(w, nid) - 5.0
	var et: Dictionary = w.play.get("exam_title", {})
	if not et.is_empty() and str(et["nid"]) == nid and int(et["until"]) > w.m:
		bonus += float(et["bonus"])
	for key in w.nations[nid]["offices"]:
		var slot: Dictionary = w.nations[nid]["offices"][key]
		var oid: = Appointment.office_of_key(key)
		var per_city: = bool(Defs.OFFICES[oid].get("per_city", false))
		if per_city and str(slot["city"]) != p.city_id:
			continue
		if not per_city and not at_cap:
			continue
		if p.office_key == nid + "/" + key:
			continue
		var inc: = w.office_holder(nid, key)
		var cand: = Appointment.score(w, p, nid, oid) + bonus
		var inc_s: = Appointment.MIN_SCORE if inc == null else Appointment.score(w, inc, nid, oid) + 5.0
		res.append({"nid": nid, "key": key, "label": Appointment.office_label(w, nid, key), "holder": "" if inc == null else inc.name, 
			"cand": cand, "inc": inc_s, "ok": cand > inc_s, "salary": roundi(float(Defs.OFFICES[oid]["weight"]) * 40.0)})
	return res


static func seek_office(w: World, nid: String, key: String) -> Dictionary:
	var opt: Dictionary = {}
	for o in office_options(w):
		if str(o["key"]) == key and str(o["nid"]) == nid:
			opt = o
	if opt.is_empty():
		return _fail("Không xin được chức này từ đây.")
	if not _spend(w, act_days(w, "seek_office")):
		pass
	var p: = w.player()
	if bool(opt["ok"]) and Appointment.snubbed(w, p):
		var tsn: = "Triều đình chê %s dung mạo, ăn nói vụng về, không cho nhậm chức %s." % [p.name, opt["label"]]
		log_line(w, tsn)
		return _ok(tsn, {"accepted": false, "snubbed": true})
	if not bool(opt["ok"]):
		var tf: = "Triều đình khước từ, %s chưa đủ tiếng tăm cho chức %s." % [p.name, opt["label"]]
		log_line(w, tf)
		return _ok(tf, {"accepted": false})
	var inc: = w.office_holder(nid, key)
	if inc != null:
		Appointment.vacate(w, inc, "bị %s thay thế" % p.name)
	if p.office_key != "":
		Appointment.vacate(w, p, "được thăng chức", true)
	Appointment.appoint(w, nid, key, p)
	var t: = "%s nhậm chức %s: lương %d lượng/tháng, 6 ngày đầu mỗi tháng lo việc công (chức trọng có thuộc lại thì không)." % [p.name, opt["label"], int(opt["salary"])]
	log_line(w, t)
	return _ok(t, {"accepted": true})


static func resign_office(w: World) -> Dictionary:
	var p: = w.player()
	if p.office_key == "":
		return _fail("Bạn không giữ chức nào.")
	var label: = Appointment.office_label_of(w, p)
	Appointment.vacate(w, p, "từ quan")
	p.set_profession("quy_toc")
	var t: = "Từ quan, rời chức %s." % label
	log_line(w, t)
	return _ok(t)



const STAT_GROUPS: = [
	{"name": "Văn", "stats": [1, 3, 6], "use": "thẩm định, dò la, tiến cử, chiêu mộ, kết giao"}, 
	{"name": "Võ", "stats": [0, 2], "use": "an thân, thách đấu, tư binh, theo quân"}, 
	{"name": "Tài", "stats": [4, 5], "use": "thu nhập gia tộc, xưởng, buôn chuyến"}, 
]


static func pstat_name(i: int) -> String:
	return "Mị lực" if i >= Defs.N_STATS else str(Defs.STAT_NAMES[i])



static func pstat(w: World, i: int) -> Array:
	var p: = w.player()
	if i >= Defs.N_STATS:
		return [p.mi_real, p.mi_pot]
	return [float(p.real[i]), float(p.pot[i])]



static func strength_stat(w: World) -> int:
	var best: = 0
	for i in Defs.N_STATS + 1:
		if float(pstat(w, i)[1]) > float(pstat(w, best)[1]):
			best = i
	return best



static func train_suggestion(w: World) -> int:
	var best: = -1
	var bv: = 0.0
	for i in Defs.N_STATS + 1:
		var v: Array = pstat(w, i)
		var gap: = float(v[1]) - float(v[0])
		if gap < 3.0:
			continue
		var val: = gap * float(v[1]) / 100.0
		if val > bv:
			bv = val
			best = i
	return best



static func stat_effects(w: World) -> Array:
	var p: = w.player()
	var tri: = float(p.real[Defs.TRI])
	var n_leads: = 1 + (1 if tri >= 35.0 else 0) + (1 if tri >= 70.0 else 0)
	return [
		["Võ lực", "chiêu mộ võ giả +%d · thắng thách đấu %d%% · chính biến hỏng mất mạng %d%%" % [roundi(martial_recruit_bonus(w)), roundi(duel_chance(w) * 100.0), roundi(Endings.coup_death_chance(w) * 100.0)]], 
		["Trí lực", "dải thẩm định hẹp %d%% · dò la %d–%d manh mối%s" % [roundi(tri / 2.5), n_leads, n_leads + 1, " · thấy lời đồn phóng đại" if tri >= 50.0 else ""]], 
		["Quân sự", "theo quân +%.1f chiến cục · tiến cử tướng +%.1f" % [campaign_push(w), general_bonus(w)]], 
		["Chính trị", "tiến cử +%.1f · xin chức cho bản thân" % (float(p.real[Defs.CHINH]) * 0.15)], 
		["Sản xuất", "thu nhập +%d/th · mỗi xưởng +%d/th" % [roundi(float(p.real[Defs.SX]) / 2.0), roundi(workshop_income(w))]], 
		["Thương nghiệp", "thu nhập +%d/th · buôn chuyến ~%d%% vốn" % [roundi(float(p.real[Defs.THUONG]) / 2.0), roundi(trade_expect(w) / TRADE_STAKE * 100.0)]], 
		["Mị lực", "chiêu mộ %+d · khuyên nhủ +%d · triều đình %+d%s" % [roundi((charm(w) - 25.0) / 3.0), roundi(minf(35.0, 10.0 + charm(w) / 5.0)), roundi((Items.eff_mi(p) - 50.0) * Defs.CHARM_WEIGHT), " · có thể bị chê" if Items.eff_mi(p) < Defs.SNUB_BELOW else ""]], 
	]




static func probe_block(w: World, c: Character) -> String:
	if c == null:
		return "Không có người này."
	if is_retainer(w, c):
		return "Môn khách của bạn, tin tức luôn về tới bạn."
	if not is_known(w, c) and not is_starred(w, c.id):
		return "Bạn chưa biết người này."
	if c.city_id == here(w):
		return "Đang ở cùng thành: cứ Gặp gỡ trực tiếp."
	for pr in w.play.get("probes", []):
		if str(pr["id"]) == c.id:
			return "Đã cử người đi dò tin, đang chờ tin về."
	return ""


static func probe_delay(w: World, c: Character, tier: int) -> int:
	var d: = w.travel_months(here(w), c.city_id)
	if d < 0:
		d = 4
	if w.has_feature(here(w), "tram_dich"):
		d -= 1
	return maxi(1, d + int(PROBE_TIERS[tier]["delay"]))


static func probe(w: World, id: String, tier: int) -> Dictionary:
	var c: = w.ch(id)
	var err: = probe_block(w, c)
	if err != "":
		return _fail(err)
	var td: Dictionary = PROBE_TIERS[tier]
	if money(w) < float(td["cost"]):
		return _fail("Không đủ ngân lượng (cần %d)." % int(td["cost"]))
	w.clan["money"] = money(w) - float(td["cost"])
	var seq: = int(w.play.get("probe_seq", 0))
	w.play["probe_seq"] = seq + 1
	var delay: = probe_delay(w, c, tier)

	var intel: = _make_intel(w, c, tier, w.rng(["probe", id, seq]))
	if not w.play.has("probes"):
		w.play["probes"] = []
	(w.play["probes"] as Array).append({"id": id, "due": w.m + delay, "intel": intel})
	var t: = "Cử người đi dò tin %s ở %s (%d lượng), tin về sau ~%d tháng." % [c.name, w.city_name(c.city_id), int(td["cost"]), delay]
	log_line(w, t)
	return _ok(t)



static func public_status(w: World, c: Character) -> String:
	if not c.alive:
		return "đã qua đời"
	if c.office_key != "":
		return "%s của %s" % [Appointment.office_label_of(w, c), w.nation_name(c.nation_id)]
	if c.clan_retainer:
		return "môn khách của %s" % w.clan["name"]
	var s: = Defs.prof_name(c.profession).to_lower()
	if c.nation_id != "":
		s += " (%s)" % w.nation_name(c.nation_id)
	return s


static func _make_intel(w: World, c: Character, tier: int, r: RandomNumberGenerator) -> Dictionary:
	var td: Dictionary = PROBE_TIERS[tier]
	var wrong: = r.randf() < float(td["wrong"])
	var city: = c.city_id
	var health: = "khỏe mạnh"
	if c.health < 40.0:
		health = "ốm yếu, thương tích nặng"
	elif c.health < 70.0:
		health = "sức khỏe kém"
	if wrong:
		if r.randf() < 0.5:
			var others: Array = []
			for cid in w.cities:
				if cid != c.city_id:
					others.append(cid)
			city = str(Rng.pick(r, others))
		else:
			health = "khỏe mạnh" if c.health < 70.0 else "nghe nói đang lâm bệnh"
	var events: Array = []
	var h: Array = c.history
	for k in range(h.size() - 1, -1, -1):
		var e: Dictionary = h[k]
		if int(e["m"]) < w.m - 12 or events.size() >= int(td["events"]):
			break
		var t: = str(e["t"]).replace("[Định mệnh] ", "")
		for pre in PUBLIC_EVENT_PREFIX:
			if t.begins_with(pre):
				events.append({"m": int(e["m"]), "t": t})
				break
	var reals: Array = []
	var half: float = td["half"]
	for i in Defs.N_STATS:
		reals.append(Appraisal.band(w, c, "probe%d" % tier, i, 9, c.shown_real(i), half))
	var injuries: Array = []
	for inj in c.injuries:
		if int(inj["months"]) < 0:
			injuries.append(str(inj["name"]))
	return {
		"m": w.m, "tier": tier, "alive": c.alive, "city": city, "status": public_status(w, c), 
		"health": health, "injuries": injuries, "crisis": not c.crisis.is_empty(), "events": events, "real": reals, 
	}


static func intel_text(w: World, intel: Dictionary) -> String:
	if not bool(intel["alive"]):
		return "đã qua đời"
	var parts: Array = ["ở %s" % w.city_name(str(intel["city"])), str(intel["status"]), str(intel["health"])]
	var inj: Array = intel["injuries"]
	if not inj.is_empty():
		parts.append("mang thương tật: " + ", ".join(inj))
	if bool(intel["crisis"]):
		parts.append("đang suy sụp sau biến cố")
	return " · ".join(parts)


static func _deliver_probes(w: World) -> void :
	var keep: Array = []
	for pr in w.play.get("probes", []):
		if int(pr["due"]) > w.m:
			keep.append(pr)
			continue
		var id: = str(pr["id"])
		var c: = w.ch(id)
		var intel: Dictionary = pr["intel"]
		if not w.play.has("intel"):
			w.play["intel"] = {}
		w.play["intel"][id] = intel
		var nm: = c.name if c != null else id
		var ev: = ""
		for e in intel["events"]:
			ev += " Gần đây: %s (%s)." % [e["t"], World.date_of(int(e["m"]))]
		report(w, "Thám báo về %s (tin từ %s): %s.%s" % [nm, World.date_of(int(intel["m"])), intel_text(w, intel), ev])
	w.play["probes"] = keep




static func counsel(w: World, id: String, path: String) -> Dictionary:
	var c: = w.ch(id)
	if c == null or not c.alive or c.crisis.is_empty():
		return _fail("Người này không cần khuyên nhủ.")
	if not met_now(w, c):
		return _fail("Phải gặp mặt %s (trong %d ngày qua)." % [c.name, MEET_WINDOW])
	var n: = note(w, id)
	if int(n.get("counsel_m", -1)) == w.m:
		return _fail("Đã khuyên nhủ %s tháng này." % c.name)
	if not Crisis.PATHS.has(path) or path == "sa_nga":
		return _fail("Hướng khuyên không hợp lệ.")
	if not _spend(w, act_days(w, "counsel")):
		pass
	var b: = minf(35.0, 10.0 + charm(w) / 5.0 + c.favor / 5.0)
	var bonus: Dictionary = c.crisis["bonus"]
	bonus[path] = float(bonus.get(path, 0.0)) + b
	c.favor = minf(100.0, c.favor + 5.0)
	n["counsel_m"] = w.m
	var t: = "Khuyên nhủ %s: %s." % [c.name, PATH_HINT[path].to_lower()]
	log_line(w, t)
	return _ok(t)


const TRAIN_MAX: = 2
const TRAIN_AGE_FLOOR: = 0.25
const TRAIN_PLACE: = 1.3

const TRAIN_CITY_STAT: = {0: "quan_su", 1: "giao_duc", 2: "quan_su", 3: "giao_duc", 4: "sx", 5: "kinh_te"}


static func trained_this_month(w: World) -> int:
	return int(w.play.get("train_n", 0)) if int(w.play.get("train_m", -1)) == w.m else 0



static func train_place_ok(w: World, stat: int) -> bool:
	if stat >= Defs.N_STATS:
		return not capital_nations(w).is_empty()
	var cid: = here(w)
	if (stat == Defs.TRI or stat == Defs.CHINH) and w.has_feature(cid, "hoc_phu"):
		return true
	if (stat == Defs.VO or stat == Defs.QUAN) and w.has_feature(cid, "vo_duong"):
		return true
	return float(w.cities[cid].get(TRAIN_CITY_STAT[stat], 0)) >= 60.0


static func train_place_name(stat: int) -> String:
	if stat >= Defs.N_STATS:
		return "kinh đô"
	return {"quan_su": "thành Quân sự ≥ 60", "giao_duc": "thành Giáo dục ≥ 60", "sx": "thành Sản xuất ≥ 60", "kinh_te": "thành Kinh tế ≥ 60"}[TRAIN_CITY_STAT[stat]]



static func train_gain(w: World, stat: int) -> float:
	var p: = w.player()
	var n: = trained_this_month(w)
	if n >= TRAIN_MAX:
		return 0.0
	var age_stat: = Defs.CHINH if stat >= Defs.N_STATS else stat
	var k: = 2.5 * float(Defs.NGO_MULT[p.ngo]) * maxf(TRAIN_AGE_FLOOR, Defs.age_growth(age_stat, p.age(w.m)))
	if train_place_ok(w, stat):
		k *= TRAIN_PLACE
	if n >= 1:
		k *= 0.5
	var v: = pstat(w, stat)
	var pt: = float(v[1])
	if pt <= 0.0:
		return 0.0
	return k * maxf(0.0, pt - float(v[0])) / pt


static func train(w: World, stat: int) -> Dictionary:
	var p: = w.player()
	if stat < 0 or stat > Defs.N_STATS:
		return _fail("Chỉ số không hợp lệ.")
	if trained_this_month(w) >= TRAIN_MAX:
		return _fail("Đã tu dưỡng %d lần tháng này; sức người có hạn." % TRAIN_MAX)
	if not _spend(w, act_days(w, "train")):
		pass
	var gain: = train_gain(w, stat)
	w.play["train_n"] = trained_this_month(w) + 1
	w.play["train_m"] = w.m
	var nm: = "Mị lực"
	if stat >= Defs.N_STATS:
		p.mi_real += gain
	else:
		p.real[stat] = float(p.real[stat]) + gain
		p.focus = [stat]
		nm = Defs.STAT_NAMES[stat]
	var t: = "Tự tu dưỡng %s: +%.1f%s." % [nm, gain, " (nơi hợp để rèn)" if train_place_ok(w, stat) else ""]
	log_line(w, t)
	return _ok(t)






static func has_clerks(w: World) -> bool:
	var p: = w.player()
	if p.office_key == "":
		return false
	var key: = p.office_key.split("/")[1]
	var oid: = Appointment.office_of_key(key)
	return float(Defs.OFFICES[oid]["weight"]) >= 2.0



static func office_days(w: World) -> int:
	return OFFICE_DAYS if w.player().office_key != "" and not has_clerks(w) else 0


static func befriend(w: World) -> Dictionary:
	var caps: = capital_nations(w)
	if caps.is_empty():
		return _fail("Chỉ kết giao quan lại được ở kinh đô.")
	if money(w) < BEFRIEND_COST:
		return _fail("Cần %d lượng để mở tiệc." % BEFRIEND_COST)
	if not _spend(w, act_days(w, "befriend")):
		pass
	var nid: String = caps[0]
	var gain: = 4.0 + charm(w) / 10.0
	w.clan["money"] = money(w) - BEFRIEND_COST
	w.play["influence"][nid] = float(w.play["influence"].get(nid, 0.0)) + gain
	w.clan["prestige"] = prestige(w) + 1.0
	var t: = "Mở tiệc kết giao quan lại %s: Ảnh hưởng +%.0f." % [w.nation_name(nid), gain]
	log_line(w, t)
	return _ok(t)






static func end_month(w: World) -> Dictionary:
	var old_m: = w.m
	w.play["report"] = []
	_sync_retainers(w)
	_apply_task_env(w)
	Sim.tick(w)
	_new_month(w, old_m)
	var news: Array = []
	for e in w.news:
		if int(e["m"]) == old_m and str(e["k"]) != "an":
			news.append(e)
	return {"lines": (w.play["report"] as Array).duplicate(), "news": news}


static func _new_month(w: World, old_m: int) -> void :
	var p: = w.player()

	var near: = "" if p == null else p.city_id
	var mine: Array = retainers(w)
	for id in w.play["recommended"]:
		var c: = w.ch(str(id))
		if c != null and not mine.has(c) and c.city_id == near:
			mine.append(c)
	for c: Character in mine:
		for e in c.history:
			if int(e["m"]) == old_m and not str(e["t"]).begins_with("Nhậm chức") and not str(e["t"]).begins_with("Được "):
				report(w, "%s: %s." % [c.name, e["t"]])

	for id in w.play.get("stars", []):
		var c: = w.ch(str(id))
		if c == null or mine.has(c) or c.city_id != near:
			continue
		for e in c.history:
			var t: = str(e["t"])
			if int(e["m"]) == old_m and (t.begins_with("Nhậm chức") or t.begins_with("Rời chức") or t.begins_with("Đỗ ") or t.begins_with("Qua đời") or t.begins_with("Được thăng")):
				report(w, "★ %s: %s." % [c.name, t])
	if p != null:
		for e in p.history:
			if int(e["m"]) == old_m:
				report(w, "Bạn: %s." % str(e["t"]).replace("[Định mệnh] ", ""))
	if p == null or not p.alive:
		w.play["over"] = "death"
		return

	p.fame = maxf(p.fame, minf(100.0, prestige(w) / 3.0))

	if p.office_key != "":
		var oid: = Appointment.office_id_of(p)
		var sal: = float(Defs.OFFICES[oid]["weight"]) * 40.0
		w.clan["money"] = money(w) + sal
		w.play["influence"][p.nation_id] = float(w.play["influence"].get(p.nation_id, 0.0)) + 1.0
		w.clan["prestige"] = prestige(w) + 0.5

	for c: Character in retainers(w):
		if not c.alive:
			(w.clan["retainers"] as Array).erase(c.id)
			w.play["tasks"].erase(c.id)
			studies(w).erase(c.id)
			w.play["salary"].erase(c.id)
		elif c.loyalty < 25.0 and w.rng(["leave", c.id]).randf() < 0.05:
			_release(w, c)
			report(w, "%s bất mãn, bỏ đi khỏi %s." % [c.name, w.clan["name"]])

	var cf: = clan_cashflow(w)
	var steward: bool = cf[1]
	w.play["last_income"] = cf[0]
	var m2: = money(w) + float(cf[0])
	if m2 < 0.0:
		m2 = 0.0
		for c: Character in retainers(w):
			c.loyalty = maxf(0.0, c.loyalty - 5.0)
		report(w, "Gia tộc cạn tiền, nợ lương môn khách (Trung thành −5).")
	w.clan["money"] = m2
	for c: Character in retainers(w):
		c.loyalty = minf(100.0, c.loyalty + 0.5)

	w.play["day"] = office_days(w)
	_sync_retainers(w)
	_arrivals(w)
	w.play["eye"] = mini(int(w.play["eye_max"]), int(w.play["eye"]) + int(w.play.get("eye_regen", EYE_REGEN)))

	var keep: Array = []
	for l in w.play["leads"]:
		var lc: = w.ch(str(l["id"]))
		if w.m - int(l["m"]) < LEAD_LIFE and lc != null and lc.alive and lc.city_id == str(l["city"]):
			keep.append(l)
	w.play["leads"] = keep

	var sus: = maxf(0.0, float(w.play["suspicion"]) - 1.0)
	if sus >= 60.0:
		w.clan["prestige"] = maxf(0.0, prestige(w) - 30.0)
		w.play["influence"][p.nation_id] = maxf(0.0, float(w.play["influence"].get(p.nation_id, 0.0)) - 20.0)
		report(w, "Triều đình %s nghi kỵ %s vì đưa người sang nước khác: Danh vọng −30, Ảnh hưởng −20." % [w.nation_name(p.nation_id), w.clan["name"]])
		sus = 30.0
	w.play["suspicion"] = sus

	for id in w.notebook:
		var c: = w.ch(str(id))
		var n: Dictionary = w.notebook[id]
		if c == null or not c.alive:
			continue
		var pred: Array = n.get("pred", [])
		for i in pred.duplicate():
			if float(c.real[int(i)]) >= 75.0:
				pred.erase(i)
				w.play["stats"]["predicted"] = int(w.play["stats"]["predicted"]) + 1
				var up: = bool(n.get("uplift", false))
				report(w, "Lời tiên đoán ứng nghiệm: %s đã thành tài về %s (Ngộ đạo +%d%s)." % [c.name, Defs.STAT_NAMES[int(i)], 15 if up else 10, ", người do bạn khuyên đổi nghề" if up else ""])
				_add_ngo(w, 15 if up else 10)
	_deliver_probes(w)
	_career_checks(w)
	Purse.month(w)
	Repute.tick(w)
	for c: Character in retainers(w):
		if study_of(w, c) == "giao_du" and study_pause(w, c) == "" and not c.has_trait("tham_tai")\
		and w.rng(["giao_du", c.id, w.m]).randf() < 0.02:
			c.traits.append("tham_tai")
			report(w, "%s ăn chơi lâu ngày, nhiễm thói tham tài." % c.name)

	for c: Character in retainers(w):
		if job_of(w, c) == "" and study_of(w, c) == "" and c.max_real() >= 50.0:
			c.loyalty = maxf(0.0, c.loyalty - 1.0)
	apply_teaching(w)

	var keep_pay: Array = []
	for pay in w.play.get("payouts", []):
		if int(pay["m"]) <= w.m:
			w.clan["money"] = money(w) + float(pay["amt"])
			report(w, str(pay["t"]))
		else:
			keep_pay.append(pay)
	w.play["payouts"] = keep_pay
	_expire_choices(w)
	_roll_choices(w)

	if w.month() == 1:
		_check_tier(w)
	var ending: = Endings.check(w)
	if ending != "":
		w.play["ending"] = ending
		w.play["over"] = "ending"
		report(w, "Thiên mệnh đã định: %s!" % Endings.NAMES[ending])
	elif w.m >= end_m(w):
		w.play["over"] = "time"



static func clan_cashflow(w: World) -> Array:
	studies(w)
	var p: = w.player()
	var income: = BASE_INCOME + (float(p.real[Defs.THUONG]) + float(p.real[Defs.SX])) / 2.0
	income += int(w.clan.get("workshops", 0)) * workshop_income(w)
	var cost: = float(w.clan.get("troops", 0)) * TROOP_UPKEEP
	var steward: = false
	for c: Character in retainers(w):
		var task: = str(w.play["tasks"].get(c.id, ""))
		cost += float(w.play["salary"].get(c.id, 0)) + float(TASKS[task]["cost"]) + float(TASKS[study_of(w, c)]["cost"])
		if task_pause(w, c) != "":
			continue
		if task == "kinh_doanh":
			income += maxf(0.0, c.role_score("thuong_nhan") - 20.0) * 1.2 * (1.0 - c.skim) * (BOTH_MULT if both_on(w, c) else 1.0) * trade_mult(c)
		if task == "quan_gia" and c.role_score("quan_van") >= 50.0:
			steward = true
	if w.clan.has("houses"):
		cost += maxf(0.0, float((w.clan["houses"] as Dictionary).size() - 1)) * HOUSE_UPKEEP
		cost += float(w.clan.get("carts", 0)) * CART_UPKEEP
	return [income - cost, steward]


static func tier_requirements(w: World) -> Dictionary:
	var t: = clan_tier(w)
	if t >= MAX_TIER_SLICE:
		return {}
	var loyal: = 0
	for c: Character in retainers(w):
		if c.loyalty >= 60.0:
			loyal += 1
	var req: = {"prestige": 70.0, "money": 1000.0, "loyal": 2, "office": false} if t == 1 else {"prestige": 160.0, "money": 3000.0, "loyal": 3, "office": true}
	var has_office: = false
	for id in w.play["recommended"]:
		var c: = w.ch(str(id))
		if c != null and c.alive and c.office_key != "" and Appointment.weight_of(c) >= 1.5:
			has_office = true
	req["now_loyal"] = loyal
	req["now_office"] = has_office
	req["met"] = prestige(w) >= float(req["prestige"]) and money(w) >= float(req["money"]) and loyal >= int(req["loyal"]) and (has_office or not bool(req["office"]))
	return req


static func _check_tier(w: World) -> void :
	var req: = tier_requirements(w)
	if req.is_empty() or not bool(req["met"]):
		return
	w.clan["tier"] = clan_tier(w) + 1
	var t: = "%s thăng lên %s!" % [w.clan["name"], CLAN_TIER_NAMES[clan_tier(w)]]
	log_line(w, t)
	report(w, t)
	w.add_news(t, [], "quoc_gia")



static func score(w: World) -> Dictionary:
	var parts: = {}
	parts["Danh vọng"] = prestige(w)
	parts["Ngân lượng / 50"] = money(w) / 50.0
	var off: = 0.0
	var placed: = 0
	for id in w.play["recommended"]:
		var c: = w.ch(str(id))
		if c != null and c.alive and c.office_key != "":
			var oid: = Appointment.office_id_of(c)
			off += c.office_score(oid) * float(Defs.OFFICES[oid]["weight"]) / 2.0
			placed += 1
	parts["Người bạn tiến cử đang tại chức"] = off
	var ret: = 0.0
	for c: Character in retainers(w):
		ret += c.max_real() / 3.0
	parts["Môn khách"] = ret
	parts["Gia thế"] = (clan_tier(w) - 1) * 60.0
	parts["Ngộ đạo"] = float(w.play["ngo_dao"])
	var total: = 0.0
	for k in parts:
		total += float(parts[k])
	return {"parts": parts, "total": total, "placed": placed}
