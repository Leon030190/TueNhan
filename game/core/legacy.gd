class_name Legacy
extends RefCounted



const UPGRADE_ORDER: = ["tham_dinh", "ky_uc", "khoi_dau", "can_man"]
const UPGRADES: = {
	"tham_dinh": {"name": "Thẩm định", "levels": [
		{"cost": 15, "desc": "Nhãn lực tối đa +3"}, 
		{"cost": 30, "desc": "Sinh ra với 25 Ngộ đạo (mở sẵn tầng Cao cấp)"}, 
		{"cost": 60, "desc": "Nhãn lực hồi thêm +2 mỗi tháng"}, 
		{"cost": 100, "desc": "Sinh ra với 80 Ngộ đạo (mở sẵn tầng Tối cao)"}, 
	]}, 
	"ky_uc": {"name": "Ký ức", "levels": [
		{"cost": 15, "desc": "Thiên Thư nhớ dải tiềm năng đã thẩm định"}, 
		{"cost": 30, "desc": "Thiên Thư nhớ thiên phú, tính cách, ngộ tính"}, 
		{"cost": 60, "desc": "Thiên Thư nhớ các kiếp nạn / cơ duyên định mệnh đã chứng kiến"}, 
		{"cost": 100, "desc": "Thiên Thư nhớ trọn vẹn, cả kết cục của họ ở đời trước"}, 
	]}, 
	"khoi_dau": {"name": "Khởi đầu", "levels": [
		{"cost": 15, "desc": "+500 ngân lượng khởi đầu"}, 
		{"cost": 30, "desc": "+1 lựa chọn Mệnh cách (4)"}, 
		{"cost": 60, "desc": "Gia tộc khởi đầu là Thế gia, Danh vọng 80"}, 
		{"cost": 100, "desc": "+1 lựa chọn Mệnh cách (5) và được tung lại Mệnh cách một lần"}, 
	]}, 
	"can_man": {"name": "Cần mẫn", "levels": [
		{"cost": 150, "desc": "Làm mọi việc nhanh hơn 15% ở mọi đời sau"}, 
	]}, 
}
const ENDING_BONUS: = {"nguoi_dung_sau": 40, "thay_trieu": 40, "ngoai_bang": 30, "thong_nhat": 50}

var thien_co: int = 0
var upgrades: Dictionary = {"tham_dinh": 0, "ky_uc": 0, "khoi_dau": 0, "can_man": 0}
var books: Dictionary = {}
var lives: Dictionary = {}
var clans: Dictionary = {}
var tuc_tue: Dictionary = {}
var endings: Dictionary = {}
var history: Array = []


func level(branch: String) -> int:
	return int(upgrades.get(branch, 0))


func next_cost(branch: String) -> int:
	var lv: = level(branch)
	var lvls: Array = UPGRADES[branch]["levels"]
	return -1 if lv >= lvls.size() else int(lvls[lv]["cost"])


func buy(branch: String) -> Dictionary:
	var cost: = next_cost(branch)
	if cost < 0:
		return {"ok": false, "msg": "Nhánh này đã tối đa."}
	if thien_co < cost:
		return {"ok": false, "msg": "Cần %d Thiên Cơ." % cost}
	thien_co -= cost
	upgrades[branch] = level(branch) + 1
	var d: String = UPGRADES[branch]["levels"][level(branch) - 1]["desc"]
	return {"ok": true, "msg": "%s cấp %d: %s." % [UPGRADES[branch]["name"], level(branch), d]}


func destiny_count() -> int:
	return 3 + (1 if level("khoi_dau") >= 2 else 0) + (1 if level("khoi_dau") >= 4 else 0)


func can_reroll() -> bool:
	return level("khoi_dau") >= 4


func lives_of(world_seed: int) -> int:
	return int(lives.get(str(world_seed), 0))


func book(world_seed: int) -> Dictionary:
	return books.get(str(world_seed), {})





