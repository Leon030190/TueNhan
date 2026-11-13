extends Control




const C_BG: = Color("16140f")
const C_PANEL: = Color("211e18")
const C_PANEL2: = Color("2a261e")
const C_LINE: = Color("3d362a")
const C_TEXT: = Color("e8dec8")
const C_DIM: = Color("968b74")
const C_GOLD: = Color("d9b064")
const C_RED: = Color("d47a62")
const C_GREEN: = Color("97c482")
const C_BLUE: = Color("82aed6")
const C_PURPLE: = Color("b998d9")

const FILTERS: = ["Còn sống", "Ngọc thô (TN ≥ 75, chưa ai dùng)", "Quan chức", "Đang khủng hoảng", "Có định mệnh trong 2 năm", "Ẩn cao nhân / hư danh", "Đã mất", "Tất cả"]
const SORTS: = ["Tiềm năng cao nhất ↓", "Thực lực cao nhất ↓", "Tuổi ↑", "Danh tiếng ↓"]
const TIERS: = ["Mắt thần (sự thật)", "Công khai (AI thấy)", "Sơ cấp", "Trung cấp", "Cao cấp", "Tối cao"]
const FATE_ST: = {"cho": "chờ", "xay_ra": "đã xảy ra", "tranh": "đã tránh được"}

var w: World
var world_seed: = 1
var sel_id: = ""
var tier: = -1

var date_lbl: Label
var player_lbl: RichTextLabel
var seed_box: SpinBox
var tabs: TabContainer
var tree: Tree
var detail: RichTextLabel
var nation_txt: RichTextLabel
var news_txt: RichTextLabel
var stats_txt: RichTextLabel
var filter_opt: OptionButton
var sort_opt: OptionButton
var tier_opt: OptionButton
var search: LineEdit
var count_lbl: Label


func _ready() -> void :
	var args: = _args()
	world_seed = int(args.get("seed", "1"))
	theme = _make_theme()
	_build()
	_new_world()
	if args.has("months"):
		Sim.run(w, int(args["months"]))
	if args.has("tier"):
		tier = int(args["tier"])
		tier_opt.select(tier + 1)
	if args.has("select"):
		for c: Character in w.chars.values():
			if c.name.to_lower().contains(str(args["select"]).to_lower()):
				sel_id = c.id
				break
	_refresh()
	if args.has("tab"):
		tabs.current_tab = int(args["tab"])
	if args.has("shot"):
		for k in 5:
			await get_tree().process_frame
		get_viewport().get_texture().get_image().save_png(str(args["shot"]))
		get_tree().quit()


func _args() -> Dictionary:
	var d: = {}
	for a in OS.get_cmdline_user_args():
		var kv: = a.trim_prefix("--").split("=", true, 1)
		d[kv[0]] = kv[1] if kv.size() > 1 else "1"
	return d




func _sb(bg: Color, border: Color = C_LINE, pad: int = 8) -> StyleBoxFlat:
	var s: = StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(1)
	s.set_corner_radius_all(4)
	s.set_content_margin_all(pad)
	return s


