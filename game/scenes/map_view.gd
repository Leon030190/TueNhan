extends Control








signal city_pressed(cid: String)

const NATION_COLOR: = {
	"dai_ha": Color("d9b064"), "bac_nguyen": Color("82aed6"), "nam_cam": Color("97c482"), 
	"tay_lang": Color("c4a0e0"), "dong_hai": Color("6ec7c2"), 
}
const SEA_COLOR: = Color("4f7f9e")


const CITY_ART: = {
	"thien_kinh": "kinh_do", "soc_phong": "vuong_dinh", "thuong_son": "son_thanh", 
	"vong_hai": "hai_thanh", "ngoc_cang": "hai_thanh", 
	"van_chau": "thanh_tran", "nam_phong": "thanh_tran", 
	"lac_thuy": "ben_cang", "hai_mon": "ben_cang", "hong_pho": "ben_cang", "bong_chau": "ben_cang", 
	"binh_lang": "cua_ai", "hac_thuy": "cua_ai", "kiem_mon": "cua_ai", 
	"lang_cu": "trai_du_muc", "ho_thi": "trai_du_muc", "diem_tri": "trai_du_muc", 
	"bach_sa": "oc_dao", "van_dinh": "vo_duong", "thanh_o": "xuong_thuyen", "thanh_ha": "hoc_phu", 
	"cam_giang": "lang_lua", "thach_coc": "mo_sat", "bach_loc": "y_quan", "tra_son": "y_quan", 
	"ngan_khe": "tram_dich", 
}
const CITY_R: = 90.0
const VIG_MIN_R: = 20.0

var w: World
var buttons: = {}
var big: = false
var mode: = "local"
var region: = ""
var _rect: = Rect2(0, 0, 1, 1)
var _scale: = 1.0
var _off: = Vector2.ZERO
const WORLD_PX: = Vector2(2400, 1400)
const ART_DIR: = "res://assets/art/map/"
static var _tex_cache: = {}
var mark: = ""
var _view: = {}
var _sea: = {}
var _label_rects: Array = []
var _trip_from: = ""
var _trip_to: = ""
var _trip_t: = 0.0
var animate: = true



func play_travel(from: String, to: String, done: Callable) -> void :
	if not animate or not _view.has(from) or not _view.has(to) or not is_inside_tree():
		done.call()
		return
	_trip_from = from
	_trip_to = to
	_trip_t = 0.0
	var tw: = create_tween()
	tw.tween_method( func(t: float) -> void :
		_trip_t = t
		queue_redraw(), 0.0, 1.0, 0.6)
	tw.tween_callback( func() -> void :
		_trip_from = ""
		_trip_to = ""
		done.call())


func setup(world: World) -> void :
	w = world


func _ready() -> void :
	clip_contents = true
	for pair in GameData.world_def().get("sea_links", []):
		_sea[World.rel_key(str(pair[0]), str(pair[1]))] = true
	for cid in w.cities:
		var b: = Button.new()
		b.text = w.city_name(cid)
		b.pressed.connect( func() -> void : city_pressed.emit(cid))
		add_child(b)
		buttons[cid] = b
	resized.connect(_layout)
	refresh()



static func data_pos(w: World, cid: String) -> Vector2:
	var p: Variant = w.cities[cid].get("pos", null)
	if p == null:
		for cd in GameData.world_def().get("cities", []):
			if str(cd["id"]) == cid:
				p = cd.get("pos", null)
	if p == null:
		return Vector2(0.5, 0.5)
	return Vector2(float(p[0]), float(p[1]))



static func home_region(cid: String) -> String:
	for cd in GameData.world_def().get("cities", []):
		if str(cd["id"]) == cid:
			return str(cd["nation"])
	return ""



static func region_rect(nid: String) -> Rect2:
	for nd in GameData.world_def().get("nations", []):
		if str(nd["id"]) == nid and nd.has("region"):
			var r: Array = nd["region"]
			return Rect2(float(r[0]), float(r[1]), float(r[2]) - float(r[0]), float(r[3]) - float(r[1]))
	return Rect2(0, 0, 1, 1)



