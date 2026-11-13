class_name UIKit
extends RefCounted


const BG: = Color("16140f")
const PANEL: = Color("211e18")
const PANEL2: = Color("2a261e")
const PANEL3: = Color("332d22")
const LINE: = Color("3d362a")
const TEXT: = Color("e8dec8")
const DIM: = Color("968b74")
const GOLD: = Color("d9b064")
const RED: = Color("d47a62")
const GREEN: = Color("97c482")
const BLUE: = Color("82aed6")
const PURPLE: = Color("b998d9")


const ART_UI: = "res://assets/art/ui/"

const ART_MARGIN: = {
	"panel.png": Vector2i(30, 25), "modal.png": Vector2i(48, 40), 
	"button_normal.png": Vector2i(12, 10), "button_hover.png": Vector2i(12, 10), 
	"button_pressed.png": Vector2i(12, 10), "button_disabled.png": Vector2i(12, 10), 
	"tab_selected.png": Vector2i(9, 7), "tab_unselected.png": Vector2i(9, 7), "tab_hovered.png": Vector2i(9, 7), 
}
static var _tex_cache: = {}



static func art(file: String) -> Texture2D:
	if _tex_cache.has(file):
		return _tex_cache[file]
	var tex: Texture2D = null
	var path: = ART_UI + file
	if ResourceLoader.exists(path):
		tex = load(path)
	elif FileAccess.file_exists(path):
		var img: = Image.load_from_file(ProjectSettings.globalize_path(path))
		if img != null:
			tex = ImageTexture.create_from_image(img)
	_tex_cache[file] = tex
	return tex



static func tsb(file: String, pad_x: int, pad_y: int, fallback: StyleBox) -> StyleBox:
	var tex: = art(file)
	if tex == null:
		return fallback
	var s: = StyleBoxTexture.new()
	s.texture = tex
	var m: Vector2i = ART_MARGIN.get(file, Vector2i(8, 8))
	s.texture_margin_left = m.x
	s.texture_margin_right = m.x
	s.texture_margin_top = m.y
	s.texture_margin_bottom = m.y
	s.content_margin_left = pad_x
	s.content_margin_right = pad_x
	s.content_margin_top = pad_y
	s.content_margin_bottom = pad_y
	return s



static func _tab_sb(file: String, fallback: StyleBox) -> StyleBox:
	var s: = tsb(file, 12, 6, fallback)
	if s is StyleBoxTexture:
		(s as StyleBoxTexture).texture_margin_bottom = 0
	return s



static func icon(name: String, c: Color = DIM, px: int = 22) -> TextureRect:
	var tex: = art("icons/%s_24.png" % name)
	if tex == null:
		return null
	var r: = TextureRect.new()
	r.texture = tex
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r.custom_minimum_size = Vector2(px, px)
	r.modulate = c
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r



static func divider(n: int = 1) -> Control:
	var mid: = art("divider_%d_mid.png" % n)
	if mid == null:
		return HSeparator.new()
	var h: = HBoxContainer.new()
	h.add_theme_constant_override("separation", 0)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for part in ["left", "mid", "right"]:
		var r: = TextureRect.new()
		r.texture = art("divider_%d_%s.png" % [n, part])
		r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		r.stretch_mode = TextureRect.STRETCH_SCALE
		r.custom_minimum_size = Vector2(mid.get_width() if part == "mid" else 10, mid.get_height())
		if part != "mid":
			r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.add_child(r)
	return h


static func sb(bg: Color, border: Color = LINE, pad: int = 8, radius: int = 4) -> StyleBoxFlat:
	var s: = StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(1)
	s.set_corner_radius_all(radius)
	s.set_content_margin_all(pad)
	return s