func _make_theme() -> Theme:
	var t: = Theme.new()
	var f: = SystemFont.new()
	f.font_names = PackedStringArray(["Segoe UI", "Arial", "Noto Sans", "DejaVu Sans"])
	t.default_font = f
	t.default_font_size = 15
	t.set_color("font_color", "Label", C_TEXT)
	t.set_color("default_color", "RichTextLabel", C_TEXT)
	t.set_stylebox("normal", "RichTextLabel", _sb(C_PANEL, C_LINE, 10))
	t.set_stylebox("panel", "TabContainer", _sb(C_PANEL, C_LINE, 6))
	t.set_stylebox("tab_selected", "TabContainer", _sb(C_PANEL2, C_GOLD, 8))
	t.set_stylebox("tab_unselected", "TabContainer", _sb(C_BG, C_LINE, 8))
	t.set_stylebox("tab_hovered", "TabContainer", _sb(C_PANEL2, C_LINE, 8))
	t.set_color("font_selected_color", "TabContainer", C_GOLD)
	t.set_color("font_unselected_color", "TabContainer", C_DIM)
	for cls in ["Button", "OptionButton"]:
		t.set_stylebox("normal", cls, _sb(C_PANEL2, C_LINE, 6))
		t.set_stylebox("hover", cls, _sb(Color("383226"), C_GOLD, 6))
		t.set_stylebox("pressed", cls, _sb(Color("4a4130"), C_GOLD, 6))
		t.set_stylebox("focus", cls, _sb(Color(0, 0, 0, 0), C_GOLD, 6))
		t.set_color("font_color", cls, C_TEXT)
		t.set_color("font_hover_color", cls, C_GOLD)
	t.set_stylebox("normal", "LineEdit", _sb(C_PANEL2, C_LINE, 6))
	t.set_stylebox("normal", "SpinBox", _sb(C_PANEL2, C_LINE, 4))
	t.set_stylebox("panel", "Tree", _sb(C_PANEL, C_LINE, 4))
	t.set_stylebox("selected", "Tree", _sb(Color("4a4130"), C_GOLD, 2))
	t.set_stylebox("selected_focus", "Tree", _sb(Color("4a4130"), C_GOLD, 2))
	t.set_stylebox("title_button_normal", "Tree", _sb(C_PANEL2, C_LINE, 4))
	t.set_color("font_color", "Tree", C_TEXT)
	t.set_color("font_selected_color", "Tree", C_GOLD)
	t.set_color("title_button_color", "Tree", C_GOLD)
	t.set_color("guide_color", "Tree", Color(1, 1, 1, 0.04))
	t.set_stylebox("panel", "PopupMenu", _sb(C_PANEL2, C_GOLD, 6))
	t.set_color("font_color", "PopupMenu", C_TEXT)
	t.set_color("font_hover_color", "PopupMenu", C_GOLD)
	return t