static func art(name: String) -> Texture2D:
	if not _tex_cache.has(name):
		var path: = ART_DIR + name + ".png"
		var tex: Texture2D = null
		if ResourceLoader.exists(path):
			tex = load(path)
		elif FileAccess.file_exists(path):
			var img: = Image.load_from_file(ProjectSettings.globalize_path(path))
			if img != null:
				tex = ImageTexture.create_from_image(img)
		_tex_cache[name] = tex
	return _tex_cache[name]


func _visible_set() -> Array:
	match mode:
		"world":
			return w.cities.keys()
		"region":
			var res: Array = []
			var rr: = region_rect(region)
			for cid in w.cities:
				if rr.has_point(data_pos(w, cid)):
					res.append(cid)
			return res
	var here: = w.player().city_id
	var res2: Array = [here]
	for nb in w.cities[here]["links"]:
		if w.cities.has(nb):
			res2.append(nb)
	return res2


func _compute_view() -> void :
	_view.clear()
	var vis: = _visible_set()
	match mode:
		"world":
			_rect = Rect2(0, 0, 1, 1)
		"region":
			_rect = region_rect(region)
		_:
			var lo: = Vector2(1, 1)
			var hi: = Vector2(0, 0)
			for cid in vis:
				var p: = data_pos(w, cid)
				lo = Vector2(minf(lo.x, p.x), minf(lo.y, p.y))
				hi = Vector2(maxf(hi.x, p.x), maxf(hi.y, p.y))
			var pad: = Vector2(0.07, 0.11)
			_rect = Rect2(lo - pad, hi - lo + pad * 2.0)

	var rp: = Rect2(_rect.position * WORLD_PX, _rect.size * WORLD_PX)
	var sz: = size if size.x > 1.0 else custom_minimum_size
	_scale = minf(sz.x / rp.size.x, sz.y / rp.size.y)
	_off = sz / 2.0 - (rp.position + rp.size / 2.0) * _scale
	if mode == "local":

		var ws: = WORLD_PX * _scale
		if ws.x >= sz.x:
			_off.x = clampf(_off.x, sz.x - ws.x, 0.0)
		if ws.y >= sz.y:
			_off.y = clampf(_off.y, sz.y - ws.y, 0.0)

	for cid in vis:
		_view[cid] = true



func _background() -> Array:
	match mode:
		"world":
			return [art("world"), Rect2(0, 0, 1, 1)]
		"region":
			return [art("region_" + region), region_rect(region)]
	var nid: = home_region(w.player().city_id)
	var rr: = region_rect(nid)

	var sz: = size if size.x > 1.0 else custom_minimum_size
	var seen: = Rect2( - _off / _scale / WORLD_PX, sz / _scale / WORLD_PX)
	if art("region_" + nid) != null and rr.grow(0.002).encloses(seen):
		return [art("region_" + nid), rr]
	return [art("world"), Rect2(0, 0, 1, 1)]


func _pos(cid: String) -> Vector2:
	return _off + data_pos(w, cid) * WORLD_PX * _scale



func _vig_r() -> float:
	var r: = CITY_R * _scale
	return r if _background()[0] != null and r >= VIG_MIN_R else 0.0



func _art_rect() -> Rect2:
	var bg: Array = _background()
	if bg[0] == null:
		return Rect2(_off, WORLD_PX * _scale)
	var br: Rect2 = bg[1]
	return Rect2(_off + br.position * WORLD_PX * _scale, br.size * WORLD_PX * _scale)


func _layout() -> void :
	_compute_view()
	var vr: = _vig_r()
	var ar: = _art_rect()
	for cid in buttons:
		var b: Button = buttons[cid]
		b.visible = _view.has(cid)
		b.reset_size()
		b.position = _pos(cid) - b.size / 2.0
		var vig: = vr > 0.0 and art("cities/" + str(CITY_ART.get(cid, "thanh_tran"))) != null
		if vig:
			b.position.y += vr * 0.72
		if mode == "region" and _background()[0] != null:

			if b.position.y + b.size.y > ar.end.y:
				b.position.y = _pos(cid).y - (vr * 0.72 if vig else 0.0) - b.size.y
			b.position.x = clampf(b.position.x, ar.position.x, maxf(ar.position.x, ar.end.x - b.size.x))
			b.position.y = clampf(b.position.y, ar.position.y, maxf(ar.position.y, ar.end.y - b.size.y))
	_avoid_overlap(vr)
	queue_redraw()




