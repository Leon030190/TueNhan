extends Control


var main: Node


func setup(m: Node) -> void :
	main = m


const KEYART: = "res://assets/art/promo/keyart_title.png"
const TITLE_FONT: = "res://assets/fonts/PlayfairDisplay.ttf"


func _ready() -> void :
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	Music.set_context("chu_de")
	var art: = _tex(KEYART)
	if art != null:

		var bg: = TextureRect.new()
		bg.texture = art
		bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(bg)
		add_child(_shade())
	else:
		add_child(preload("res://game/scenes/menu_bg.gd").new())


	var col: = UIKit.vbox(4)
	col.anchor_left = 0.445
	col.anchor_right = 0.445
	col.anchor_top = 0.31
	col.anchor_bottom = 0.31
	col.grow_horizontal = Control.GROW_DIRECTION_BOTH
	col.custom_minimum_size.x = 360
	add_child(col)
	if art == null:
		var title: = UIKit.label("TUỆ NHÃN · Thức Anh Hùng", 40, UIKit.GOLD)
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col.add_child(title)
	col.add_child(UIKit.divider(1))
	if main.has_save():
		col.add_child(_big("Tiếp tục", func() -> void : main.continue_game(), "Chơi tiếp ván đã lưu", true))
	col.add_child(_big("Ván mới", func() -> void : main.show_start(1, randi_range(1, 999999)), "Chọn thế giới, độ dài một đời và Mệnh cách"))
	col.add_child(_big("Hướng dẫn", func() -> void : Guide.open(self), "Cách chơi, giao diện, các hệ thống"))
	col.add_child(_big("Nâng cấp", func() -> void : _open_shop(), "Dùng Thiên Cơ tích lũy qua các đời để nâng cấp vĩnh viễn (đang có %d)" % main.legacy.thien_co))
	col.add_child(_big("Cài đặt", _settings, "Màn hình, âm lượng nhạc, cảnh báo, hướng dẫn"))
	col.add_child(_big("Thoát", func() -> void : get_tree().quit()))

	var lg: Legacy = main.legacy
	var foot: = UIKit.label("Đã sống %d đời · Thiên Cơ %d" % [lg.history.size(), lg.thien_co] if lg.history.size() > 0 else "Con mắt tinh nhận ra anh hùng khi họ còn vô danh.", 14, Color(UIKit.TEXT, 0.75))
	foot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	foot.add_theme_constant_override("outline_size", 6)
	foot.add_theme_color_override("font_outline_color", Color(UIKit.BG, 0.85))
	col.add_child(UIKit.divider(1))
	col.add_child(foot)

	var ver: = UIKit.label("v%s" % str(ProjectSettings.get_setting("application/config/version", "")), 12, Color(UIKit.DIM, 0.8))
	ver.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	ver.position += Vector2(28, -28)
	add_child(ver)
	var dbg: = UIKit.button("👑 Bàn mô phỏng (Debug)", func() -> void : main.open_debug(), "Debug: xem toàn bộ sự thật của thế giới và mô phỏng")
	dbg.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	dbg.position -= Vector2(36, 24)
	dbg.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	dbg.grow_vertical = Control.GROW_DIRECTION_BEGIN
	dbg.add_theme_color_override("font_color", UIKit.GOLD)
	dbg.modulate = Color(1, 1, 1, 0.85)
	add_child(dbg)



func _shade() -> Control:
	var g: = Gradient.new()
	var ink: = Color(0.04, 0.03, 0.02)
	g.offsets = PackedFloat32Array([0.0, 0.6, 1.0])
	g.colors = PackedColorArray([Color(ink, 0.85), Color(ink, 0.55), Color(ink, 0.0)])
	var gt: = GradientTexture2D.new()
	gt.gradient = g
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(1.0, 0.5)
	gt.width = 256
	gt.height = 256
	var r: = TextureRect.new()
	r.texture = gt
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_SCALE
	r.anchor_left = 0.29
	r.anchor_right = 0.6
	r.anchor_top = 0.26
	r.anchor_bottom = 0.84
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