func _build() -> void :
	var bg: = ColorRect.new()
	bg.color = C_BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var margin: = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	add_child(margin)
	var root: = VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	margin.add_child(root)


	var top: = HBoxContainer.new()
	top.add_theme_constant_override("separation", 10)
	root.add_child(top)
	var back: = Button.new()
	back.text = "← Về game"
	back.pressed.connect( func() -> void : get_tree().change_scene_to_file("res://game/scenes/main.tscn"))
	top.add_child(back)
	var title: = Label.new()
	title.text = "TUỆ NHÃN · Bàn mô phỏng"
	title.add_theme_color_override("font_color", C_GOLD)
	title.add_theme_font_size_override("font_size", 22)
	top.add_child(title)
	date_lbl = Label.new()
	date_lbl.add_theme_color_override("font_color", C_DIM)
	top.add_child(date_lbl)
	var sp: = Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(sp)
	for spec in [["+1 tháng", 1], ["+1 năm", 12], ["+5 năm", 60]]:
		var b: = Button.new()
		b.text = spec[0]
		var n: int = spec[1]
		b.pressed.connect( func() -> void : _advance(n))
		top.add_child(b)
	var sl: = Label.new()
	sl.text = "  Seed"
	top.add_child(sl)
	seed_box = SpinBox.new()
	seed_box.min_value = 1
	seed_box.max_value = 999999
	seed_box.value = world_seed
	seed_box.custom_minimum_size.x = 110
	top.add_child(seed_box)
	var regen: = Button.new()
	regen.text = "Tạo lại thế giới"
	regen.pressed.connect( func() -> void :
		world_seed = int(seed_box.value)
		_new_world()
		_refresh())
	top.add_child(regen)

	player_lbl = RichTextLabel.new()
	player_lbl.bbcode_enabled = true
	player_lbl.fit_content = true
	player_lbl.scroll_active = false
	root.add_child(player_lbl)

	tabs = TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(tabs)


	var split: = HSplitContainer.new()
	split.name = "NhanVat"
	tabs.add_child(split)
	tabs.set_tab_title(0, "Nhân vật")
	var left: = VBoxContainer.new()
	left.custom_minimum_size.x = 820
	left.add_theme_constant_override("separation", 6)
	split.add_child(left)
	var fbar: = HBoxContainer.new()
	fbar.add_theme_constant_override("separation", 6)
	left.add_child(fbar)
	filter_opt = _option(FILTERS)
	filter_opt.item_selected.connect( func(_i: int) -> void : _fill_tree())
	fbar.add_child(filter_opt)
	sort_opt = _option(SORTS)
	sort_opt.item_selected.connect( func(_i: int) -> void : _fill_tree())
	fbar.add_child(sort_opt)
	search = LineEdit.new()
	search.placeholder_text = "Tìm tên…"
	search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	search.text_changed.connect( func(_t: String) -> void : _fill_tree())
	fbar.add_child(search)
	count_lbl = Label.new()
	count_lbl.add_theme_color_override("font_color", C_DIM)
	fbar.add_child(count_lbl)
	tree = Tree.new()
	tree.columns = 7
	tree.column_titles_visible = true
	tree.hide_root = true
	tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var titles: = ["Tên", "Tuổi", "Nơi ở", "Nghề / Chức vụ", "Tiềm năng", "Thực lực", "Thiên phú"]
	var widths: = [170, 50, 90, 190, 90, 90, 200]
	for i in titles.size():
		tree.set_column_title(i, titles[i])
		tree.set_column_custom_minimum_width(i, widths[i])
		tree.set_column_expand(i, i == 3 or i == 6)
		tree.set_column_clip_content(i, true)
	tree.item_selected.connect(_on_select)
	left.add_child(tree)

	var right: = VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 6)
	split.add_child(right)
	var tbar: = HBoxContainer.new()
	right.add_child(tbar)
	var tl: = Label.new()
	tl.text = "Góc nhìn:"
	tbar.add_child(tl)
	tier_opt = _option(TIERS)
	tier_opt.item_selected.connect( func(i: int) -> void :
		tier = i - 1
		_show_detail())
	tbar.add_child(tier_opt)
	detail = _rich_box()
	right.add_child(detail)

	nation_txt = _rich_tab("QuocGia", "Quốc gia")
	news_txt = _rich_tab("TinTuc", "Tin tức")
	stats_txt = _rich_tab("ThongKe", "Thống kê")


func _option(items: Array) -> OptionButton:
	var o: = OptionButton.new()
	for it in items:
		o.add_item(str(it))
	return o


func _rich_box() -> RichTextLabel:
	var r: = RichTextLabel.new()
	r.bbcode_enabled = true
	r.selection_enabled = true
	r.size_flags_vertical = Control.SIZE_EXPAND_FILL
	r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return r


func _rich_tab(node_name: String, title: String) -> RichTextLabel:
	var r: = _rich_box()
	r.name = node_name
	tabs.add_child(r)
	tabs.set_tab_title(tabs.get_tab_count() - 1, title)
	return r




func _new_world() -> void :
	w = WorldGen.generate(world_seed)
	sel_id = ""
	for c: Character in w.chars.values():
		if c.special == "lam_van":
			sel_id = c.id


func _advance(n: int) -> void :
	Sim.run(w, n)
	_refresh()


func _refresh() -> void :
	date_lbl.text = "%s · seed %d · %d người còn sống" % [World.date_cap(w.m), w.world_seed, w.living().size()]
	_fill_player()
	_fill_tree()
	_show_detail()
	_fill_nations()
	_fill_news()
	_fill_stats()


func _on_select() -> void :
	var it: = tree.get_selected()
	if it == null:
		return
	sel_id = str(it.get_metadata(0))
	_show_detail()




static func _hex(c: Color) -> String:
	return c.to_html(false)


static func _col(text: String, c: Color) -> String:
	return "[color=#%s]%s[/color]" % [_hex(c), text]