func _avoid_overlap(vr: float) -> void :
	_label_rects.clear()
	var here: = w.player().city_id
	var order: Array = []
	for cid in buttons:
		if (buttons[cid] as Button).visible:
			order.append(cid)
	order.sort_custom( func(a: String, b: String) -> bool:
		if a == here or b == here:
			return a == here
		return _pos(a).y < _pos(b).y)
	var bound: = Rect2(Vector2(2, 2), size - Vector2(4, 4)) if mode == "local" else _art_rect()
	for cid in order:
		var b: Button = buttons[cid]
		var c: = _pos(str(cid))
		var gap: = maxf(vr * 0.72, 6.0)
		var cands: Array = [
			b.position, 
			Vector2(c.x - b.size.x / 2.0, c.y - gap - b.size.y), 
			Vector2(c.x + maxf(vr, 8.0) * 0.8, c.y - b.size.y / 2.0), 
			Vector2(c.x - maxf(vr, 8.0) * 0.8 - b.size.x, c.y - b.size.y / 2.0), 
		]
		var pick: Vector2 = cands[0]
		var best_hit: = INF
		for cand: Vector2 in cands:
			var q: = Vector2(clampf(cand.x, bound.position.x, maxf(bound.position.x, bound.end.x - b.size.x)), 
				clampf(cand.y, bound.position.y, maxf(bound.position.y, bound.end.y - b.size.y)))
			var rr: = Rect2(q, b.size).grow(2.0)
			var hit: = 0.0
			for o: Rect2 in _label_rects:
				var ov: = rr.intersection(o)
				hit += ov.size.x * ov.size.y
			hit += (q - cand).length() * 4.0
			if hit < best_hit:
				best_hit = hit
				pick = q
			if hit <= 0.0:
				break
		b.position = pick
		_label_rects.append(Rect2(pick, b.size))


func refresh() -> void :
	if w == null:
		return
	_compute_view()
	var here: = w.player().city_id
	var links: Dictionary = w.cities[here]["links"]
	for cid in buttons:
		var b: Button = buttons[cid]
		var nm: = w.city_name(cid)
		var is_cap: = false
		for nid in w.nations:
			if str(w.nations[nid]["capital"]) == cid:
				is_cap = true
		b.text = ("♛ " if is_cap else "") + nm
		b.add_theme_font_size_override("font_size", 17 if big else 13)
		var pad: = 7 if big else 3
		var tip: = str(w.cities[cid].get("desc", ""))
		var feats: Array = []
		for f in w.cities[cid].get("features", []):
			feats.append(str(Defs.FEATURES.get(f, {}).get("name", f)))
		if not feats.is_empty():
			tip += "\n" + ", ".join(feats) + "."
		if cid == here:
			b.add_theme_color_override("font_color", UIKit.BG)
			b.add_theme_stylebox_override("normal", UIKit.sb(UIKit.GOLD, UIKit.GOLD, pad))
			b.add_theme_stylebox_override("hover", UIKit.sb(UIKit.GOLD, UIKit.TEXT, pad))
			tip += "\n\nBạn đang ở đây."
		else:
			var nc: Color = NATION_COLOR.get(w.city_nation(cid), UIKit.DIM)
			b.add_theme_color_override("font_color", nc)
			b.add_theme_stylebox_override("normal", UIKit.sb(UIKit.PANEL2, nc.darkened(0.3), pad))
			b.add_theme_stylebox_override("hover", UIKit.sb(Color("3a3326"), nc, pad))
			if links.has(cid):
				tip += "\n\nBấm để đi tới (%d ngày%s)." % [PlayerOps.travel_days(w, cid), ", đường thủy" if _sea.has(World.rel_key(here, cid)) else ""]
			else:
				tip += "\n\nKhông có đường đi thẳng từ %s." % w.city_name(here)
		tip += "\nThuộc %s." % w.nation_name(w.city_nation(cid))
		b.tooltip_text = tip
	_layout()