static func make_theme() -> Theme:
	var t: = Theme.new()
	var f: = SystemFont.new()
	f.font_names = PackedStringArray(["Segoe UI", "Arial", "Noto Sans", "DejaVu Sans"])
	t.default_font = f
	t.default_font_size = 18
	t.set_color("font_color", "Label", TEXT)
	t.set_color("default_color", "RichTextLabel", TEXT)
	t.set_stylebox("normal", "RichTextLabel", sb(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 2))
	t.set_stylebox("panel", "PanelContainer", tsb("panel.png", 22, 18, sb(PANEL, LINE, 12, 6)))
	t.set_stylebox("panel", "TabContainer", sb(PANEL, LINE, 8, 6))
	t.set_stylebox("tab_selected", "TabContainer", _tab_sb("tab_selected.png", sb(PANEL2, GOLD, 12, 6)))
	t.set_stylebox("tab_unselected", "TabContainer", _tab_sb("tab_unselected.png", sb(BG, LINE, 12, 6)))
	t.set_stylebox("tab_hovered", "TabContainer", _tab_sb("tab_hovered.png", sb(PANEL2, LINE, 12, 6)))
	t.set_color("font_selected_color", "TabContainer", GOLD)
	t.set_color("font_unselected_color", "TabContainer", DIM)
	t.set_color("font_hovered_color", "TabContainer", TEXT)
	t.set_font_size("font_size", "TabContainer", 17)
	for cls in ["Button", "OptionButton"]:
		t.set_stylebox("normal", cls, tsb("button_normal.png", 20, 11, sb(PANEL2, LINE, 9, 6)))
		t.set_stylebox("hover", cls, tsb("button_hover.png", 20, 11, sb(Color("3a3326"), GOLD, 9, 6)))
		t.set_stylebox("pressed", cls, tsb("button_pressed.png", 20, 11, sb(Color("4a4130"), GOLD, 9, 6)))
		t.set_stylebox("disabled", cls, tsb("button_disabled.png", 20, 11, sb(Color("1d1a15"), Color("2c2720"), 9, 6)))
		t.set_stylebox("focus", cls, sb(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 9))
		t.set_color("font_color", cls, TEXT)
		t.set_color("font_hover_color", cls, GOLD)
		t.set_color("font_pressed_color", cls, GOLD)
		t.set_color("font_disabled_color", cls, Color("6a6252"))
		t.set_font_size("font_size", cls, 17)
	t.set_stylebox("normal", "LineEdit", sb(PANEL2, LINE, 9, 5))
	t.set_font_size("font_size", "LineEdit", 17)
	t.set_stylebox("normal", "SpinBox", sb(PANEL2, LINE, 6, 5))
	t.set_font_size("font_size", "SpinBox", 17)
	t.set_stylebox("panel", "Tree", sb(PANEL, LINE, 6, 6))
	t.set_stylebox("selected", "Tree", sb(Color("4a4130"), GOLD, 4, 4))
	t.set_stylebox("selected_focus", "Tree", sb(Color("4a4130"), GOLD, 4, 4))
	t.set_stylebox("focus", "Tree", sb(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 2))
	t.set_stylebox("title_button_normal", "Tree", sb(PANEL2, LINE, 6, 4))
	t.set_stylebox("title_button_hover", "Tree", sb(PANEL2, LINE, 6, 4))
	t.set_stylebox("title_button_pressed", "Tree", sb(PANEL2, LINE, 6, 4))
	t.set_color("font_color", "Tree", TEXT)
	t.set_color("font_selected_color", "Tree", GOLD)
	t.set_color("title_button_color", "Tree", DIM)
	t.set_color("guide_color", "Tree", Color(1, 1, 1, 0.04))
	t.set_font_size("font_size", "Tree", 16)
	t.set_font_size("title_button_font_size", "Tree", 16)
	t.set_constant("v_separation", "Tree", 10)
	t.set_stylebox("panel", "PopupMenu", sb(PANEL2, GOLD, 8, 6))
	t.set_color("font_color", "PopupMenu", TEXT)
	t.set_color("font_hover_color", "PopupMenu", GOLD)
	t.set_font_size("font_size", "PopupMenu", 17)
	t.set_stylebox("panel", "TooltipPanel", sb(PANEL3, GOLD, 10, 6))
	t.set_color("font_color", "TooltipLabel", TEXT)
	t.set_font_size("font_size", "TooltipLabel", 16)
	return t


static func col(text: String, c: Color) -> String:
	return "[color=#%s]%s[/color]" % [c.to_html(false), text]


static func grade_color(v: float) -> Color:
	if v >= 100.0:
		return RED
	if v >= 90.0:
		return Color("e8925a")
	if v >= 75.0:
		return GOLD
	if v >= 60.0:
		return BLUE
	if v >= 40.0:
		return GREEN
	if v >= 20.0:
		return TEXT
	return DIM