static func grade_color(v: float) -> Color:
	if v >= 100.0:
		return C_RED
	if v >= 90.0:
		return Color("e8925a")
	if v >= 75.0:
		return C_GOLD
	if v >= 60.0:
		return C_BLUE
	if v >= 40.0:
		return C_GREEN
	if v >= 20.0:
		return C_TEXT
	return C_DIM


func _role_text(c: Character) -> String:
	var s: = ""
	if not c.alive:
		return "Đã mất (%s)" % c.death_cause
	if c.office_key != "":
		s = "%s · %s" % [Appointment.office_label_of(w, c), w.nation_name(c.nation_id)]
	elif c.is_player:
		s = "Nhân vật chính"
	else:
		s = Defs.prof_name(c.profession)
		if c.nation_id != "":
			s += " · " + w.nation_name(c.nation_id)
	if not c.crisis.is_empty():
		s += " · khủng hoảng"
	return s


func _pass_filter(c: Character) -> bool:
	match filter_opt.selected:
		0:
			return c.alive
		1:
			return c.alive and not c.is_player and c.office_key == "" and c.nation_id == "" and c.max_pot() >= 75.0
		2:
			return c.alive and c.office_key != ""
		3:
			return c.alive and not c.crisis.is_empty()
		4:
			if not c.alive:
				return false
			for f in c.fate:
				if str(f["st"]) == "cho" and int(f["m"]) <= w.m + 24:
					return true
			return false
		5:
			return c.special == "an_cao_nhan" or c.special == "hu_danh"
		6:
			return not c.alive
	return true


func _fill_player() -> void :
	var p: = w.player()
	if p == null:
		player_lbl.text = ""
		return
	var parts: Array = []
	for i in Defs.N_STATS:
		parts.append("%s %d/%d" % [Defs.STAT_SHORT[i], roundi(p.real[i]), roundi(p.pot[i])])
	parts.append("Mị %d/%d" % [roundi(p.mi_real), roundi(p.mi_pot)])
	var tl: Array = p.talents.map( func(t: String) -> String: return GameData.talent_name(t))
	player_lbl.text = "%s %s, %d tuổi · Mệnh cách %s · Ngộ tính %s · %s · Thiên phú: %s   %s" % [
		_col("★", C_GOLD), _col(p.name, C_GOLD), p.age(w.m), _col(p.destiny, C_PURPLE), Defs.NGO_NAMES[p.ngo], 
		"  ".join(parts), ", ".join(tl) if not tl.is_empty() else "—", 
		_col("(%s · Ngân lượng %d)" % [str(w.clan.get("name", "")), roundi(float(w.clan.get("money", 0)))], C_DIM)]


func _fill_tree() -> void :
	tree.clear()
	var root: = tree.create_item()
	var q: = search.text.strip_edges().to_lower()
	var list: Array = []
	for c: Character in w.chars.values():
		if not _pass_filter(c):
			continue
		if q != "" and not c.name.to_lower().contains(q):
			continue
		list.append(c)
	match sort_opt.selected:
		0:
			list.sort_custom( func(a: Character, b: Character) -> bool: return a.max_pot() > b.max_pot())
		1:
			list.sort_custom( func(a: Character, b: Character) -> bool: return a.max_real() > b.max_real())
		2:
			list.sort_custom( func(a: Character, b: Character) -> bool: return a.birth_m > b.birth_m)
		3:
			list.sort_custom( func(a: Character, b: Character) -> bool: return a.fame > b.fame)
	count_lbl.text = "%d người" % list.size()
	var selected_item: TreeItem = null
	for c: Character in list:
		var it: = tree.create_item(root)
		it.set_text(0, ("★ " if c.is_player else "") + c.name)
		it.set_text(1, str(c.age(w.m) if c.alive else c.age(c.death_m)))
		it.set_text(2, w.city_name(c.city_id))
		it.set_text(3, _role_text(c))
		var tp: = c.top_pot()
		it.set_text(4, "%s %d" % [Defs.STAT_SHORT[tp], roundi(c.pot[tp])])
		it.set_custom_color(4, grade_color(float(c.pot[tp])))
		var tr: = c.top_real()
		it.set_text(5, "%s %d" % [Defs.STAT_SHORT[tr], roundi(c.real[tr])])
		it.set_custom_color(5, grade_color(float(c.real[tr])))
		var tl: Array = c.talents.map( func(t: String) -> String: return GameData.talent_name(t))
		it.set_text(6, ", ".join(tl))
		it.set_metadata(0, c.id)
		if c.is_player:
			it.set_custom_color(0, C_GOLD)
		elif c.special == "lam_van":
			it.set_custom_color(0, C_PURPLE)
		if not c.alive:
			for col in 4:
				it.set_custom_color(col, C_DIM)
		if c.id == sel_id:
			selected_item = it
	if selected_item != null:
		selected_item.select(0)
		tree.scroll_to_item(selected_item)