func _draw() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), Color("1b1813"))
	if w == null:
		return
	var bg: Array = _background()
	var art_rect: = Rect2(_off, WORLD_PX * _scale)
	if bg[0] != null:
		var br: Rect2 = bg[1]
		art_rect = Rect2(_off + br.position * WORLD_PX * _scale, br.size * WORLD_PX * _scale)
		draw_texture_rect(bg[0], art_rect, false)
		if mode == "region":
			draw_rect(art_rect.grow(2.0), Color(UIKit.GOLD, 0.55), false, 2.0)
	var font: = get_theme_default_font()

	if mode == "world":
		for nid in w.nations:
			var cs: = w.nation_cities(nid)
			if cs.is_empty():
				continue
			var nc: Color = NATION_COLOR.get(nid, UIKit.DIM)
			var lp: = Vector2.ZERO
			var lab: Variant = w.nations[nid].get("label", null)
			if lab != null:
				lp = _off + Vector2(float(lab[0]), float(lab[1])) * WORLD_PX * _scale
			else:
				for cid in cs:
					lp += _pos(cid)
				lp = lp / float(cs.size()) + Vector2(0, -46)
			var txt: = w.nation_name(nid).to_upper()
			var tw: = font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
			var has_art: bool = bg[0] != null
			if has_art:
				draw_string_outline(font, lp + Vector2( - tw / 2.0, 8), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, 6, Color(UIKit.BG, 0.85))
			draw_string(font, lp + Vector2( - tw / 2.0, 8), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(nc, 0.95 if has_art else 0.4))

	for wr in w.wars:
		var fc: = str(wr["front"])
		if not _view.has(fc):
			continue
		var fp: = _pos(fc)
		draw_arc(fp, 34.0, 0.0, TAU, 32, Color(UIKit.RED, 0.8), 3.0)
		draw_string(font, fp + Vector2(30, -18), "⚔", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, UIKit.RED)
	var here: = w.player().city_id
	var drawn: = {}
	var placed: Array = []
	for a in w.cities:
		for b in w.cities[a]["links"]:
			if not w.cities.has(b):
				continue
			var k: = World.rel_key(a, b)
			if drawn.has(k):
				continue
			drawn[k] = true
			var va: = _view.has(a)
			var vb: = _view.has(b)
			if not va and not vb:
				continue
			var pa: = _pos(a)
			var pb: = _pos(b)
			var sea: = _sea.has(k)
			if not (va and vb):

				var from: = pa if va else pb
				var to: = from.lerp(pb if va else pa, 0.35)
				if mode == "region" and bg[0] != null:
					var seg: = _clip(from, to, art_rect)
					if seg.is_empty():
						continue
					to = seg[1]
				draw_line(from, to, Color(UIKit.LINE, 0.8), 1.5, true)
				continue
			var active: bool = str(a) == here or str(b) == here
			var small: = mode == "local"
			var col: = Color(UIKit.GOLD, 0.75) if active else Color(UIKit.LINE, 0.55 if small else 1.0)
			if sea:
				col = Color(SEA_COLOR, 0.95) if active else Color(SEA_COLOR, 0.4 if small else 0.6)
				draw_dashed_line(pa, pb, col, 2.5 if active else (1.5 if small else 2.0), 10.0, true)
			else:
				draw_line(pa, pb, col, 3.0 if active else (1.5 if small else 2.0), true)
			if small and not active:
				continue
			var mid: = (pa + pb) / 2.0
			var keep_out: = _vig_r() + 12.0
			for t in [0.5, 0.42, 0.58, 0.36, 0.64, 0.3, 0.7]:
				var cand: Vector2 = pa.lerp(pb, t)
				var clash: = false
				for q in placed:
					if cand.distance_to(q) < 24.0:
						clash = true
				if keep_out > 12.0:
					for oc in _view:
						if cand.distance_to(_pos(str(oc))) < keep_out:
							clash = true
				for lr: Rect2 in _label_rects:
					if lr.grow(10.0).has_point(cand):
						clash = true
				if not clash:
					mid = cand
					break
			placed.append(mid)
			var cost: = int(w.cities[a]["links"][b]) * (PlayerOps.SEA_DAYS if sea else PlayerOps.LAND_DAYS)
			var cr: = 9.0 if small else 12.0
			var fs: = 11 if small else 13
			draw_circle(mid, cr, Color("1b1813"))
			var cs: = str(cost)
			var tw: = font.get_string_size(cs, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
			draw_string(font, mid + Vector2( - tw / 2.0, fs * 0.36), cs, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, UIKit.GOLD if active else UIKit.DIM)

	var vr: = _vig_r()
	if vr > 0.0:
		var screen: = Rect2(Vector2.ZERO, size).grow(vr)
		for cid in w.cities:
			var tex: = art("cities/" + str(CITY_ART.get(cid, "thanh_tran")))
			var p: = _pos(str(cid))
			if tex != null and screen.has_point(p):
				if mode == "region" and not art_rect.has_point(p):
					continue
				var tint: = Color.WHITE if _view.has(cid) else Color(1, 1, 1, 0.5)
				var dst: = Rect2(p - Vector2(vr, vr) * 0.98, Vector2(vr, vr) * 1.96)
				if mode == "region" and bg[0] != null and not art_rect.encloses(dst):

					var cut: = dst.intersection(art_rect)
					if cut.size.x <= 0.0 or cut.size.y <= 0.0:
						continue
					var ts: = Vector2(tex.get_size())
					var src: = Rect2((cut.position - dst.position) / dst.size * ts, cut.size / dst.size * ts)
					draw_texture_rect_region(tex, cut, src, tint)
				else:
					draw_texture_rect(tex, dst, false, tint)
	if _view.has(here):
		draw_circle(_pos(here), 30.0 * (1.5 if big else 1.0), Color(UIKit.GOLD, 0.15))
	if _trip_to != "":
		var tp: = _pos(_trip_from).lerp(_pos(_trip_to), _trip_t)
		draw_circle(tp, 9.0, UIKit.GOLD)
		draw_arc(tp, 12.0, 0.0, TAU, 24, UIKit.BG, 2.0)
	if mark != "" and _view.has(mark):
		draw_arc(_pos(mark), 44.0 if big else 30.0, 0.0, TAU, 40, Color(UIKit.BLUE, 0.9), 2.5)
	if big:
		for cid in buttons:
			if not _view.has(cid):
				continue
			var note: = note_of(str(cid))
			if note != "":
				var bb: Button = buttons[cid]
				draw_string_outline(font, bb.position + Vector2(0, bb.size.y + 16), note, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, 5, Color(UIKit.BG, 0.9))
				draw_string(font, bb.position + Vector2(0, bb.size.y + 16), note, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, UIKit.TEXT)




static func _clip(a: Vector2, b: Vector2, r: Rect2) -> Array:
	var t0: = 0.0
	var t1: = 1.0
	var d: = b - a
	for k in 4:
		var p: float = [ - d.x, d.x, - d.y, d.y][k]
		var q: float = [a.x - r.position.x, r.end.x - a.x, a.y - r.position.y, r.end.y - a.y][k]
		if is_zero_approx(p):
			if q < 0.0:
				return []
			continue
		var t: = q / p
		if p < 0.0:
			t0 = maxf(t0, t)
		else:
			t1 = minf(t1, t)
		if t0 > t1:
			return []
	return [a + d * t0, a + d * t1]



func note_of(cid: String) -> String:
	var parts: Array = []
	if w.player().city_id == cid:
		parts.append("● bạn")
	var nr: = 0
	for c: Character in PlayerOps.retainers(w):
		if c.city_id == cid:
			nr += 1
	if nr > 0:
		parts.append("%d môn khách" % nr)
	var ns: = 0
	for id in w.play.get("stars", []):
		var c: = w.ch(str(id))
		if c != null and c.alive and c.city_id == cid:
			ns += 1
	if ns > 0:
		parts.append("★%d" % ns)
	var nl: = 0
	for l in w.play["leads"]:
		if str(l["city"]) == cid:
			nl += 1
	if nl > 0:
		parts.append("%d manh mối" % nl)
	return " · ".join(parts)