func _tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path)
	if FileAccess.file_exists(path):
		var img: = Image.load_from_file(ProjectSettings.globalize_path(path))
		if img != null:
			return ImageTexture.create_from_image(img)
	return null


static var _font: Font = null


static func title_font() -> Font:
	if _font == null:
		var f: FontFile = load(TITLE_FONT) if ResourceLoader.exists(TITLE_FONT) else null
		if f == null and FileAccess.file_exists(TITLE_FONT):
			f = FontFile.new()
			f.load_dynamic_font(ProjectSettings.globalize_path(TITLE_FONT))
		if f == null:
			return null
		var v: = FontVariation.new()
		v.base_font = f
		v.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): 600}
		_font = v
	return _font



func _big(text: String, cb: Callable, tip: String = "", primary: bool = false) -> Button:
	var b: = UIKit.button(text, cb, tip)
	b.flat = true
	b.custom_minimum_size = Vector2(360, 46)
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var f: = title_font()
	if f != null:
		b.add_theme_font_override("font", f)
	b.add_theme_font_size_override("font_size", 27 if primary else 24)
	var empty: = StyleBoxEmpty.new()
	for st in ["normal", "hover", "pressed", "focus", "disabled"]:
		b.add_theme_stylebox_override(st, empty)
	var hl: = UIKit.sb(Color(UIKit.GOLD, 0.1), Color(UIKit.GOLD, 0.0), 6, 3)
	b.add_theme_stylebox_override("hover", hl)
	b.add_theme_stylebox_override("pressed", hl)
	b.add_theme_color_override("font_color", UIKit.GOLD if primary else UIKit.TEXT)
	b.add_theme_color_override("font_hover_color", Color("f3d38f"))
	b.add_theme_color_override("font_pressed_color", UIKit.GOLD)
	b.add_theme_color_override("font_focus_color", UIKit.TEXT)
	b.add_theme_constant_override("outline_size", 8)
	b.add_theme_color_override("font_outline_color", Color(UIKit.BG, 0.9))
	b.mouse_entered.connect( func() -> void : b.text = "~  %s  ~" % text)
	b.mouse_exited.connect( func() -> void : b.text = text)
	return b



func _open_shop() -> void :
	main.show_start(1, randi_range(1, 999999))
	main.current._shop_modal()


func _settings() -> void :
	var body: = UIKit.modal(self, "Cài đặt", 620)
	var fs: = CheckBox.new()
	fs.text = "Toàn màn hình"
	fs.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fs.toggled.connect( func(on: bool) -> void :
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if on else DisplayServer.WINDOW_MODE_MAXIMIZED)
		UIKit.set_pref("fullscreen", on))
	body.add_child(fs)
	body.add_child(Music.volume_row())
	var ga: = CheckBox.new()
	ga.text = "Tự mở Hướng dẫn khi bắt đầu ván đầu tiên"
	ga.button_pressed = not bool(UIKit.pref("guide_seen", false))
	ga.toggled.connect( func(on: bool) -> void : UIKit.set_pref("guide_seen", not on))
	body.add_child(ga)
	var row: = UIKit.hbox(10)
	row.add_child(UIKit.wrap_label("Các hộp cảnh báo đã chọn \"Không hiện lại nữa\":", 14, UIKit.DIM))
	row.add_child(UIKit.spacer())
	row.add_child(UIKit.button("Bật lại tất cả", func() -> void :
		UIKit.reset_warnings()
		UIKit.close_modal(body)))
	body.add_child(row)
	var r2: = UIKit.hbox(8)
	r2.add_child(UIKit.spacer())
	r2.add_child(UIKit.button("Đóng", func() -> void : UIKit.close_modal(body)))
	body.add_child(r2)