func _show_detail() -> void :
	var c: = w.ch(sel_id)
	if c == null:
		detail.text = _col("Chọn một người ở danh sách bên trái.", C_DIM)
		return
	detail.text = _truth_text(c) if tier < 0 else _appraisal_text(c, tier)
	detail.scroll_to_line(0)


func _header(c: Character) -> String:
	var s: = "[font_size=22]%s[/font_size]  %s\n" % [_col(c.name, C_GOLD), _col("(%s, %d tuổi)" % ["Nữ" if c.female else "Nam", c.age(w.m) if c.alive else c.age(c.death_m)], C_DIM)]
	s += "%s · %s" % [_role_text(c), w.city_name(c.city_id)]
	if c.faction_id != "" and c.nation_id != "":
		s += " · phe " + str(w.nations[c.nation_id]["factions"][c.faction_id]["name"])
	return s + "\n"


func _stat_row(cells: Array) -> String:
	var s: = ""
	for x in cells:
		s += "[cell]%s[/cell]" % str(x)
	return s


func _truth_text(c: Character) -> String:
	var s: = _header(c)
	match c.special:
		"lam_van":
			s += _col("Nhân vật mẫu của GDD 6.6.D, có định mệnh bị phế tay vào tháng 7 năm 3.\n", C_PURPLE)
		"an_cao_nhan":
			s += _col("Ẩn cao nhân: cố tình tỏ ra tầm thường (hồ sơ giả ×0,45).\n", C_PURPLE)
		"hu_danh":
			s += _col("Kẻ hư danh: tỏ ra giỏi hơn thật (hồ sơ giả thổi phồng).\n", C_RED)
	s += "\nNgộ tính %s (×%.2f) · Ý chí %d · Tham vọng %d · Trung thành %d · Danh tiếng %d · Ẩn tàng %d\n" % [
		Defs.NGO_NAMES[c.ngo], float(Defs.NGO_MULT[c.ngo]), roundi(c.y_chi), roundi(c.tham_vong), roundi(c.loyalty), roundi(c.fame), roundi(c.concealment)]
	var foc: Array = c.focus.map( func(i: int) -> String: return Defs.STAT_NAMES[i])
	s += "Tâm trạng %s · Sức khỏe %d · Tuổi thọ (định mệnh) %d · Môi trường %s · Tu dưỡng: %s" % [
		Defs.MOOD_NAMES.get(c.mood, c.mood), roundi(c.health), floori(c.lifespan_m / 12.0), Defs.ENVS.get(c.env, Defs.ENVS[""])["name"], 
		", ".join(foc) if not foc.is_empty() else "không (sống qua ngày)"]
	if c.mentor_m > 0:
		s += " · được cao nhân chỉ dạy %s (%d tháng)" % [Defs.STAT_NAMES[c.mentor_stat], c.mentor_m]
	s += "\n\n"
	var p5: = Growth.project(c, w.m, 60)
	var p10: = Growth.project(c, w.m, 120)
	var pv: = Appraisal.perceived_vals(w, c)
	s += "[table=7]" + _stat_row([_col("Chỉ số", C_DIM), _col("Thực", C_DIM), _col("Tiềm năng", C_DIM), _col("Phân loại TN", C_DIM), _col("AI thấy", C_DIM), _col("+5 năm", C_DIM), _col("+10 năm", C_DIM)])
	for i in Defs.N_STATS:
		var r: = float(c.real[i])
		var p: = float(c.pot[i])
		s += _stat_row([
			Defs.STAT_NAMES[i] + ("  •" if c.in_focus(i) else ""), 
			_col(str(roundi(r)), grade_color(r)), 
			_col(str(roundi(p)), grade_color(p)), 
			Defs.grade(p), 
			_col(str(roundi(pv[i])), C_DIM), 
			str(roundi(p5[i])), str(roundi(p10[i]))])
	s += "[/table]\n"
	s += "Mị lực %d / %d (AI thấy %d)\n" % [roundi(c.mi_real), roundi(c.mi_pot), roundi(Appraisal.perceived_mi(w, c))]
	var roles: Array = []
	for role in Defs.ROLE_ORDER:
		roles.append("%s %d" % [Defs.ROLES[role]["name"], roundi(c.role_score(role) + Talents.role_bonus(c, role))])
	s += "\nVai trò: " + " · ".join(roles) + "\n"
	if c.office_key != "":
		s += "Công lao: tháng này %.1f · năm nay %.1f · tổng %.0f\n" % [c.merit_m, c.merit_y, c.merit_total]
	s += "\n" + _col("Thiên phú", C_GOLD) + "\n"
	if c.talents.is_empty():
		s += _col("  (không có)\n", C_DIM)
	for t in c.talents:
		var d: = GameData.talent(t)
		s += "  %s %s — %s\n" % [_col(str(d["name"]), C_GOLD), _col("[%s]" % Defs.RARITY_NAMES[int(d["rarity"])], C_DIM), d.get("desc", "")]
	s += _col("Tính cách", C_GOLD) + "\n  " + ", ".join(c.traits.map( func(t: String) -> String: return GameData.trait_name(t))) + "\n"
	if not c.injuries.is_empty():
		s += _col("Thương tật", C_RED) + "\n"
		for inj in c.injuries:
			s += "  %s%s\n" % [inj["name"], " (vĩnh viễn)" if int(inj["months"]) < 0 else " (còn %d tháng)" % int(inj["months"])]
	if not c.crisis.is_empty():
		s += "\n" + _col("Khủng hoảng: %s, còn %d tháng" % [c.crisis.get("cause", ""), int(c.crisis["m_left"])], C_RED) + "\n"
		var pr: = Crisis.probabilities(w, c)
		for k in Crisis.PATHS:
			s += "  %-24s %3.0f%%\n" % [Crisis.PATH_NAMES[k], float(pr[k]) * 100.0]
	s += "\n" + _col("Định mệnh (giống nhau ở mọi vòng đời)", C_PURPLE) + "\n"
	if c.fate.is_empty():
		s += _col("  (không có biến cố định sẵn)\n", C_DIM)
	for f in c.fate:
		var st: = str(f["st"])
		var colr: = C_TEXT if st == "cho" else (C_DIM if st == "tranh" else C_RED)
		s += "  %s — %s — %s\n" % [World.date_cap(int(f["m"])), GameData.event_name(str(f["ev"])), _col(FATE_ST.get(st, st), colr)]
	s += "\n" + _col("Nhật ký (mới nhất trước)", C_GOLD) + "\n"
	var h: Array = c.history.duplicate()
	h.reverse()
	for e in h:
		s += "  %s  %s\n" % [_col(World.date_of(int(e["m"])), C_DIM), e["t"]]
	return s