static func range_text(b: Array) -> String:
	if b.is_empty():
		return col("?", DIM)
	if int(b[0]) == int(b[1]):
		return col(str(b[0]), grade_color(float(b[0])))
	return col("%d–%d" % [int(b[0]), int(b[1])], grade_color((float(b[0]) + float(b[1])) / 2.0))


static func label(text: String, size: int = 17, c: Color = TEXT) -> Label:
	var l: = Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", c)
	return l


static func wrap_label(text: String, size: int = 17, c: Color = TEXT) -> Label:
	var l: = label(text, size, c)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size.x = 100
	return l


static func wrap_tip(t: String, width: int = 60) -> String:
	if t.length() <= width:
		return t
	var out: Array = []
	for para in t.replace(". ", ".\n").replace("; ", ";\n").split("\n"):
		var line: = ""
		for word in para.split(" ", false):
			if line.length() + word.length() + 1 > width and line != "":
				out.append(line)
				line = word
			else:
				line = word if line == "" else line + " " + word
		if line != "":
			out.append(line)
	return "\n".join(out)


static func button(text: String, cb: Callable, tip: String = "") -> Button:
	var b: = Button.new()
	b.text = text
	b.tooltip_text = wrap_tip(tip)
	b.custom_minimum_size.y = 36
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if cb.is_valid():
		b.pressed.connect(cb)
	return b


static func rich(fit: bool = false) -> RichTextLabel:
	var r: = RichTextLabel.new()
	r.bbcode_enabled = true
	r.selection_enabled = false
	r.fit_content = fit
	r.scroll_active = not fit
	if not fit:
		r.size_flags_vertical = Control.SIZE_EXPAND_FILL
	r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return r


static func panel(content: Control, bg: Color = PANEL, pad: int = 10) -> PanelContainer:
	var p: = PanelContainer.new()
	var flat: = sb(bg, LINE, pad)
	p.add_theme_stylebox_override("panel", tsb("panel.png", pad + 10, pad + 6, flat) if bg == PANEL else flat)
	p.add_child(content)
	return p


static func vbox(sep: int = 8) -> VBoxContainer:
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", sep)
	return v


static func hbox(sep: int = 8) -> HBoxContainer:
	var h: = HBoxContainer.new()
	h.add_theme_constant_override("separation", sep)
	return h


static func spacer() -> Control:
	var c: = Control.new()
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return c





const SETTINGS_PATH: = "user://settings.cfg"
static var settings_path: = SETTINGS_PATH


static func pref(key: String, default: Variant = null) -> Variant:
	var cf: = ConfigFile.new()
	if cf.load(settings_path) != OK:
		return default
	return cf.get_value("ui", key, default)



static func reset_warnings() -> void :
	var cf: = ConfigFile.new()
	if cf.load(settings_path) != OK or not cf.has_section("ui"):
		return
	for k in cf.get_section_keys("ui"):
		if str(k).begins_with("warn_"):
			cf.erase_section_key("ui", k)
	cf.save(settings_path)


static func set_pref(key: String, value: Variant) -> void :
	var cf: = ConfigFile.new()
	cf.load(settings_path)
	cf.set_value("ui", key, value)
	cf.save(settings_path)


static func modal(host: Control, title: String, width: int = 740) -> VBoxContainer:
	var overlay: = Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var dim: = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.68)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(dim)
	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	var body: = vbox(12)
	body.custom_minimum_size.x = width
	var p: = panel(body, PANEL2, 20)
	p.add_theme_stylebox_override("panel", tsb("modal.png", 28, 24, sb(PANEL2, GOLD, 20, 8)))
	center.add_child(p)

	var head: = hbox()
	var ph: = Control.new()
	ph.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_child(ph)
	var tl: = label(title, 24, GOLD)
	tl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	head.add_child(tl)
	var xb: = button(" ✕ ", func() -> void : overlay.queue_free())
	xb.custom_minimum_size = Vector2(40, 36)
	xb.resized.connect( func() -> void : ph.custom_minimum_size.x = xb.size.x)
	head.add_child(xb)
	body.add_child(head)
	body.add_child(divider(1))
	body.set_meta("overlay", overlay)
	host.add_child(overlay)
	return body


static func close_modal(body: Control) -> void :
	var o: Node = body.get_meta("overlay")
	if is_instance_valid(o):
		o.queue_free()
