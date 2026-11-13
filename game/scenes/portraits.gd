class_name Portraits
extends RefCounted





const DIR: = "res://assets/art/portraits/"


const EXTRA: = [
	{"sheet": "p0_1_a", "row": 1, "nation": "dai_ha", "sex": "m", "prof": "rich merchant", "look": "ordinary"}, 
	{"sheet": "p0_1_a", "row": 2, "nation": "dai_ha", "sex": "m", "prof": "soldier", "look": "plain and coarse"}, 
	{"sheet": "p0_1_b", "row": 1, "nation": "nam_cam", "sex": "m", "prof": "small trader", "look": "ordinary"}, 
	{"sheet": "p0_1_b", "row": 2, "nation": "nam_cam", "sex": "m", "prof": "soldier", "look": "plain and coarse"}, 
	{"sheet": "p0_2_a", "row": 1, "nation": "dai_ha", "sex": "f", "prof": "noble lady", "look": "strikingly handsome"}, 
	{"sheet": "p0_2_a", "row": 2, "nation": "nam_cam", "sex": "f", "prof": "farmer", "look": "plain and coarse"}, 
	{"sheet": "p0_2_b", "row": 1, "nation": "dai_ha", "sex": "f", "prof": "scholar's daughter", "look": "strikingly handsome"}, 
	{"sheet": "p0_2_b", "row": 2, "nation": "nam_cam", "sex": "f", "prof": "farmer", "look": "ordinary"}, 
	{"sheet": "s1_001", "row": 2, "nation": "bac_nguyen", "sex": "f", "prof": "herder", "look": "plain and coarse"}, 
	{"sheet": "s1_002", "row": 1, "nation": "bac_nguyen", "sex": "m", "prof": "herder", "look": "ordinary"}, 
	{"sheet": "s1_002", "row": 2, "nation": "dai_ha", "sex": "m", "prof": "scholar", "look": "strikingly handsome"}, 
	{"sheet": "s1_002", "row": 3, "nation": "dai_ha", "sex": "f", "prof": "small trader", "look": "ordinary"}, 
	{"sheet": "s1_003", "row": 2, "nation": "bac_nguyen", "sex": "m", "prof": "military officer", "look": "plain and coarse"}, 
	{"sheet": "s1_003", "row": 3, "nation": "dai_ha", "sex": "f", "prof": "noble lady", "look": "strikingly handsome"}, 
]


const PROF_GROUP: = {
	"soldier": "vo", "martial artist": "vo", "wandering swordsman": "vo", "wandering swordswoman": "vo", "military officer": "vo", "hunter": "vo", 
	"scholar": "van", "clerk": "van", "civil official": "van", "retired old official": "van", "physician": "van", "herbalist": "van", 
	"rich merchant": "buon", "small trader": "buon", "innkeeper": "buon", 
	"young noble": "quy", "noble lady": "quy", "scholar's daughter": "quy", "palace attendant": "quy", 
}

const GAME_GROUP: = {
	"binh_si": "vo", "vo_sinh": "vo", "kiem_khach": "vo", "vo_quan": "vo", "vo_cu_nhan": "vo", 
	"thu_sinh": "van", "lai_vien": "van", "thay_thuoc": "van", "quan_lai": "van", "tan_khoa": "van", "lao_than": "van", "cuu_quan": "van", 
	"thuong_nhan": "buon", "tieu_thuong": "buon", "nghe_nhan": "buon", "bien_si": "van", 
	"quy_toc": "quy", 
}

const KIN: = {"dai_ha": ["nam_cam", "tay_lang"], "nam_cam": ["dai_ha", "dong_hai"], "tay_lang": ["dai_ha"], 
	"dong_hai": ["nam_cam", "dai_ha"], "bac_nguyen": []}
const LOOK: = {"plain and coarse": 0, "ordinary": 1, "strikingly handsome": 2}

static var _people: Array = []
static var _tex: = {}


static func people() -> Array:
	if _people.is_empty():
		var src: Array = []
		var txt: = FileAccess.get_file_as_string(DIR + "cast.json")
		if txt != "":
			src = JSON.parse_string(txt)
		src.append_array(EXTRA)
		for e in src:
			var key: = "%s_r%d" % [e["sheet"], int(e["row"])]
			if ResourceLoader.exists(DIR + key + "_a1.png"):
				_people.append({"key": key, "nation": str(e["nation"]), "sex": str(e["sex"]), 
					"group": str(PROF_GROUP.get(str(e["prof"]), "dan")), "look": int(LOOK.get(str(e["look"]), 1))})
	return _people


static func _home(w: World, c: Character) -> String:
	var n: = MapView_home(c.city_id)
	return n if n != "" else (c.nation_id if c.nation_id != "" else "dai_ha")



static func MapView_home(cid: String) -> String:
	for cd in GameData.world_def().get("cities", []):
		if str(cd["id"]) == cid:
			return str(cd["nation"])
	return ""


static func _look_of(c: Character) -> int:
	var m: = maxf(c.mi_real, c.mi_pot * 0.8)
	return 0 if m < 30.0 else (2 if m >= 60.0 else 1)



static func assign(w: World, c: Character) -> String:
	if c.portrait != "" or people().is_empty():
		return c.portrait
	var nat: = _home(w, c)
	var grp: = str(GAME_GROUP.get(c.profession, "dan"))
	if c.special == "gia_chu" or c.office_key != "":
		grp = "van" if not ["vo_quan", "vo_cu_nhan"].has(c.profession) else "vo"
	var look: = _look_of(c)
	var sex: = "f" if c.female else "m"
	var used: = {}
	for o: Character in w.chars.values():
		if o.portrait != "":
			used[o.portrait] = int(used.get(o.portrait, 0)) + 1
	var r: = Rng.make([w.world_seed, "portrait", c.id])
	var best: = ""
	var bs: = - INF
	for p in people():
		if str(p["sex"]) != sex:
			continue
		var s: = 0.0
		if str(p["nation"]) == nat:
			s += 4.0
		elif (KIN.get(nat, []) as Array).has(str(p["nation"])):
			s += 1.5
		elif nat == "bac_nguyen" or str(p["nation"]) == "bac_nguyen":
			s -= 4.0
		if str(p["group"]) == grp:
			s += 3.0
		s += 2.0 - absf(float(p["look"]) - float(look)) * 1.5
		s -= float(used.get(str(p["key"]), 0)) * 2.5
		s += r.randf() * 0.8
		if s > bs:
			bs = s
			best = str(p["key"])
	c.portrait = best
	return best


static func tex(w: World, c: Character) -> Texture2D:
	if c == null:
		return null
	var key: = assign(w, c)
	if key == "":
		return null
	var age: = c.age(w.m)
	var path: = DIR + "%s_a%d.png" % [key, 1 if age < 32 else (2 if age < 53 else 3)]
	if not _tex.has(path):
		_tex[path] = load(path) if ResourceLoader.exists(path) else null
	return _tex[path]



static func bb(w: World, c: Character, width: int) -> String:
	var t: = tex(w, c)
	if t == null:
		return ""
	return "[img=%dx%d]%s[/img]" % [width, roundi(width * 1.25), t.resource_path]