func apply_to_world(w: World) -> void :
	var p: = w.player()
	if level("tham_dinh") >= 1:
		w.play["eye_max"] = 13
		w.play["eye"] = 13
	if level("tham_dinh") >= 2:
		w.play["ngo_dao"] = maxi(int(w.play["ngo_dao"]), 25)
	if level("tham_dinh") >= 3:
		w.play["eye_regen"] = PlayerOps.EYE_REGEN + 2
	if level("tham_dinh") >= 4:
		w.play["ngo_dao"] = maxi(int(w.play["ngo_dao"]), 80)
	if level("khoi_dau") >= 1:
		w.clan["money"] = float(w.clan["money"]) + 500.0
	if level("khoi_dau") >= 3:
		w.clan["tier"] = maxi(int(w.clan["tier"]), 2)
		w.clan["prestige"] = maxf(float(w.clan["prestige"]), 80.0)
	w.play["memory"] = level("ky_uc")
	if level("can_man") >= 1:
		w.play["ap_bonus"] = 1

	var bk: = {}
	var src: = book(w.world_seed)
	for id in src:
		var c: = w.ch(str(id))
		if c != null and c.name == str(src[id]["name"]):
			bk[id] = (src[id] as Dictionary).duplicate(true)
	w.play["book"] = bk

	var cm: Dictionary = clans.get(str(w.world_seed), {})
	for rid in cm:
		if w.rivals.has(rid):
			if bool(cm[rid].get("kind", false)):
				w.rivals[rid]["met"] = true
			w.rivals[rid]["past_fall"] = str(cm[rid].get("fell", ""))

	var tt: Dictionary = tuc_tue.get(str(w.world_seed), {})
	for id in tt:
		var c: = w.ch(str(id))
		if c == null or not c.has_talent("tuc_tue"):
			continue
		var mem: Dictionary = tt[id]
		c.favor = clampf(float(mem.get("favor", 0.0)) * 0.5 + (20.0 if bool(mem.get("recommended", false)) else 0.0), 0.0, 100.0)
		var r: = Rng.make([w.world_seed, w.life, "tuctue", c.id])
		var bad: Array = mem.get("fates", [])
		for f in c.fate:
			if str(f["st"]) == "cho" and bad.has(str(f["ev"])) and r.randf() < 0.6:
				f["st"] = "tranh"
				c.add_log(w.m, "Mơ thấy kiếp trước, quyết né \"%s\"" % GameData.event_name(str(f["ev"])))
		c.add_log(w.m, "Mang ký ức mơ hồ về một kiếp sống khác")
	if p != null and lives_of(w.world_seed) > 0:
		PlayerOps.log_line(w, "Vòng đời thứ %d. Thiên Thư còn ghi %d người từ những kiếp trước." % [w.life, bk.size()])





func record_life(w: World, ending: String, score: float) -> Dictionary:
	var key: = str(w.world_seed)
	if not books.has(key):
		books[key] = {}
	var bk: Dictionary = books[key]
	var added: = 0
	var ids: Array = w.notebook.keys()
	for id in w.play.get("stars", []):
		if not ids.has(id):
			ids.append(id)
	for id in ids:
		var c: = w.ch(str(id))
		if c == null:
			continue
		var n: Dictionary = w.notebook.get(c.id, {})
		if not bk.has(c.id):
			added += 1
		var old: Dictionary = bk.get(c.id, {})
		var e: = {
			"name": c.name, "life": w.life, 
			"city": str(old.get("city", c.city_id)), 
			"prof": str(old.get("prof", c.profession)), 
			"appr": n.get("appr", old.get("appr", {})), 
			"fates": [], 
			"end": {"alive": c.alive, "status": PlayerOps.public_status(w, c), "top": c.top_real(), "real": roundi(c.max_real()), "death": c.death_cause}, 
		}
		if n.has("first_city"):
			e["city"] = n["first_city"]
		for f in c.fate:
			if str(f["st"]) == "xay_ra":
				(e["fates"] as Array).append({"m": int(f["m"]), "ev": str(f["ev"])})
		for f in old.get("fates", []):
			var dup: = false
			for g in e["fates"]:
				if int(g["m"]) == int(f["m"]):
					dup = true
			if not dup:
				(e["fates"] as Array).append(f)
		bk[c.id] = e

	var cm: Dictionary = clans.get(key, {})
	for rid in w.rivals:
		var rv: Dictionary = w.rivals[rid]
		var old_c: Dictionary = cm.get(rid, {})
		cm[rid] = {"kind": bool(old_c.get("kind", false)) or Rivals.known_kind(rv), "fell": str(rv.get("fallen", "")) if Rivals.is_fallen(rv) else str(old_c.get("fell", ""))}
	clans[key] = cm

	var tt: = {}
	for c: Character in w.chars.values():
		if c.has_talent("tuc_tue"):
			var bad: Array = []
			for f in c.fate:
				if str(f["st"]) == "xay_ra" and ["trong_thuong", "benh_nang", "mat_nguoi_than"].has(str(f["ev"])):
					bad.append(str(f["ev"]))
			tt[c.id] = {"favor": c.favor, "recommended": c.recommender == w.player_id, "fates": bad}
	tuc_tue[key] = tt
	var gain: = maxi(5, roundi(score / 20.0)) + int(ENDING_BONUS.get(ending, 0)) + 2 * int(w.play["stats"].get("predicted", 0))
	thien_co += gain
	lives[key] = lives_of(w.world_seed) + 1
	if ending != "":
		endings[ending] = int(endings.get(ending, 0)) + 1
	history.append({"seed": w.world_seed, "life": w.life, "score": roundi(score), "ending": ending, "thien_co": gain})
	return {"thien_co": gain, "added": added, "total": bk.size()}




func to_dict() -> Dictionary:
	return Serial.to_dict(self)


static func from_dict(d: Dictionary) -> Legacy:
	var lg: = Legacy.new()
	Serial.from_dict(lg, d)
	return lg


func save_file(path: String) -> Error:
	var f: = FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return FileAccess.get_open_error()
	f.store_buffer(var_to_bytes(to_dict()))
	return OK


static func load_file(path: String) -> Legacy:
	if not FileAccess.file_exists(path):
		return Legacy.new()
	var d: Variant = bytes_to_var(FileAccess.get_file_as_bytes(path))
	if typeof(d) != TYPE_DICTIONARY:
		return Legacy.new()
	return from_dict(d)