func _range_text(b: Array) -> String:
	if b.is_empty():
		return _col("?", C_DIM)
	if int(b[0]) == int(b[1]):
		return _col(str(b[0]), grade_color(float(b[0])))
	return _col("%d–%d" % [int(b[0]), int(b[1])], grade_color((float(b[0]) + float(b[1])) / 2.0))


func _appraisal_text(c: Character, t: int) -> String:
	var rec: = Appraisal.appraise(w, c, t, w.player())
	var s: = _header(c)
	s += "\n" + _col("Thẩm định tầng %s · tốn %d Nhãn lực · Độ xuyên thấu %d" % [Defs.TIER_NAMES[t], int(Defs.TIER_COST[t]), int(Defs.TIER_PEN[t])], C_GOLD) + "\n"
	if t == 0:
		s += _col("Đây là thứ AI các nước và người thường nhìn thấy: chỉ số thực mơ hồ, không thấy tiềm năng.\n", C_DIM)
	if bool(rec["anomaly"]):
		s += _col("⚠ Bất thường: người này đang che giấu điều gì đó.\n", C_RED)
	if bool(rec["fake"]):
		s += _col("[debug] Đang nhìn thấy hồ sơ giả.\n", C_PURPLE)
	if bool(rec["masked"]):
		s += _col("[debug] Bị che mờ: dải rộng gấp đôi, thiên phú bị ẩn.\n", C_PURPLE)
	s += "\n[table=3]" + _stat_row([_col("Chỉ số", C_DIM), _col("Thực", C_DIM), _col("Tiềm năng", C_DIM)])
	for i in Defs.N_STATS:
		s += _stat_row([Defs.STAT_NAMES[i], _range_text(rec["real"][i]), _range_text(rec["pot"][i])])
	s += "[/table]\n\n"
	if rec.has("health"):
		s += "Sức khỏe %d" % int(rec["health"])
		var inj: Array = rec["injuries"]
		if not inj.is_empty():
			s += " · Thương tật: " + ", ".join(inj)
		s += "\n"
	if rec.has("ngo"):
		s += "Ngộ tính: %s\n" % Defs.NGO_NAMES[int(rec["ngo"])]
	if rec.has("talents"):
		var tl: Array = rec["talents"]
		s += "Thiên phú nhìn thấy: %s\n" % (", ".join(tl.map( func(x: String) -> String: return GameData.talent_name(x))) if not tl.is_empty() else "không thấy")
	if rec.has("traits"):
		s += "Tính cách: %s\n" % ", ".join((rec["traits"] as Array).map( func(x: String) -> String: return GameData.trait_name(x)))
		s += "Trung thành %d · Ý chí %d · Tham vọng %d\n" % [int(rec["loyalty"]), int(rec["y_chi"]), int(rec["tham_vong"])]
	if rec.has("crisis"):
		s += "\n" + _col("Đang khủng hoảng. Xác suất các hướng:", C_RED) + "\n"
		for k in Crisis.PATHS:
			s += "  %-24s %3.0f%%\n" % [Crisis.PATH_NAMES[k], float(rec["crisis"][k]) * 100.0]
	if rec.has("fate"):
		var fh: Array = rec["fate"]
		s += "\n" + _col("Thiên cơ (2 năm tới):", C_PURPLE) + " "
		if fh.is_empty():
			s += "bình lặng\n"
		else:
			s += ", ".join(fh.map( func(x: Dictionary) -> String: return "%s sau %d tháng" % [x["kind"], int(x["in"])])) + "\n"
	return s


