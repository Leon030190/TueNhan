extends Control


const MapView: = preload("res://game/scenes/map_view.gd")
var tex: Texture2D
var cities: Array = []


func _ready() -> void :
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	tex = load("res://assets/art/map/world.png")
	var f: = FileAccess.open("res://data/world.json", FileAccess.READ)
	if f != null:
		var d: Dictionary = JSON.parse_string(f.get_as_text())
		for c in d.get("cities", []):
			var p: Array = c.get("pos", [])
			if p.size() == 2:
				cities.append([str(c["id"]), Vector2(float(p[0]), float(p[1]))])
	resized.connect(queue_redraw)


func _draw() -> void :
	if tex == null:
		return
	var ts: = Vector2(tex.get_size())
	var sc: = maxf(size.x / ts.x, size.y / ts.y)
	var dsz: = ts * sc
	var org: = (size - dsz) / 2.0
	draw_texture_rect(tex, Rect2(org, dsz), false)
	var r: = MapView.CITY_R * sc * 0.98
	for c in cities:
		var art: Texture2D = MapView.art("cities/" + str(MapView.CITY_ART.get(str(c[0]), "thanh_tran")))
		if art != null:
			var p: Vector2 = org + (c[1] as Vector2) * dsz
			draw_texture_rect(art, Rect2(p - Vector2(r, r), Vector2(r, r) * 2.0), false)