func _fill_nations() -> void :
	var s: = ""
	for nid in w.nations:
		var nat: Dictionary = w.nations[nid]
		s += "[font_size=20]%s[/font_size]  %s\n" % [_col(str(nat["name"]), C_GOLD), _col("· " + str(nat.get("ruler", "")), C_DIM)]
		s += "Ngân khố %d (%+d/tháng) · Lương thực %d (%+d/tháng)%s · Quân %d · Chất lượng %.2f · Ổn định %d\n" % [
			roundi(nat["treasury"]), roundi(nat["last_income"]), roundi(nat["food"]), roundi(nat["last_food"]), 
			_col(" THIẾU LƯƠNG", C_RED) if bool(nat.get("shortage", false)) else "", roundi(nat["troops"]), float(nat["quality"]), roundi(nat["stability"])]
		var fp: Array = []
		for fid in nat["factions"]:
			fp.append("%s %d" % [nat["factions"][fid]["name"], roundi(nat["factions"][fid]["power"])])
		s += "Phe phái: " + " · ".join(fp) + "\n"
		s += "[table=6]" + _stat_row([_col("Chức vụ", C_DIM), _col("Người giữ", C_DIM), _col("Điểm thật", C_DIM), _col("AI thấy", C_DIM), _col("Hiệu suất", C_DIM), _col("Tiềm năng cao nhất", C_DIM)])
		for key in nat["offices"]:
			var oid: = Appointment.office_of_key(key)
			var c: = w.office_holder(nid, key)
			if c == null:
				s += _stat_row([Appointment.office_label(w, nid, key), _col("(trống)", C_RED), "", "", "0.00", ""])
				continue
			var real_s: = c.office_score(oid)
			var seen: = Appraisal.perceived_office_score(w, c, oid)
			var tp: = c.top_pot()
			s += _stat_row([Appointment.office_label(w, nid, key), c.name + (_col(" (hư danh)", C_RED) if c.special == "hu_danh" else ""), 
				_col(str(roundi(real_s)), grade_color(real_s)), _col(str(roundi(seen)), C_DIM), 
				"%.2f" % NationSim.eff(w, nid, key), "%s %d" % [Defs.STAT_SHORT[tp], roundi(c.pot[tp])]])
		s += "[/table]\n"
		s += "[table=7]" + _stat_row([_col("Thành", C_DIM), _col("Dân số", C_DIM), _col("Kinh tế", C_DIM), _col("Sản xuất", C_DIM), _col("An ninh", C_DIM), _col("Giáo dục", C_DIM), _col("Phồn vinh", C_DIM)])
		for cid in w.nation_cities(nid):
			var city: Dictionary = w.cities[cid]
			s += _stat_row([city["name"], roundi(city["pop"]), roundi(city["kinh_te"]), roundi(city["sx"]), roundi(city["an_ninh"]), roundi(city["giao_duc"]), roundi(city["phon_vinh"])])
		s += "[/table]\n\n"
	s += _col("Quan hệ ngoại giao", C_GOLD) + "\n"
	for key in w.relations:
		var parts: PackedStringArray = str(key).split("|")
		s += "  %s – %s: %d\n" % [w.nation_name(parts[0]), w.nation_name(parts[1]), roundi(w.relations[key])]
	nation_txt.text = s


func _fill_news() -> void :
	var s: = ""
	var n: = w.news.size()
	for k in range(n - 1, maxi(-1, n - 300), -1):
		var e: Dictionary = w.news[k]
		var colr: = C_TEXT
		match str(e["k"]):
			"bien_co", "chien_su":
				colr = C_RED
			"co_duyen":
				colr = C_GOLD
			"bo_nhiem":
				colr = C_BLUE
			"an":
				colr = C_PURPLE
		s += "%s  %s\n" % [_col(World.date_of(int(e["m"])), C_DIM), _col(str(e["t"]), colr)]
	news_txt.text = s if s != "" else _col("Chưa có tin tức. Bấm +1 năm.", C_DIM)


func _fill_stats() -> void :
	var s: = _col("Bộ đếm sự kiện từ đầu ván", C_GOLD) + "\n"
	var keys: Array = w.counters.keys()
	keys.sort()
	for k in keys:
		s += "  %-28s %d\n" % [k, int(w.counters[k])]
	var gems: = 0
	for c: Character in w.living():
		if not c.is_player and c.office_key == "" and c.nation_id == "" and c.max_pot() >= 75.0:
			gems += 1
	s += "\nNgọc thô đang tự do: %d\n" % gems
	stats_txt.text = s
