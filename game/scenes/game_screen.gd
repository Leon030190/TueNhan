extends Control



const MapView: = preload("res://game/scenes/map_view.gd")
const AdminPanel: = preload("res://game/scenes/admin_panel.gd")

var main: Node
var w: World
var sel: = "self"

var top_vals: = {}
var war_cell: Control
var end_btn: Button
var choices_btn: Button
var map_view: Control
var city_title: Label
var city_desc: Label
var city_stats: RichTextLabel
var city_cells: = {}
var city_btns: HFlowContainer
var log_txt: RichTextLabel
var tabs: TabContainer
var here_tree: Tree
var leads_box: VBoxContainer
var leads_scroll: ScrollContainer
var leads_title: Label
var known_title: Label
var book_tree: Tree
var ret_tree: Tree
var clan_tree: Tree
var court_tabs: TabContainer
var scout_btn: Button
var detail_btn: Button
var tea_btn: Button
var more_acts: Array = []
var more_title: = "Việc khác"
var more_pending: = false
var notice: = ""
var news_txt: RichTextLabel
var detail_txt: RichTextLabel
var action_box: HFlowContainer
var eye_box: HFlowContainer
var eye_line: HBoxContainer
var eye_head: Label
var msg_lbl: Label
var hint_txt: RichTextLabel


func setup(m: Node, world: World) -> void :
	main = m
	w = world
	ProfTree.ensure(w)


func _ready() -> void :
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()
	refresh_all()




func _build() -> void :
	var margin: = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 10)
	add_child(margin)
	var root: = UIKit.vbox(8)
	margin.add_child(root)


	var top: = UIKit.hbox(9)
	top.alignment = BoxContainer.ALIGNMENT_BEGIN
	root.add_child(UIKit.panel(top, UIKit.PANEL, 8))
	_cell(top, "date", "", 22)
	top.add_child(VSeparator.new())
	for spec in [["here", "Đang ở"], ["ap", "Ngày"], ["eye", "Nhãn lực"], ["money", "Ngân lượng"], ["prestige", "Danh vọng"], ["clan", "Gia tộc"], ["mat", "Đôi Mắt"]]:
		_cell(top, spec[0], spec[1])
	war_cell = _cell(top, "war", "Chiến sự")
	top.add_child(UIKit.spacer())
	var admin_btn: = UIKit.button("👑 Admin", func() -> void : AdminPanel.open(self), "Bảng điều khiển Admin / Thiên Mệnh: Thêm tài nguyên, sửa chỉ số, hệ thống game")
	admin_btn.add_theme_stylebox_override("normal", UIKit.sb(Color("3b2450"), UIKit.PURPLE, 8))
	admin_btn.add_theme_color_override("font_color", Color("ffd700"))
	admin_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var sys_btn: = UIKit.button("Hệ thống ▾", Callable(), "Lưu ván, về menu chính, hướng dẫn, bot tự chơi")
	sys_btn.pressed.connect( func() -> void : _sys_menu(sys_btn))
	for b in [UIKit.button("Bản đồ", func() -> void : _world_map_modal(""), "Bản đồ thế giới: các nước, thành trấn, đường đi, chiến sự"), 
			UIKit.button("Bản thân", func() -> void : select("self"), "Xem Mệnh cách, gia tộc, tự tu dưỡng (Tu dưỡng nằm ở đây)"), 
			admin_btn,
			sys_btn]:
		b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		top.add_child(b)
	choices_btn = UIKit.button("Việc chờ", _choices_modal, "Những việc đang chờ bạn quyết định")
	choices_btn.add_theme_stylebox_override("normal", UIKit.sb(Color("4a2a1c"), UIKit.RED, 8))
	choices_btn.add_theme_color_override("font_color", UIKit.RED)
	choices_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	choices_btn.icon = UIKit.art("icons/viec_cho_24.png")
	choices_btn.expand_icon = false
	choices_btn.add_theme_color_override("icon_normal_color", UIKit.RED)
	choices_btn.add_theme_color_override("icon_hover_color", UIKit.RED)
	choices_btn.add_theme_constant_override("icon_max_width", 16)
	top.add_child(choices_btn)
	end_btn = UIKit.button(" Nghỉ hết tháng ▶ ", _end_month, "Nghỉ ngơi tới cuối tháng; thế giới vận hành sang tháng mới")
	end_btn.add_theme_stylebox_override("normal", UIKit.sb(Color("4a3a1c"), UIKit.GOLD, 8))
	end_btn.add_theme_color_override("font_color", UIKit.GOLD)
	end_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(end_btn)

	var body: = UIKit.hbox(8)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(body)


	var left: = UIKit.vbox(8)
	left.custom_minimum_size.x = 370
	body.add_child(left)
	map_view = MapView.new()
	map_view.setup(w)
	map_view.custom_minimum_size = Vector2(360, 330)
	map_view.city_pressed.connect(_on_city)
	left.add_child(UIKit.panel(map_view, UIKit.PANEL, 4))
	var cbox: = UIKit.vbox(6)
	city_title = UIKit.label("", 20, UIKit.GOLD)
	cbox.add_child(city_title)
	city_desc = UIKit.wrap_label("", 13, UIKit.DIM)
	cbox.add_child(city_desc)
	var grid: = UIKit.hbox(4)
	for spec in [["kinh_te", "Kinh tế"], ["sx", "Sản xuất"], ["an_ninh", "An ninh"], ["giao_duc", "Giáo dục"]]:
		var cv: = UIKit.vbox(0)
		cv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var t: = UIKit.label(spec[1], 12, UIKit.DIM)
		t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cv.add_child(t)
		var v: = UIKit.label("", 17, UIKit.TEXT)
		v.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cv.add_child(v)
		city_cells[spec[0]] = v
		grid.add_child(cv)
	cbox.add_child(grid)
	city_stats = UIKit.rich(true)
	cbox.add_child(city_stats)
	city_btns = _flow()
	cbox.add_child(city_btns)
	left.add_child(UIKit.panel(cbox))
	var lbox: = UIKit.vbox(4)
	lbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	lbox.add_child(UIKit.label("Nhật ký", 15, UIKit.GOLD))
	log_txt = UIKit.rich()
	log_txt.add_theme_font_size_override("normal_font_size", 13)
	lbox.add_child(log_txt)
	var lp: = UIKit.panel(lbox)
	lp.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_child(lp)


	tabs = TabContainer.new()
	tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(tabs)
	var hbox: = UIKit.vbox(6)
	var lrow: = UIKit.hbox(10)
	leads_title = UIKit.label("", 15, UIKit.GOLD)
	leads_title.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	lrow.add_child(leads_title)
	lrow.add_child(UIKit.spacer())
	tea_btn = UIKit.button("Trà quán", func() -> void : _do_pop(Daily.teahouse(w), "Ngồi trà quán"), 
		"Rẻ hơn Dò la: nghe 0–1 lời đồn (phần nhiều người thường), đôi khi biết thêm về một thế gia")
	lrow.add_child(tea_btn)
	scout_btn = UIKit.button("Dò la", func() -> void : _do(PlayerOps.scout(w)), "Nghe ngóng lời đồn về những người đáng chú ý trong thành")
	lrow.add_child(scout_btn)
	hbox.add_child(lrow)
	leads_scroll = ScrollContainer.new()
	leads_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	leads_box = UIKit.vbox(4)
	leads_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	leads_scroll.add_child(leads_box)
	hbox.add_child(leads_scroll)
	known_title = UIKit.label("", 15, UIKit.GOLD)
	hbox.add_child(known_title)
	here_tree = _tree(["Tên", "Tuổi", "Thân phận", "Ghi chú"], [190, 45, 250, 150])
	here_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_child(here_tree)
	_tab(hbox, "Tại đây")
	book_tree = _tree(["Tên", "Tuổi", "Ở", "Thân phận", "Tiềm năng", "Thẩm định"], [170, 45, 85, 175, 95, 110])
	var bbox: = UIKit.vbox(6)
	bbox.add_child(UIKit.wrap_label("Sổ ghi chép của bạn: những người bạn đã gặp, kèm kết quả thẩm định gần nhất. Dùng để nhớ ai đáng quay lại, theo dõi viên ngọc thô lớn lên, so sánh trước khi chiêu mộ hay tiến cử. ★ Lưu tâm: người bạn tự ghim (bấm \"★ Lưu tâm\" trong hồ sơ). Tin tức về một người chỉ đến tai bạn khi họ là môn khách, hoặc ở cùng thành với bạn. Quan chức xem ở tab Triều đình.", 13, UIKit.DIM))
	book_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bbox.add_child(book_tree)
	_tab(bbox, "Sổ nhân vật")
	ret_tree = _tree(["Tên", "Tuổi", "Việc", "Lương", "Túi riêng", "Thực lực", "Thái độ"], [165, 38, 175, 48, 64, 80, 105])
	_tab(ret_tree, "Môn khách")
	court_tabs = TabContainer.new()
	court_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tab(court_tabs, "Triều đình")
	news_txt = UIKit.rich()
	_tab(news_txt, "Tin tức")
	clan_tree = _tree(["Thế gia", "Nước", "Quê", "Gia thế", "Quan hệ", "Trong triều", "Môn khách"], [120, 85, 85, 80, 120, 80, 80])
	var cbox2: = UIKit.vbox(6)
	cbox2.add_child(UIKit.wrap_label("Các gia tộc khác cũng săn nhân tài, nuôi dạy rồi tiến cử, tranh ghế với bạn; có nhà còn dùng âm mưu. Bái phỏng để kết giao (quan hệ ≥ 50: liên minh, ≥ 70: có thể kết thông gia), hoặc dùng mưu với họ. Biết họ là hạng nhà nào phải bái phỏng hoặc cài nội gián.", 13, UIKit.DIM))
	clan_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cbox2.add_child(clan_tree)
	_tab(cbox2, "Thế gia")


	var right: = UIKit.vbox(8)
	right.custom_minimum_size.x = 470
	body.add_child(right)
	var dbox: = UIKit.vbox(6)
	dbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_txt = UIKit.rich()
	detail_txt.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dbox.add_child(detail_txt)
	var drow: = UIKit.hbox(6)
	drow.add_child(UIKit.spacer())
	detail_btn = UIKit.button("Chi tiết…", func() -> void : _open_detail(), "Hồ sơ đầy đủ, chia tab")
	drow.add_child(detail_btn)
	dbox.add_child(drow)
	var dp: = UIKit.panel(dbox)
	dp.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(dp)
	var abox: = UIKit.vbox(6)
	hint_txt = UIKit.rich(true)
	abox.add_child(hint_txt)
	msg_lbl = UIKit.wrap_label("", 14, UIKit.GOLD)
	abox.add_child(msg_lbl)
	eye_line = UIKit.hbox(8)
	eye_head = UIKit.label("Thẩm định", 13, UIKit.DIM)
	eye_head.custom_minimum_size.x = 76
	eye_head.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	eye_line.add_child(eye_head)
	eye_box = _flow()
	eye_line.add_child(eye_box)
	abox.add_child(eye_line)
	var act_line: = UIKit.hbox(8)
	var ah: = UIKit.label("Hành động", 13, UIKit.DIM)
	ah.custom_minimum_size.x = 76
	ah.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	act_line.add_child(ah)
	action_box = _flow()
	act_line.add_child(action_box)
	abox.add_child(act_line)
	right.add_child(UIKit.panel(abox))


func _flow() -> HFlowContainer:
	var f: = HFlowContainer.new()
	f.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	f.add_theme_constant_override("h_separation", 6)
	f.add_theme_constant_override("v_separation", 6)
	return f




const TOP_ICONS: = {
	"here": "dang_o", "ap": "ngay", "eye": "nhan_luc", "money": "ngan_luong", 
	"prestige": "danh_vong", "clan": "gia_toc", "mat": "nhan_luc", "war": "chien_su", 
}



func _sys_menu(anchor: Control) -> void :
	var pm: = PopupMenu.new()
	pm.add_theme_font_size_override("font_size", 16)
	pm.add_item("👑 Bảng Điều Khiển Admin", 99)
	pm.add_separator()
	pm.add_item("Lưu ván", 0)
	pm.add_item("Về menu chính (tự lưu)", 1)
	pm.add_item("Hướng dẫn", 3)
	pm.add_item("Âm lượng nhạc…", 4)
	pm.add_separator()
	pm.add_item("Dừng bot tự chơi" if main.bot != null and is_instance_valid(main.bot) else "Bot tự chơi (Space dừng, +/− tốc độ, Esc tắt)", 2)
	pm.id_pressed.connect(_sys_pick)
	pm.popup_hide.connect(pm.queue_free)
	add_child(pm)
	pm.popup(Rect2i(Vector2i(anchor.global_position + Vector2(0, anchor.size.y + 2)), Vector2i(0, 0)))


func _sys_pick(id: int) -> void :
	if id == 99:
		AdminPanel.open(self)
	elif id == 0:
		_save_now()
	elif id == 1:
		_to_start()
	elif id == 2:
		main.toggle_bot()
	elif id == 3:
		Guide.open(self)
	elif id == 4:
		var body: = UIKit.modal(self, "Âm lượng nhạc", 480)
		body.add_child(Music.volume_row())
		var r: = UIKit.hbox(8)
		r.add_child(UIKit.spacer())
		r.add_child(UIKit.button("Đóng", func() -> void : UIKit.close_modal(body)))
		body.add_child(r)


func _save_now() -> void :
	main.save_game(w)
	_msg("Đã lưu.")


func _to_start() -> void :
	main.save_game(w)
	main.show_menu()


func _cell(parent: Control, key: String, title: String, size: int = 18) -> Control:
	var v: = UIKit.vbox(0)
	v.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if title != "":
		var t: = UIKit.label(title, 14, UIKit.DIM)
		t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var ic: = UIKit.icon(TOP_ICONS.get(key, ""), UIKit.DIM, 17)
		if ic != null:
			var th: = UIKit.hbox(4)
			th.alignment = BoxContainer.ALIGNMENT_CENTER
			th.add_child(ic)
			th.add_child(t)
			v.add_child(th)
		else:
			v.add_child(t)
	var val: = RichTextLabel.new()
	val.bbcode_enabled = true
	val.fit_content = true
	val.scroll_active = false
	val.autowrap_mode = TextServer.AUTOWRAP_OFF
	val.add_theme_font_size_override("normal_font_size", size)
	val.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(val)
	parent.add_child(v)
	top_vals[key] = val
	return v


func _tree(titles: Array, widths: Array) -> Tree:
	var t: = Tree.new()
	t.columns = titles.size()
	t.column_titles_visible = true
	t.hide_root = true
	t.select_mode = Tree.SELECT_ROW
	for i in titles.size():
		t.set_column_title(i, titles[i])
		t.set_column_custom_minimum_width(i, widths[i])
		t.set_column_expand(i, i == 0)
		t.set_column_clip_content(i, true)
	t.item_selected.connect( func() -> void :
		var it: = t.get_selected()
		if it != null and it.get_metadata(0) != null:
			select(str(it.get_metadata(0)), false))
	return t


func _tab(c: Control, title: String) -> void :
	c.name = "Tab%d" % tabs.get_tab_count()
	tabs.add_child(c)
	tabs.set_tab_title(tabs.get_tab_count() - 1, title)




func refresh_all() -> void :
	_top()
	map_view.refresh()
	_city()
	_log()
	_here_tab()
	_book_tab()
	_ret_tab()
	_court()
	_news()
	_clans_tab()
	_detail()
	Music.update_world(w)


func _msg(t: String, ok: bool = true) -> void :
	msg_lbl.text = t
	msg_lbl.add_theme_color_override("font_color", UIKit.GOLD if ok else UIKit.RED)



func _do_pop(res: Dictionary, title: String = "Kết quả") -> void :
	_do(res)
	_msg("")
	_result_popup(title, str(res["msg"]), bool(res["ok"]))


func _result_popup(title: String, text: String, ok: bool) -> void :
	var body: = UIKit.modal(self, title, 600)
	var r: = UIKit.rich(true)
	r.text = UIKit.col(text, UIKit.TEXT if ok else UIKit.RED)
	body.add_child(r)
	var row: = UIKit.hbox(8)
	row.add_child(UIKit.spacer())
	row.add_child(UIKit.button("Đóng", func() -> void : UIKit.close_modal(body)))
	body.add_child(row)



func _meet_lead(id: String) -> void :
	var r: = PlayerOps.meet(w, id)
	if r["ok"] and r.get("missed", false):
		notice = str(r["msg"])
		sel = "notice"
	elif r["ok"]:
		sel = "npc:" + id
	_do(r)


func _do(res: Dictionary) -> void :
	w.play["last_income"] = PlayerOps.clan_cashflow(w)[0]
	if str(w.play["over"]) != "":
		main.show_end(w)
		return
	var reps: = PlayerOps.take_reports(w)
	refresh_all()
	for cr in Repute.take_results(w):
		_result_popup(str(cr["title"]), str(cr["t"]), bool(cr["ok"]))
	_msg("" if res.get("missed", false) else str(res["msg"]), bool(res["ok"]))
	if not reps.is_empty():
		main.save_game(w)
		var merged: = {"lines": [], "news": []}
		for rp in reps:
			(merged["lines"] as Array).append_array(rp["lines"])
			(merged["news"] as Array).append_array(rp["news"])
		show_report(merged)



func _confirm_once(key: String, title: String, text: String, ok_label: String, on_ok: Callable) -> void :
	if UIKit.pref(key, false):
		on_ok.call()
		return
	var body: = UIKit.modal(self, title, 560)
	var r: = UIKit.rich(true)
	r.text = text
	body.add_child(r)
	var cb: = CheckBox.new()
	cb.text = "Không hiện lại nữa"
	body.add_child(cb)
	var row: = UIKit.hbox(10)
	row.add_child(UIKit.spacer())
	row.add_child(UIKit.button("Thôi", func() -> void :
		if cb.button_pressed:
			UIKit.set_pref(key, true)
		UIKit.close_modal(body)))
	row.add_child(UIKit.button(ok_label, func() -> void :
		if cb.button_pressed:
			UIKit.set_pref(key, true)
		UIKit.close_modal(body)
		on_ok.call()))
	body.add_child(row)



func _d(key: String) -> String:
	return " (%d ngày)" % PlayerOps.act_days(w, key)


func select(s: String, refresh_lists: bool = true) -> void :
	sel = s
	msg_lbl.text = ""
	if refresh_lists:
		refresh_all()
	else:
		_detail()


func _top() -> void :
	var inc: = float(w.play["last_income"])
	var tier: = PlayerOps.eye_tier(w)
	var nxt: = "" if tier >= 4 else " · %d/%d" % [int(w.play["ngo_dao"]), int(PlayerOps.TIER_UNLOCK[tier + 1])]
	top_vals["date"].text = "%s\n%s" % [UIKit.col(World.date_cap(w.m), UIKit.GOLD), UIKit.col("[font_size=12]còn %d tháng[/font_size]" % (PlayerOps.end_m(w) - w.m), UIKit.DIM)]
	top_vals["here"].text = UIKit.col(w.city_name(PlayerOps.here(w)), UIKit.TEXT)
	top_vals["ap"].text = UIKit.col("%d/%d" % [PlayerOps.day(w) + 1, PlayerOps.MONTH_DAYS], UIKit.GOLD)
	top_vals["eye"].text = UIKit.col("%d/%d" % [int(w.play["eye"]), int(w.play["eye_max"])], UIKit.BLUE)
	top_vals["money"].text = "%s %s" % [UIKit.col(str(roundi(PlayerOps.money(w))), UIKit.GOLD), UIKit.col("[font_size=12]%+d/th[/font_size]" % roundi(inc), UIKit.GREEN if inc >= 0.0 else UIKit.RED)]
	top_vals["prestige"].text = UIKit.col(str(roundi(PlayerOps.prestige(w))), UIKit.PURPLE)
	top_vals["clan"].text = UIKit.col(PlayerOps.CLAN_TIER_NAMES[PlayerOps.clan_tier(w)], UIKit.TEXT)
	top_vals["mat"].text = "%s%s" % [UIKit.col(Defs.TIER_NAMES[tier], UIKit.BLUE), UIKit.col("[font_size=12]%s[/font_size]" % nxt, UIKit.DIM)]
	var pn: = w.player().nation_id
	var foes: Array = []
	for wr in War.wars_of(w, pn):
		foes.append(w.nation_name(str(wr["b"]) if str(wr["a"]) == pn else str(wr["a"])))
	war_cell.visible = not foes.is_empty()
	top_vals["war"].text = UIKit.col("⚔ " + ", ".join(foes), UIKit.RED)
	var nch: = PlayerOps.choices(w).size()
	choices_btn.visible = nch > 0
	choices_btn.text = "Việc chờ (%d)" % nch


func _city() -> void :
	var cid: = PlayerOps.here(w)
	var city: Dictionary = w.cities[cid]
	city_title.text = "%s · %s" % [w.city_name(cid), w.nation_name(w.city_nation(cid))]
	city_desc.text = str(city.get("desc", ""))
	var n_leads: = 0
	for l in w.play["leads"]:
		if str(l["city"]) == cid:
			n_leads += 1
	for k in city_cells:
		var v: = float(city[k])
		(city_cells[k] as Label).text = str(roundi(v))
		(city_cells[k] as Label).add_theme_color_override("font_color", UIKit.grade_color(v))
	var st: = ""
	for f in city.get("features", []):
		var fd: Dictionary = Defs.FEATURES.get(f, {})
		st += "%s: %s\n" % [UIKit.col(str(fd.get("name", f)), UIKit.GOLD), UIKit.col(str(fd.get("desc", "")), UIKit.DIM)]
	if PlayerOps.house_cap(w, cid) > 0:
		st += "%s %d / %d người\n" % [UIKit.col("Tư trạch của bạn:", UIKit.GOLD), PlayerOps.house_count(w, cid), PlayerOps.house_cap(w, cid)]
	if n_leads > 0:
		st += UIKit.col("Đang có %d manh mối ở đây (tab Tại đây)." % n_leads, UIKit.DIM)
	city_stats.text = st.strip_edges()
	city_stats.visible = st != ""
	for ch in city_btns.get_children():
		ch.queue_free()

	var earn: Array = [
		{"t": "Buôn chuyến" + _d("trade"), "cb": func() -> void : _do_pop(PlayerOps.trade_run(w), "Buôn chuyến"), "ok": PlayerOps.money(w) >= PlayerOps.TRADE_STAKE, 
			"tip": ("Bỏ %d lượng vốn, 3 tháng sau thu về ~%d (theo Thương nghiệp của bạn và Kinh tế của thành)." if PlayerOps.money(w) >= PlayerOps.TRADE_STAKE else "Cần %d lượng vốn (thu về ~%d).") % [PlayerOps.TRADE_STAKE, roundi(PlayerOps.trade_expect(w))]}, 
		{"t": "Làm thuê" + _d("odd_job"), "cb": func() -> void : _do_pop(Daily.odd_job(w), "Làm thuê"), "ok": true, 
			"tip": "Theo sở trường (%s): ~%d lượng.%s" % [Daily.job_of(w)[0][1], Daily.job_pay(w), " Gia thế cao mà đi làm thuê thì mất 2 Danh vọng." if PlayerOps.clan_tier(w) >= 2 else ""]}, 
	]
	_city_menu_btn("Kiếm sống…", "Cách kiếm tiền khi túi rỗng", earn)

	var court: Array = []
	var cap: = not PlayerOps.capital_nations(w).is_empty()
	court.append({"t": "Kết giao" + _d("befriend"), "cb": func() -> void : _do_pop(PlayerOps.befriend(w), "Kết giao"), "ok": cap and PlayerOps.money(w) >= PlayerOps.BEFRIEND_COST, 
		"tip": "Mở tiệc kết giao quan lại (%d lượng): Ảnh hưởng tăng, tiến cử dễ hơn." % PlayerOps.BEFRIEND_COST if cap else "Phải ở kinh đô: %s." % PlayerOps.capitals_text(w)})
	var ccb: = Daily.court_chat_block(w)
	court.append({"t": "Hầu chuyện quan lại" + _d("court_chat"), "cb": func() -> void : _do_pop(Daily.court_chat(w), "Hầu chuyện quan lại"), "ok": ccb == "", 
		"tip": ccb if ccb != "" else "Kết giao không tốn tiền: Ảnh hưởng +1, tối đa %d lần mỗi tháng." % Daily.COURT_CHAT_MAX})
	var has_off: = not PlayerOps.office_options(w).is_empty()
	court.append({"t": "Xin chức…", "cb": _office_modal, "ok": has_off, "tip": "Tự mình ra làm quan ở đây (Chính trị, Danh vọng, Ảnh hưởng)." if has_off else "Ở đây không có chức nào bạn xin được."})
	if not War.wars_of(w, w.player().nation_id).is_empty():
		var cb: = PlayerOps.campaign_block(w)
		court.append({"t": "Theo quân" + _d("join_war"), "ok": cb == "", "cb": func() -> void :
			var r: = PlayerOps.join_war(w)
			if str(w.play["over"]) != "":
				main.show_end(w)
				return
			_do_pop(r, "Theo quân"), "tip": cb if cb != "" else "Ra tiền tuyến bày mưu: chiến cục +%.1f (theo Quân sự và tư binh). Có rủi ro bị thương." % PlayerOps.campaign_push(w)})
	_city_menu_btn("Quan trường…", "Kết giao, hầu chuyện quan lại, xin chức, theo quân", court)

	var deeds: Array = []
	for k in Daily.DEEDS:
		var kind: String = k
		var dd: Dictionary = Daily.DEEDS[k]
		var db: = Daily.deed_block(w, kind)
		deeds.append({"t": str(dd["name"]) + _d("deed"), "cb": func() -> void : _do_pop(Daily.good_deed(w, kind), str(dd["name"])), "ok": db == "", 
			"tip": db if db != "" else "%s Thành ~%d%%." % [dd["desc"], roundi(Daily.deed_chance(w, kind) * 100.0)]})
	_city_menu_btn("Việc nghĩa…", "Giúp dân trong thành: Danh vọng, an ninh", deeds)
	if Exam.active(w):
		var es: = Exam.season(w)
		var nc: = Exam.candidates_here(w).size()
		var eb: = UIKit.button("%s… (%d)" % [Exam.KINDS[str(es["kind"])]["name"], nc], _exam_modal, Exam.stage_label(w) + ". Số trong ngoặc: sĩ tử đang ở thành này.")
		eb.add_theme_color_override("font_color", UIKit.GOLD)
		city_btns.add_child(eb)
	var hcid: = PlayerOps.here(w)
	var hcap: = PlayerOps.house_cap(w, hcid)
	if hcap == 0:
		var hp: = PlayerOps.house_price(w, hcid)
		var bh: = UIKit.button("Mua tư trạch · %d (%d ngày)" % [hp, PlayerOps.HOUSE_DAYS], func() -> void : _do(PlayerOps.buy_house(w)), 
			"Nhà cho %d môn khách ở và làm việc tại %s; phí giữ nhà %d lượng/tháng." % [PlayerOps.HOUSE_CAP, w.city_name(hcid), int(PlayerOps.HOUSE_UPKEEP)])
		bh.disabled = PlayerOps.money(w) < float(hp)
		city_btns.add_child(bh)
	elif hcap < PlayerOps.HOUSE_CAP_BIG:
		var ep: = roundi(PlayerOps.house_price(w, hcid) / 2.0)
		var be: = UIKit.button("Mở rộng tư trạch · %d" % ep, func() -> void : _do(PlayerOps.expand_house(w)), 
			"Ở được %d người thay vì %d" % [PlayerOps.HOUSE_CAP_BIG, hcap])
		be.disabled = PlayerOps.money(w) < float(ep)
		city_btns.add_child(be)


func _exam_modal() -> void :
	var s: = Exam.season(w)
	if s.is_empty():
		return
	var kd: Dictionary = Exam.KINDS[str(s["kind"])]
	var body: = UIKit.modal(self, "%s năm %d · %s" % [kd["name"], w.year(), w.city_name(PlayerOps.here(w))], 980)
	var mo: = w.month()
	var steps: = [[1, "Tháng 1 · Yết bảng"], [2, "Tháng 2 · Thi Hương ở kinh đô và các thành lớn (%s)" % Exam._city_list(w, s)], [3, "Tháng 3 · sĩ tử tụ ở kinh thành; Thi Hội ngày 15, Thi Đình ngày 25 (ứng đối, tính cả Mị lực)"]]
	var sch: = ""
	for st in steps:
		sch += UIKit.col(("▶ " if int(st[0]) == mo else "   ") + str(st[1]), UIKit.GOLD if int(st[0]) == mo else UIKit.DIM) + "\n"
	sch += UIKit.col("Chấm theo tài thật (%s), không theo Ấn tượng: kẻ hư danh dễ trượt và lộ; người đã gặp có bảng điểm công bố, khoảng Ấn tượng hai môn thi hẹp lại. Người trượt về quê." % " + ".join((kd["s"] as Array).map( func(i: int) -> String: return Defs.STAT_NAMES[i])), UIKit.DIM)
	var r: = UIKit.rich(true)
	r.text = sch
	body.add_child(r)

	var pst: Dictionary = s["p"]
	var nx: = Exam.player_next(w)
	var prow: = UIKit.hbox(10)
	var pl: = UIKit.rich(true)
	pl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pl.text = UIKit.col("Bạn: ", UIKit.GOLD) + Exam.STAGE_NAMES[int(pst["st"])] + ("" if str(nx[1]) == "" else UIKit.col(" · " + str(nx[1]), UIKit.DIM))
	prow.add_child(pl)
	if int(nx[0]) > 0:
		var stg: = int(nx[0])
		var eb2: = UIKit.button("Vào %s (%d ngày)" % [Exam.STAGE_NAME[stg], Exam.STAGE_DAYS[stg]], func() -> void :
			UIKit.close_modal(body)
			_do_pop(Exam.enter(w), Exam.STAGE_NAME[stg]), "Đỗ Thi Đình: danh tiếng, Danh vọng, Ảnh hưởng; 3 năm tới Xin chức được cộng điểm")
		eb2.disabled = str(nx[1]) != ""
		prow.add_child(eb2)
	body.add_child(UIKit.panel(prow, UIKit.PANEL2, 8))
	var rets: Array = PlayerOps.retainers(w).filter( func(x: Character) -> bool: return PlayerOps.exam_flag(w, x.id))
	if not rets.is_empty():
		body.add_child(UIKit.wrap_label("Môn khách dự thi: " + ", ".join(rets.map( func(x: Character) -> String: return "%s (%s)" % [x.name, PlayerOps.loc_text(w, x)])) + ". Tháng 2 phải ở thành thi Hương, tháng 3 ở kinh thành.", 13, UIKit.DIM))

	var cands: = Exam.candidates_here(w)
	body.add_child(UIKit.label("Sĩ tử đang ở %s (%d)" % [w.city_name(PlayerOps.here(w)), cands.size()], 16, UIKit.GOLD))
	var scroll: = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(940, 360)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var list: = UIKit.vbox(4)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	if cands.is_empty():
		list.add_child(UIKit.wrap_label("Chưa có sĩ tử nào ở đây. Tháng 2 tới các thành thi Hương, tháng 3 tới kinh thành.", 14, UIKit.DIM))
	cands.sort_custom( func(a: Array, b: Array) -> bool: return int(a[1]["st"]) > int(b[1]["st"]))
	for pair in cands:
		var c: Character = pair[0]
		var e: Dictionary = pair[1]
		var row: = UIKit.hbox(10)
		var tx: = UIKit.rich(true)
		tx.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var imp: = PlayerOps.impression(w, c)
		var ss: Array = kd["s"]
		tx.text = "%s  %s\n%s" % [_tip(UIKit.col("[u]%s[/u]" % c.name, UIKit.TEXT), _person_tip(c)), UIKit.col("(%d tuổi, quê %s) · %s" % [c.age(w.m), w.city_name(str(e["home"])), Exam.STAGE_NAMES[int(e["st"])]], UIKit.DIM), 
			UIKit.col("Ấn tượng: %s %s · %s %s" % [Defs.STAT_NAMES[int(ss[0])], _plain_range(imp["real"][int(ss[0])]), Defs.STAT_NAMES[int(ss[1])], _plain_range(imp["real"][int(ss[1])])], UIKit.DIM) + (UIKit.col("  · đã gặp", UIKit.GREEN) if w.notebook.has(c.id) else "")]
		row.add_child(tx)
		var cid: = c.id
		if PlayerOps.met_now(w, c):
			row.add_child(UIKit.button("Hồ sơ", func() -> void :
				UIKit.close_modal(body)
				select("npc:" + cid)))
		else:
			row.add_child(UIKit.button("Gặp" + _d("meet"), func() -> void :
				UIKit.close_modal(body)
				var res: = PlayerOps.meet(w, cid)
				if res["ok"]:
					sel = "npc:" + cid
				_do(res)
				_exam_modal()))
		list.add_child(UIKit.panel(row, UIKit.PANEL, 6))


func _city_menu_btn(text: String, tip: String, items: Array) -> void :
	var n: = items.filter( func(x: Dictionary) -> bool: return bool(x["ok"])).size()
	var b: = UIKit.button("%s (%d)" % [text, n], func() -> void : _menu(text.replace("…", "") + " ở " + w.city_name(PlayerOps.here(w)), items), tip)
	b.disabled = n == 0
	city_btns.add_child(b)


func _log() -> void :
	var lg: Array = w.play["log"]
	if lg.is_empty():
		log_txt.text = UIKit.col("Chưa có gì. Hãy Dò la để tìm người đáng chú ý.", UIKit.DIM)
		return
	var s: = "[table=2]"
	for k in range(lg.size() - 1, maxi(-1, lg.size() - 40), -1):
		var e: Dictionary = lg[k]
		var cur: = int(e["m"]) == w.m
		s += "[cell]%s  [/cell][cell]%s[/cell]" % [UIKit.col("T%d/%d" % [int(e["m"]) % 12 + 1, floori(int(e["m"]) / 12.0) + 1], UIKit.DIM), UIKit.col(str(e["t"]), UIKit.TEXT if cur else UIKit.DIM)]
	log_txt.text = s + "[/table]"




const PROF_DESC: = {
	"nong_dan": "Cày cấy quanh năm; quen việc đồng áng, chịu khó.", 
	"ngu_dan": "Sống nhờ sông biển; quen sóng gió, biết thời tiết.", 
	"tho_thu_cong": "Làm đồ dùng, đồ gốm, đồ gỗ; khéo tay.", 
	"tho_ren": "Rèn nông cụ, binh khí; khỏe tay, hiểu sắt thép.", 
	"tieu_thuong": "Buôn bán nhỏ ở chợ; nhanh nhạy giá cả.", 
	"thuong_nhan": "Buôn chuyến xa, quen giới buôn các thành.", 
	"binh_si": "Lính trong quân; thao luyện võ nghệ, trận pháp.", 
	"vo_sinh": "Theo học võ đường; ngày ngày luyện quyền cước.", 
	"kiem_khach": "Đi lại giang hồ bằng thanh kiếm; võ nghệ tự rèn.", 
	"thu_sinh": "Đèn sách chờ khoa cử; đọc kinh sử, bàn việc nước.", 
	"lai_vien": "Làm việc giấy tờ ở nha môn; hiểu luật lệ, thủ tục.", 
	"thay_thuoc": "Bốc thuốc chữa bệnh; đọc nhiều sách y.", 
	"phu_khuan_vac": "Làm thuê kiếm sống qua ngày; không có nghề để rèn.", 
	"nghe_nhan": "Đàn hát, diễn tuồng nơi tửu lâu, phủ đệ; sống bằng sức hút với người xem.", 
	"bien_si": "Đi lại các nhà quyền quý bàn chuyện thiên hạ; ăn nói là vốn liếng.", 
	"dan_thuong": "Không có nghề cố định.", 
	"quy_toc": "Con nhà thế gia; được thầy giỏi dạy dỗ từ nhỏ.", 
	"quan_lai": "Quan văn trong triều; ngày ngày lo việc chính sự.", 
	"vo_quan": "Quan võ cầm quân; rèn binh, giữ thành.", 
	"tan_khoa": "Vừa đỗ khoa thi văn, chờ bổ nhiệm.", 
	"vo_cu_nhan": "Vừa đỗ khoa thi võ, chờ bổ nhiệm.", 
	"cuu_quan": "Từng làm quan, nay đã rời chức.", 
	"lao_than": "Quan già đã về hưu; vẫn còn tiếng nói.", 
	"muu_si": "Kẻ sĩ bày mưu tính kế cho người khác.", 
	"vo_su": "Thầy dạy võ; truyền nghề cho lớp sau.", 
	"thay_day": "Thầy đồ dạy chữ trong làng.", 
	"an_si": "Ẩn cư lánh đời; đọc sách, ngẫm việc thiên hạ.", 
}



func _prof_info(pid: String) -> String:
	var pd: Dictionary = Defs.PROFESSIONS.get(pid, Defs.PROFESSIONS["dan_thuong"])
	var fs: Array = (pd["focus"] as Array).map( func(i: int) -> String: return Defs.STAT_NAMES[int(i)])
	var t: = "%s. Hướng tu dưỡng: %s" % [str(PROF_DESC.get(pid, "")).trim_suffix("."), ", ".join(fs) if not fs.is_empty() else "không có (mọi chỉ số đều lớn chậm)"]
	t += " (chỉ số ngoài hướng chỉ lớn ×0,2)."
	if str(pd["env"]) != "":
		t += " Môi trường: %s, chỉ số hợp lớn ×%s." % [Defs.ENVS[str(pd["env"])]["name"], str(Defs.ENVS[str(pd["env"])]["mult"]).replace(".", ",")]
	if PlayerOps.MI_ENVS.has(str(pd["env"])):
		t += " Mị lực lớn ×%s." % str(PlayerOps.MI_ENVS[str(pd["env"])]).replace(".", ",")
	return t


func _prof_bb(pid: String, c: Character = null) -> String:
	var tip: = ("Nghề %s: " % Defs.prof_name(pid)) + _prof_info(pid)
	var shown: = Defs.prof_name(pid)
	if c != null and c.profession == pid:
		shown = ProfTree.title(c)
		tip += " " + _prof_rank_text(c)
	return _tip("[u]%s[/u]" % shown, tip)



func _prof_rank_text(c: Character) -> String:
	if not ProfTree.has_tree(c.profession):
		return "Nghề này không có bậc."
	var t: = "Bậc %d/4 · làm nghề %s." % [ProfTree.rank(c), ("%d năm" % (maxi(0, c.prof_months) / 12)) if c.prof_months >= 12 else "chưa tới 1 năm"]
	var ps: Array = ProfTree.path_stats(c)
	if not ps.is_empty():
		t += " Sở trường nghề: %s (thêm vào hướng tu dưỡng; chỉ số nghề lớn ×%s)." % [", ".join(ps.map( func(s: int) -> String: return ProfTree.stat_name(s))), str(ProfTree.RANK_MULT[ProfTree.rank(c) - 1]).replace(".", ",")]
	var nx: Array = ProfTree.next_options(c)
	if not nx.is_empty():
		t += " Khoảng %d tháng nữa lên bậc %d: %s." % [ProfTree.months_to_next(c), ProfTree.rank(c) + 1, " / ".join(nx.map( func(n: Dictionary) -> String: return "%s (%s)" % [n["name"], ProfTree.stat_name(int(n["stat"]))]))]
	if c.prof_hint != "":
		t += " Đã được khuyên hướng tới %s." % ProfTree.node(c.profession, c.prof_hint).get("name", "?")
	if not c.prof_on:
		t += " Đang làm việc khác nghề nên thâm niên tạm dừng."
	return t


func _role_public(c: Character) -> String:
	if not c.alive:
		return "Đã mất"
	if PlayerOps.is_retainer(w, c):
		return "Môn khách · " + ProfTree.title(c)
	var s: = ""
	if c.office_key != "":
		s = "%s · %s" % [Appointment.office_label_of(w, c), w.nation_name(c.nation_id)]
	else:
		s = ProfTree.title(c)
		if c.nation_id != "":
			s += " · " + w.nation_name(c.nation_id)
	if c.recommender == w.player_id:
		s = "◆ " + s
	return s


func _best_pot_text(c: Character) -> Array:
	var n: Dictionary = w.notebook.get(c.id, {})
	if not n.has("appr"):
		return ["—", -1.0]
	var rec: Dictionary = n["appr"]
	var best: = -1
	var hi: = -1.0
	for i in Defs.N_STATS:
		var pb: Array = rec["pot"][i]
		if not pb.is_empty() and float(pb[1]) > hi:
			hi = float(pb[1])
			best = i
	if best < 0:
		return ["(chưa thấy tiềm năng)", -1.0]
	var pb2: Array = rec["pot"][best]
	var txt: = "%s %s" % [Defs.STAT_SHORT[best], str(pb2[0]) if int(pb2[0]) == int(pb2[1]) else "%d–%d" % [int(pb2[0]), int(pb2[1])]]
	return [txt, (float(pb2[0]) + float(pb2[1])) / 2.0]


func _appr_age_text(c: Character) -> String:
	var n: Dictionary = w.notebook.get(c.id, {})
	if not n.has("appr"):
		return "chưa"
	var rec: Dictionary = n["appr"]
	var ago: = w.m - int(rec["m"])
	return "%s, %s" % [Defs.TIER_NAMES[int(rec["tier"])], "tháng này" if ago == 0 else "%d th trước" % ago]





func _talent_bb(id: String, color: Color = UIKit.GOLD) -> String:
	var d: = GameData.talent(id)
	var tip: = "%s [%s]: %s" % [d["name"], Defs.RARITY_NAMES[int(d.get("rarity", 0))], d.get("desc", "")]
	return _tip(UIKit.col("[u]%s[/u]" % d["name"], color), tip)


const NGO_DESC: = ["", "chậm hiểu, học gì cũng lâu", "như phần đông thiên hạ", "sáng dạ, học nhanh hơn người thường", 
	"rất nhanh hiểu, rèn đâu chắc đó", "kỳ tài hiếm có, một ngày bằng người khác mấy tháng"]



func _ngo_bb(n: int) -> String:
	var tip: = "Ngộ tính %s: %s. Tốc độ trưởng thành chỉ số ×%s (Thông tuệ = ×1). Khoảng %d%% người có ngộ tính này." % [
		Defs.NGO_NAMES[n], NGO_DESC[n], str(Defs.NGO_MULT[n]).replace(".", ","), int(Defs.NGO_WEIGHTS[n])]
	return _tip("[u]%s[/u]" % Defs.NGO_NAMES[n], tip)



func _npc_head(c: Character, extra: String = "") -> String:
	var met: = PlayerOps.met_now(w, c)
	var ret: = PlayerOps.is_retainer(w, c)
	var age: = c.age(w.m) if c.alive else c.age(c.death_m)
	var s: = "[font_size=22]%s[/font_size]  %s\n" % [UIKit.col(("★ " if PlayerOps.is_starred(w, c.id) else "") + c.name, UIKit.GOLD), UIKit.col("(%s, %d tuổi)" % ["Nữ" if c.female else "Nam", age], UIKit.DIM)]
	var role: = _role_public(c)
	if c.alive and c.office_key == "":
		role = role.replace(ProfTree.title(c), _prof_bb(c.profession, c))
	s += "%s · %s · Danh tiếng %d\n" % [role, w.city_name(c.city_id), roundi(c.fame)]
	if not c.alive:
		s += UIKit.col("Đã qua đời %s (%s).\n" % [World.date_of(c.death_m), c.death_cause], UIKit.RED)
	elif ret:
		s += UIKit.col("%s · lương %d · túi riêng %d\n" % [PlayerOps.loc_text(w, c), int(w.play["salary"].get(c.id, 0)), roundi(c.purse)], UIKit.GREEN)
		s += UIKit.col("Đang: %s\n" % _task_text(c), UIKit.DIM)
	elif met:
		s += UIKit.col("Vừa gặp: thẩm định, chiêu mộ, tiến cử được.\n", UIKit.GREEN)
	elif c.city_id == PlayerOps.here(w):
		s += UIKit.col("Ở cùng thành: gặp mặt để thẩm định.\n", UIKit.DIM)
	if c.alive and c.office_key == "" and Appointment.shamed(w, c):
		s += UIKit.col("Mang tiếng tới %s: triều đình chưa dùng lại.\n" % World.date_of(c.shame_until), UIKit.RED)
	elif c.alive and c.office_key == "" and c.nation_id != "" and c.idle_until >= 0 and not PlayerOps.is_retainer(w, c):
		s += UIKit.col("Cựu quan chờ bổ dụng tới %s (chiêu mộ được).\n" % World.date_of(c.idle_until), UIKit.DIM)
	if c.hates_player:
		s += UIKit.col("Biết bạn đứng sau việc hãm hại mình.\n", UIKit.RED)
	var rvc: = Rivals.of(w, c)
	if not rvc.is_empty():
		s += UIKit.col(("Gia chủ %s" if c.special == "gia_chu" else "Người của %s") % rvc["name"], UIKit.PURPLE) + "\n"
	return _with_portrait(c, s + extra)



func _npc_warnings(c: Character) -> String:
	if not c.alive:
		return ""
	var ret: = PlayerOps.is_retainer(w, c)
	var s: = ""
	if not c.crisis.is_empty() and (ret or PlayerOps.met_now(w, c)):
		s += UIKit.col("⚠ Đang suy sụp sau biến cố: nên Khuyên nhủ.\n", UIKit.RED)
	if ret:
		var ps: = PlayerOps.task_pause(w, c)
		if ps != "":
			s += UIKit.col("⚠ Việc đang tạm ngưng: %s.\n" % ps, UIKit.RED)
		var sps: = PlayerOps.study_pause(w, c)
		if sps != "" and not (sps.begins_with("đang theo hầu") and PlayerOps.job_on(w, c)):
			s += UIKit.col("⚠ Việc học đang ngưng: %s.\n" % sps, UIKit.RED)
		if c.loyalty < 40.0:
			s += UIKit.col("⚠ Trung thành thấp (%s): dễ bị lôi kéo.\n" % PlayerOps.loyalty_word(c), UIKit.RED)
	var sn: = Appointment.snub_chance(w, c)
	if sn > 0.0 and not c.is_player:
		s += UIKit.col("⚠ Dung mạo kém: ~%d%% bị triều đình chê.\n" % roundi(sn * 100.0), UIKit.RED)
	return s



func _npc_stats_short(c: Character) -> String:
	var rec: Dictionary = w.notebook.get(c.id, {}).get("appr", {})
	var imp: = PlayerOps.impression(w, c)
	var rows: Array = []
	var heads: = ["Chỉ số", "Ấn tượng", "Thực", "Tiềm năng"] if not rec.is_empty() else ["Chỉ số", "Ấn tượng"]
	for i in Defs.N_STATS:
		var row: Array = [Defs.STAT_NAMES[i], UIKit.range_text(imp["real"][i])]
		if not rec.is_empty():
			row += [UIKit.range_text(rec["real"][i]), UIKit.range_text(rec["pot"][i])]
		rows.append(row)
	var mrow: Array = ["Mị lực", UIKit.range_text(imp.get("mi_real", []))]
	if not rec.is_empty():
		mrow += [UIKit.range_text(rec.get("mi_real", [])), UIKit.range_text(rec.get("mi_pot", []))]
	rows.append(mrow)
	var s: = _stat_table(rows, heads) + "\n"
	var hints: Array = w.notebook.get(c.id, {}).get("hints", [])
	if not hints.is_empty():
		s += UIKit.col("Nghe nói: ", UIKit.DIM) + UIKit.col("; ".join(hints), UIKit.BLUE) + "\n"
	if rec.is_empty():
		var nobs: = (w.notebook.get(c.id, {}).get("obs", {}) as Dictionary).size()
		s += UIKit.col("Chưa thẩm định: Ấn tượng là điều thiên hạ thấy%s." % ((" (đã quan sát kỹ %d mặt)" % nobs) if nobs > 0 else ""), UIKit.DIM) + "\n"
		return s
	var ago: = w.m - int(rec["m"])
	s += UIKit.col("Thẩm định %s, %s" % [Defs.TIER_NAMES[int(rec["tier"])], "tháng này" if ago == 0 else "%d tháng trước" % ago], UIKit.DIM) + "\n"
	if rec.has("ngo"):
		s += UIKit.col("Ngộ tính: ", UIKit.DIM) + _ngo_bb(int(rec["ngo"])) + "\n"
	if rec.has("talents"):
		var tl: Array = rec["talents"]
		s += UIKit.col("Thiên phú: ", UIKit.DIM) + (", ".join(tl.map( func(x: String) -> String: return _talent_bb(x))) if not tl.is_empty() else UIKit.col("không thấy", UIKit.DIM)) + "\n"
	if bool(rec.get("anomaly", false)):
		s += UIKit.col("⚠ Bất thường: người này đang che giấu điều gì đó.", UIKit.RED) + "\n"
	return s


func _npc_summary(c: Character) -> String:
	var cond: = _conditions(c) if c.alive and not c.is_player and not PlayerOps.is_retainer(w, c) else ""
	var s: = _npc_head(c, cond) + _npc_warnings(c)
	s += _npc_stats_short(c)
	return s



func _npc_page_overview(c: Character) -> String:
	var n: Dictionary = w.notebook.get(c.id, {})
	var ret: = PlayerOps.is_retainer(w, c)
	var s: = _npc_head(c) + _npc_warnings(c)
	if c.alive and not ret and not c.is_player:
		s += "\n" + _conditions(c)
	s += "\n" + UIKit.col("Nghề nghiệp", UIKit.GOLD) + "\n"
	s += "%s%s: %s\n" % [_prof_bb(c.profession, c), UIKit.col(" (nghề %s)" % Defs.prof_name(c.profession).to_lower(), UIKit.DIM) if ProfTree.title(c) != Defs.prof_name(c.profession) else "", UIKit.col(_prof_info(c.profession), UIKit.DIM)]
	s += UIKit.col(_prof_rank_text(c), UIKit.DIM) + "\n"
	if ret:
		s += UIKit.col("Là môn khách: hướng tu dưỡng theo việc bạn giao (%s).\n" % ", ".join(c.focus.map( func(i: int) -> String: return Defs.STAT_NAMES[int(i)])), UIKit.DIM)
	if not c.career_try.is_empty():
		s += UIKit.col("Đang thử nghề mới theo lời bạn khuyên (bỏ nghề %s từ %s); khoảng %s sẽ biết có trụ được không.\n" % [Defs.prof_name(str(c.career_try["from"])).to_lower(), World.date_of(int(c.career_try["m"])), World.date_of(int(c.career_try["check"]))], UIKit.BLUE)
	s += "\n" + UIKit.col("Quan hệ với bạn", UIKit.GOLD) + "\n"
	if ret:
		s += "Trung thành %s · lương %d/tháng · %s\n" % [PlayerOps.loyalty_word(c), int(w.play["salary"].get(c.id, 0)), PlayerOps.loc_text(w, c)]
		s += "Túi riêng %d lượng" % roundi(c.purse)
		if not c.purse_last.is_empty():
			s += UIKit.col(" · tháng trước +%d / −%d (%s)" % [int(c.purse_last["in"]), int(c.purse_last["out"]), ", ".join(c.purse_last["notes"])], UIKit.DIM)
		s += "\n"
		var dbt: = Purse.debt_of(w, c.id)
		if not dbt.is_empty():
			s += UIKit.col("Bạn đang nợ %d lượng, hẹn trả trước %s.\n" % [int(dbt["amt"]), World.date_of(int(dbt["due"]))], UIKit.RED if int(dbt["due"]) <= w.m else UIKit.GOLD)
	s += "Ân tình %d%s\n" % [roundi(c.favor), " · đã thăm hỏi %d lần" % PlayerOps.visits(w, c.id) if PlayerOps.visits(w, c.id) > 0 else ""]
	if n.has("first_m"):
		s += UIKit.col("Biết tới từ %s%s.\n" % [World.date_of(int(n["first_m"])), (" ở " + w.city_name(str(n["first_city"]))) if n.has("first_city") else ""], UIKit.DIM)
	var rvc: = Rivals.of(w, c)
	if not rvc.is_empty():
		s += UIKit.col(("Gia chủ %s" if c.special == "gia_chu" else "Môn khách của %s") % rvc["name"] + " (%s với bạn)." % Rivals.stance(rvc), UIKit.PURPLE) + "\n"
	elif Rivals.backer(c) != "" and w.rivals.has(Rivals.backer(c)):
		s += UIKit.col("Do %s tiến cử." % w.rivals[Rivals.backer(c)]["name"], UIKit.PURPLE) + "\n"
	if c.recommender == w.player_id and c.office_key != "":
		s += UIKit.col("Do bạn tiến cử. Công lao tích lũy %.0f (thưởng mỗi cuối năm)." % c.merit_total, UIKit.GOLD) + "\n"
	var pred: Array = n.get("pred", [])
	if not pred.is_empty():
		s += UIKit.col("Bạn tin người này sẽ thành tài về: %s." % ", ".join(pred.map( func(i: int) -> String: return Defs.STAT_NAMES[int(i)])), UIKit.GOLD) + "\n"
	var gt: = Items.gear_text(c)
	if gt != "":
		s += "Trang bị: %s\n" % gt
	for inj in c.injuries:
		if int(inj["months"]) < 0:
			s += UIKit.col("Thương tật: %s\n" % inj["name"], UIKit.RED)
	var intel: Dictionary = w.play.get("intel", {}).get(c.id, {})
	if not intel.is_empty():
		s += "\n" + UIKit.col("Tin thám báo (tình hình %s, %s):" % [World.date_of(int(intel["m"])), "mức " + str(PlayerOps.PROBE_TIERS[int(intel["tier"])]["name"]).to_lower()], UIKit.BLUE) + " " + PlayerOps.intel_text(w, intel) + "\n"
		for e in intel["events"]:
			s += UIKit.col("   %s: %s\n" % [World.date_of(int(e["m"])), e["t"]], UIKit.DIM)
	for pr in w.play.get("probes", []):
		if str(pr["id"]) == c.id:
			s += UIKit.col("Đã cử người dò tin, tin về khoảng %s.\n" % World.date_of(int(pr["due"])), UIKit.BLUE)
	return s



func _npc_page_stats(c: Character) -> String:
	var rec: Dictionary = w.notebook.get(c.id, {}).get("appr", {})
	var intel: Dictionary = w.play.get("intel", {}).get(c.id, {})
	var imp: = PlayerOps.impression(w, c)
	var heads: = ["Chỉ số", "Ấn tượng"]
	if not intel.is_empty():
		heads += ["Thám báo"]
	if not rec.is_empty():
		heads += ["Thực", "Tiềm năng"]
	var rows: Array = []
	for i in Defs.N_STATS:
		var row: Array = [Defs.STAT_NAMES[i], UIKit.range_text(imp["real"][i])]
		if not intel.is_empty():
			row += [UIKit.range_text(intel["real"][i])]
		if not rec.is_empty():
			row += [UIKit.range_text(rec["real"][i]), UIKit.range_text(rec["pot"][i])]
		rows.append(row)
	var mrow: Array = ["Mị lực", UIKit.range_text(imp.get("mi_real", []))]
	if not intel.is_empty():
		mrow += [UIKit.col("?", UIKit.DIM)]
	if not rec.is_empty():
		mrow += [UIKit.range_text(rec.get("mi_real", [])), UIKit.range_text(rec.get("mi_pot", []))]
	rows.append(mrow)
	var s: = _stat_table(rows, heads) + "\n"
	if not rec.is_empty():
		var ago: = w.m - int(rec["m"])
		s += UIKit.col("Thẩm định tầng %s, %s. Người ta thay đổi theo thời gian, thông tin cũ có thể đã sai.\n" % [Defs.TIER_NAMES[int(rec["tier"])], "tháng này" if ago == 0 else "%d tháng trước" % ago], UIKit.DIM)
		if bool(rec.get("anomaly", false)):
			s += UIKit.col("⚠ Bất thường: người này đang che giấu điều gì đó. Cần Đôi Mắt cao hơn.\n", UIKit.RED)
		if c.alive:
			s += _branch_text(c, rec)
	var sn: = Appointment.snub_chance(w, c)
	if sn > 0.0:
		s += UIKit.col("Dung mạo, ăn nói kém: triều đình có ~%d%% khả năng chê, không dùng (như Bàng Thống).\n" % roundi(sn * 100.0), UIKit.RED)
	s += _stat_explain(heads)
	return s



func _npc_page_traits(c: Character) -> String:
	var rec: Dictionary = w.notebook.get(c.id, {}).get("appr", {})
	if rec.is_empty():
		return UIKit.col("Chưa thẩm định. Thẩm định tầng Trung cấp để thấy ngộ tính và thiên phú, Cao cấp để thấy tính cách và chí hướng.", UIKit.DIM)
	var s: = ""
	if rec.has("ngo"):
		s += "%s %s\n\n" % [UIKit.col("Ngộ tính", UIKit.GOLD), _ngo_bb(int(rec["ngo"]))]
	if rec.has("talents"):
		s += UIKit.col("Thiên phú", UIKit.GOLD) + "\n"
		var tl: Array = rec["talents"]
		if tl.is_empty():
			s += UIKit.col("  Không thấy thiên phú nào (tầng cao hơn có thể thấy thiên phú hiếm).", UIKit.DIM) + "\n"
		for t in tl:
			var d: = GameData.talent(str(t))
			s += "  %s %s\n  %s\n" % [_talent_bb(str(t)), UIKit.col("[%s]" % Defs.RARITY_NAMES[int(d["rarity"])], UIKit.DIM), UIKit.col(str(d.get("desc", "")), UIKit.DIM)]
		s += "\n"
	else:
		s += UIKit.col("Thẩm định tầng Trung cấp để thấy ngộ tính và thiên phú.", UIKit.DIM) + "\n\n"
	if rec.has("traits"):
		s += UIKit.col("Tính cách", UIKit.GOLD) + "  " + ", ".join((rec["traits"] as Array).map( func(x: String) -> String: return GameData.trait_name(x))) + "\n"
		s += "Trung thành %d · Ý chí %d · Tham vọng %d\n\n" % [int(rec["loyalty"]), int(rec["y_chi"]), int(rec["tham_vong"])]
	else:
		s += UIKit.col("Thẩm định tầng Cao cấp để thấy tính cách, trung thành, ý chí, tham vọng.", UIKit.DIM) + "\n\n"
	if rec.has("crisis"):
		s += UIKit.col("Lúc thẩm định đang khủng hoảng. Khả năng các hướng:", UIKit.RED) + "\n"
		for k in Crisis.PATHS:
			s += "   %s %d%%\n" % [Crisis.PATH_NAMES[k], roundi(float(rec["crisis"][k]) * 100.0)]
	if rec.has("fate"):
		var fh: Array = rec["fate"]
		s += UIKit.col("Thiên cơ 2 năm tới: ", UIKit.PURPLE) + ("bình lặng" if fh.is_empty() else ", ".join(fh.map( func(x: Dictionary) -> String: return "%s sau %d tháng" % [x["kind"], int(x["in"])]))) + "\n"
	return s



func _npc_page_history(c: Character) -> String:
	var close: = PlayerOps.is_retainer(w, c) or c.recommender == w.player_id
	var lines: Array = []
	for k in range(c.history.size() - 1, -1, -1):
		var e: Dictionary = c.history[k]
		var t: = str(e["t"]).replace("[Định mệnh] ", "")
		var show: = close
		if not show:
			for pre in PlayerOps.PUBLIC_EVENT_PREFIX:
				if t.begins_with(pre):
					show = true
					break
		if show:
			lines.append("%s  %s" % [UIKit.col(World.date_of(int(e["m"])), UIKit.DIM), t])
		if lines.size() >= 40:
			break
	var s: = UIKit.col("Những gì bạn biết về đời %s%s" % [c.name, "" if close else " (chỉ chuyện thiên hạ đều biết)"], UIKit.GOLD) + "\n"
	s += ("\n".join(lines) if not lines.is_empty() else UIKit.col("Chưa nghe chuyện gì.", UIKit.DIM)) + "\n"
	s += _book_text(c)
	return s


func _char_detail_modal(c: Character) -> void :
	var pages: Array
	if c.is_player:
		pages = [["Chỉ số", _stat_groups_text() + _stat_explain(["Thực", "Tiềm năng"])], ["Thiên phú & tính cách", _self_page_traits()], ["Gia tộc", _self_page_clan()], ["Đôi Mắt", _self_page_eye()], ["Con đường Thiên mệnh", _self_page_paths()]]
	else:
		pages = [["Tổng quan", _npc_page_overview(c)], ["Chỉ số", _npc_page_stats(c)], ["Thiên phú & tính cách", _npc_page_traits(c)], ["Tiểu sử", _npc_page_history(c)]]
	_tabbed_modal("Hồ sơ " + (c.name if not c.is_player else "bản thân: " + c.name), pages)


func _tabbed_modal(title: String, pages: Array) -> void :
	var body: = UIKit.modal(self, title, 920)
	var tc: = TabContainer.new()
	tc.custom_minimum_size = Vector2(900, 580)
	body.add_child(tc)
	for k in pages.size():
		var r: = UIKit.rich()
		r.name = "Trang%d" % k
		r.scroll_active = true
		r.text = str(pages[k][1])
		var pad: = MarginContainer.new()
		pad.name = "P%d" % k
		for side in ["left", "right", "top", "bottom"]:
			pad.add_theme_constant_override("margin_" + side, 12)
		pad.add_child(r)
		tc.add_child(pad)
		tc.set_tab_title(k, str(pages[k][0]))




func _self_page_traits() -> String:
	var p: = w.player()
	var s: = "Mệnh cách %s · Ngộ tính %s\n\n" % [UIKit.col(p.destiny, UIKit.PURPLE), _ngo_bb(p.ngo)]
	s += UIKit.col("Thiên phú", UIKit.GOLD) + "\n"
	for t in p.talents:
		var d: = GameData.talent(t)
		s += "  %s — %s\n" % [_talent_bb(t), d.get("desc", "")]
	s += "\n" + UIKit.col("Tính cách", UIKit.GOLD) + "  " + ", ".join(p.traits.map( func(t: String) -> String: return GameData.trait_name(t))) + "\n"
	s += "\nSức khỏe %s · tuổi %d\n" % [UIKit.col(str(roundi(p.health)), UIKit.GREEN if p.health >= 70.0 else UIKit.RED), p.age(w.m)]
	return s


func _self_page_clan() -> String:
	var p: = w.player()
	var s: = UIKit.col("%s · %s" % [w.clan["name"], PlayerOps.CLAN_TIER_NAMES[PlayerOps.clan_tier(w)]], UIKit.GOLD) + "\n"
	s += "Ngân lượng %d (%+d/tháng) · Danh vọng %d · Môn khách %d\n" % [roundi(PlayerOps.money(w)), roundi(float(w.play["last_income"])), roundi(PlayerOps.prestige(w)), PlayerOps.retainers(w).size()]
	var hl: Array = []
	for hc in PlayerOps.houses(w):
		hl.append("%s %d/%d" % [w.city_name(str(hc)), PlayerOps.house_count(w, str(hc)), PlayerOps.house_cap(w, str(hc))])
	s += "Tư trạch: %s · Theo hầu %d / %d (xe ngựa %d / %d)\n" % [", ".join(hl), PlayerOps.follow_count(w), PlayerOps.follow_cap(w), int(w.clan.get("carts", 0)), PlayerOps.CART_MAX]
	s += "Tư binh %d / %d · Xưởng %d / %d\n" % [int(w.clan.get("troops", 0)), PlayerOps.troop_cap(w), int(w.clan.get("workshops", 0)), PlayerOps.WORKSHOP_MAX]
	if p.office_key != "":
		s += "Đang giữ chức %s%s\n" % [Appointment.office_label_of(w, p), " (có thuộc lại lo việc giấy tờ)" if PlayerOps.has_clerks(w) else " (%d ngày đầu mỗi tháng lo việc công)" % PlayerOps.OFFICE_DAYS]
	var gtp: = Items.gear_text(p)
	s += "Trang bị: %s · kho %d / %d món\n" % [gtp if gtp != "" else UIKit.col("chưa có", UIKit.DIM), Items.store(w).size(), Items.STORE_CAP]
	var spb: = PlayerOps.speed_breakdown(w, bool(PlayerOps.clan_cashflow(w)[1]))
	var spparts: Array = []
	for x in spb[1]:
		spparts.append("%s %d%%" % [x[0], int(x[1])])
	s += "Tốc độ làm việc: %s\n" % ("nhanh hơn %d%% (%s)" % [roundi((1.0 - float(spb[0])) * 100.0), " · ".join(spparts)] if not spparts.is_empty() else "bình thường (Quản gia, Gia thế Danh môn, Cần mẫn giúp làm nhanh hơn)")
	var req: = PlayerOps.tier_requirements(w)
	if not req.is_empty():
		s += "\n" + UIKit.col("Thăng %s (xét đầu năm)" % PlayerOps.CLAN_TIER_NAMES[PlayerOps.clan_tier(w) + 1], UIKit.GOLD) + "\n"
		s += "Danh vọng %d · Ngân lượng %d · %d môn khách trung thành ≥ 60 (hiện %d)%s\n" % [int(req["prestige"]), int(req["money"]), int(req["loyal"]), int(req["now_loyal"]), 
			" · có người bạn tiến cử giữ chức Thượng thư / Tướng" if bool(req["office"]) else ""]
	var st: Dictionary = w.play["stats"]
	s += "\n" + UIKit.col("Đã gặp %d người · thẩm định %d lần · chiêu mộ %d · tiến cử %d · tiên đoán ứng nghiệm %d" % [int(st["met"]), int(st["appraised"]), int(st["recruited"]), int(st["recommended"]), int(st["predicted"])], UIKit.DIM) + "\n"
	return s


func _self_page_eye() -> String:
	var s: = UIKit.col("Đôi Mắt Thẩm Định", UIKit.GOLD) + "  tầng %s · Ngộ đạo %d · điểm ngộ còn %d (mỗi 20 Ngộ đạo được 1 điểm)\n\n" % [Defs.TIER_NAMES[PlayerOps.eye_tier(w)], int(w.play["ngo_dao"]), PlayerOps.branch_points(w)]
	for b in PlayerOps.BRANCH_ORDER:
		var bd: Dictionary = PlayerOps.BRANCHES[b]
		s += "%s %s\n  %s\n" % [UIKit.col(str(bd["name"]), UIKit.GREEN if PlayerOps.has_branch(w, b) else UIKit.TEXT), 
			UIKit.col("(đã mở)" if PlayerOps.has_branch(w, b) else "(%d điểm)" % int(bd["cost"]), UIKit.DIM), UIKit.col(str(bd["desc"]), UIKit.DIM)]
	s += "\n" + UIKit.col("Ngộ đạo có được khi thẩm định người mới, nhìn thấu ngụy trang, và khi lời tiên đoán ứng nghiệm.", UIKit.DIM)
	return s


func _self_page_paths() -> String:
	var s: = UIKit.col("Con đường Thiên mệnh (kết thúc)", UIKit.PURPLE) + "\n\n"
	for pr in Endings.progress(w):
		s += "%s\n  %s\n\n" % [UIKit.col(Endings.NAMES[pr["id"]], UIKit.GOLD), pr["text"]]
	return s



func _with_portrait(c: Character, head: String) -> String:
	var img: = Portraits.bb(w, c, PORTRAIT_W)
	if img == "":
		return head
	return "[table=2][cell]%s   [/cell][cell]%s[/cell][/table]\n" % [img, head.strip_edges(false, true)]


const PORTRAIT_W: = 92


func _add_npc_row(t: Tree, parent: TreeItem, c: Character, cells: Array) -> TreeItem:
	var it: = t.create_item(parent)
	for i in cells.size():
		it.set_text(i, str(cells[i]))
	var pt: = Portraits.tex(w, c)
	if pt != null:
		it.set_icon(0, pt)
		it.set_icon_max_width(0, 22)
	var starred: = PlayerOps.is_starred(w, c.id)
	if starred:
		it.set_text(0, "★ " + str(cells[0]))
	it.set_metadata(0, "npc:" + c.id)
	if not c.alive:
		for i in cells.size():
			it.set_custom_color(i, UIKit.DIM)
	elif starred or (PlayerOps.met_now(w, c) and not PlayerOps.is_retainer(w, c)):
		it.set_custom_color(0, UIKit.GOLD)
	if sel == "npc:" + c.id:
		it.select(0)
	return it


func _section(t: Tree, root: TreeItem, title: String) -> TreeItem:
	var it: = t.create_item(root)
	it.set_text(0, title)
	it.set_custom_color(0, UIKit.DIM)
	it.set_selectable(0, false)
	it.set_expand_right(0, true)
	for i in range(1, t.columns):
		it.set_selectable(i, false)
		it.set_expand_right(i, true)
	return it


func _here_tab() -> void :
	var cid: = PlayerOps.here(w)
	for ch in leads_box.get_children():
		leads_box.remove_child(ch)
		ch.queue_free()
	var leads: Array = []
	for l in w.play["leads"]:
		if str(l["city"]) == cid:
			leads.append(l)
	leads_title.text = "Manh mối ở %s (%d)" % [w.city_name(cid), leads.size()]
	scout_btn.text = "Dò la" + _d("scout")
	tea_btn.text = "Trà quán" + _d("teahouse")
	if leads.is_empty():
		leads_box.add_child(UIKit.label("Chưa có. Bấm \"Dò la\" bên phải để nghe lời đồn.", 14, UIKit.DIM))
	for l in leads:
		var row: = UIKit.hbox(10)
		var tx: = UIKit.rich(true)
		tx.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tx.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		tx.text = "❝ %s ❞  %s" % [str(l["text"]), UIKit.col("· %s" % ("tháng này" if int(l["m"]) == w.m else "%d tháng trước" % (w.m - int(l["m"]))), UIKit.DIM)]
		row.add_child(tx)
		var lid: = str(l["id"])
		var b: = UIKit.button("Tìm gặp" + _d("meet"), func() -> void : _meet_lead(lid), "Gặp người trong lời đồn")
		b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(b)
		var p: = UIKit.panel(row, UIKit.PANEL2 if sel == "lead:" + lid else UIKit.PANEL, 8)
		leads_box.add_child(p)
	_fit_leads()
	here_tree.clear()
	var root: = here_tree.create_item()
	var known: Array = []
	for c: Character in w.living():
		if c.city_id == cid and PlayerOps.is_known(w, c) and not PlayerOps.is_retainer(w, c):
			known.append(c)
	known.sort_custom( func(a: Character, b: Character) -> bool: return a.name < b.name)
	known_title.text = "Người đã biết ở %s (%d)" % [w.city_name(cid), known.size()]
	for c: Character in known:
		var note: = "vừa gặp" if PlayerOps.met_now(w, c) else ""
		_add_npc_row(here_tree, root, c, [c.name, c.age(w.m), _role_public(c), note])



func _fit_leads() -> void :
	await get_tree().process_frame
	if not is_instance_valid(leads_box):
		return
	leads_scroll.custom_minimum_size.y = minf(leads_box.get_combined_minimum_size().y, LEADS_MAX_H)


const LEADS_MAX_H: = 290.0


func _book_tab() -> void :
	book_tree.clear()
	var root: = book_tree.create_item()
	var stars: Array = []
	var hopes: Array = []
	var met: Array = []
	var past: Array = []
	var book: Dictionary = w.play.get("book", {})
	for c: Character in w.chars.values():
		if c.is_player:
			continue
		if PlayerOps.is_starred(w, c.id):
			stars.append(c)
			continue
		if PlayerOps.is_retainer(w, c):
			continue
		var n: Dictionary = w.notebook.get(c.id, {})
		if n.is_empty():
			if book.has(c.id):
				past.append(c)
			continue
		if not (n.get("pred", []) as Array).is_empty() and c.alive:
			hopes.append(c)
		else:
			met.append(c)
	var by_pot: = func(a: Character, b: Character) -> bool:
		if a.alive != b.alive:
			return a.alive
		var pa: float = _best_pot_text(a)[1]
		var pb: float = _best_pot_text(b)[1]
		if pa != pb:
			return pa > pb
		return a.name < b.name
	stars.sort_custom(by_pot)
	hopes.sort_custom(by_pot)
	met.sort_custom(by_pot)
	past.sort_custom( func(a: Character, b: Character) -> bool: return a.name < b.name)
	tabs.set_tab_title(1, "Sổ nhân vật (%d)" % (stars.size() + hopes.size() + met.size() + past.size()))
	var groups: = [
		["★ Lưu tâm (%d)" % stars.size(), stars, "Chọn một người rồi bấm \"★ Lưu tâm\" để ghim vào đây."], 
		["Ngọc thô (%d)" % hopes.size(), hopes, "Thẩm định thấy tiềm năng ≥ 75 mà thực lực còn thấp thì tự vào đây."], 
		["Đã gặp (%d)" % met.size(), met, "Chưa gặp ai. Dò la rồi Tìm gặp."], 
		["Thiên Thư – kiếp trước (%d)" % past.size(), past, "Những người đã gặp ở các đời trước, chưa gặp lại ở đời này."], 
	]
	for gr in groups:
		var sec: = _section(book_tree, root, str(gr[0]))
		var lst: Array = gr[1]
		if lst.is_empty():
			var e: = book_tree.create_item(sec)
			e.set_text(0, "(trống)")
			e.set_tooltip_text(0, str(gr[2]))
			e.set_custom_color(0, UIKit.DIM)
			e.set_selectable(0, false)
		for c: Character in lst:
			var bp: = _best_pot_text(c)
			var appr_t: = _appr_age_text(c)
			if appr_t == "chưa" and book.has(c.id):
				appr_t = "kiếp trước"
				if int(w.play.get("memory", 0)) >= 1:
					bp = _book_pot(c)
			var it: = _add_npc_row(book_tree, sec, c, [c.name, c.age(w.m) if c.alive else c.age(c.death_m), w.city_name(c.city_id), _role_public(c), bp[0], appr_t])
			if float(bp[1]) >= 0.0:
				it.set_custom_color(4, UIKit.grade_color(float(bp[1])))


func _book_pot(c: Character) -> Array:
	var e: Dictionary = w.play.get("book", {}).get(c.id, {})
	var rec: Dictionary = e.get("appr", {})
	if rec.is_empty():
		return ["—", -1.0]
	var best: = -1
	var hi: = -1.0
	for i in Defs.N_STATS:
		var pb: Array = rec["pot"][i]
		if not pb.is_empty() and float(pb[1]) > hi:
			hi = float(pb[1])
			best = i
	if best < 0:
		return ["—", -1.0]
	var pb2: Array = rec["pot"][best]
	return ["%s %d–%d" % [Defs.STAT_SHORT[best], int(pb2[0]), int(pb2[1])], (float(pb2[0]) + float(pb2[1])) / 2.0]


func _book_text(c: Character) -> String:
	var e: Dictionary = w.play.get("book", {}).get(c.id, {})
	if e.is_empty():
		return ""
	var lv: = int(w.play.get("memory", 0))
	var s: = "\n" + UIKit.col("Thiên Thư (ký ức đời thứ %d):" % int(e["life"]), UIKit.PURPLE) + " từng gặp ở %s, khi ấy là %s.\n" % [w.city_name(str(e["city"])), Defs.prof_name(str(e["prof"])).to_lower()]
	var rec: Dictionary = e.get("appr", {})
	if lv >= 1 and not rec.is_empty():
		var parts: Array = []
		for i in Defs.N_STATS:
			var pb: Array = rec["pot"][i]
			if not pb.is_empty() and int(pb[1]) >= 50:
				parts.append("%s %d–%d" % [Defs.STAT_SHORT[i], int(pb[0]), int(pb[1])])
		s += "   Tiềm năng từng thấy: %s\n" % (", ".join(parts) if not parts.is_empty() else "không có gì nổi bật")
	if lv >= 2 and not rec.is_empty():
		var tl: Array = rec.get("talents", [])
		var tr: Array = rec.get("traits", [])
		s += "   Thiên phú: %s · Tính cách: %s%s\n" % [", ".join(tl.map( func(x: String) -> String: return _talent_bb(x))) if not tl.is_empty() else "không thấy", 
			", ".join(tr.map( func(x: String) -> String: return GameData.trait_name(x))) if not tr.is_empty() else "?", 
			" · Ngộ tính " + _ngo_bb(int(rec["ngo"])) if rec.has("ngo") else ""]
	if lv >= 3:
		var fs: Array = e.get("fates", [])
		if fs.is_empty():
			s += "   Không nhớ biến cố định mệnh nào.\n"
		for f in fs:
			s += UIKit.col("   Định mệnh: %s – %s\n" % [World.date_of(int(f["m"])), GameData.event_name(str(f["ev"]))], UIKit.RED)
	if lv >= 4:
		var en: Dictionary = e.get("end", {})
		if not en.is_empty():
			s += "   Kết cục đời trước: %s · %s %d\n" % [str(en["status"]), Defs.STAT_NAMES[int(en["top"])], int(en["real"])]
	if lv < 4:
		s += UIKit.col("   (Nâng cấp Ký ức để nhớ nhiều hơn.)\n", UIKit.DIM)
	return s


func _ret_tab() -> void :
	ret_tree.clear()
	var root: = ret_tree.create_item()
	var rs: = PlayerOps.retainers(w)
	tabs.set_tab_title(2, "Môn khách (%d)" % rs.size())
	if rs.is_empty():
		var e: = ret_tree.create_item(root)
		e.set_text(0, "Chưa có môn khách. Gặp người tài rồi Chiêu mộ.")
		e.set_custom_color(0, UIKit.DIM)
		e.set_selectable(0, false)
		return

	var groups: = {"follow": []}
	var order: Array = ["follow"]
	for hc in PlayerOps.houses(w):
		groups["house:" + str(hc)] = []
		order.append("house:" + str(hc))
	groups["away"] = []
	order.append("away")
	for c: Character in rs:
		var l: = PlayerOps.loc(w, c)
		match str(l.get("st", "")):
			"follow":
				groups["follow"].append(c)
			"house":
				var k: = "house:" + str(l["city"])
				if not groups.has(k):
					groups[k] = []
					order.insert(order.size() - 1, k)
				groups[k].append(c)
			_:
				groups["away"].append(c)
	for k in order:
		var lst: Array = groups[k]
		var title: = ""
		if k == "follow":
			title = "Đang đi theo (%d / %d)" % [lst.size(), PlayerOps.follow_cap(w)]
		elif k == "away":
			if lst.is_empty():
				continue
			title = "Đang lên đường / ở trọ (%d)" % lst.size()
		else:
			var cid: = str(k).substr(6)
			title = "Tư trạch %s (%d / %d)" % [w.city_name(cid), lst.size(), PlayerOps.house_cap(w, cid)]
		var sec: = _section(ret_tree, root, title)
		if lst.is_empty():
			var e2: = ret_tree.create_item(sec)
			e2.set_text(0, "  (trống)")
			e2.set_custom_color(0, UIKit.DIM)
			e2.set_selectable(0, false)
		for c: Character in lst:
			var note: = PlayerOps.loyalty_word(c) + (" · khủng hoảng" if not c.crisis.is_empty() else "") + (" · dự thi" if PlayerOps.exam_flag(w, c.id) else "")
			if k == "away":
				note = PlayerOps.loc_text(w, c) + " · " + note
			if not Purse.debt_of(w, c.id).is_empty():
				note = "bạn nợ %d · " % int(Purse.debt_of(w, c.id)["amt"]) + note
			_add_npc_row(ret_tree, sec, c, [c.name, c.age(w.m), _task_text(c), w.play["salary"].get(c.id, 0), roundi(c.purse), _power_text(c), note])



func _power_text(c: Character) -> String:
	var rec: Dictionary = w.notebook.get(c.id, {}).get("appr", {})
	if rec.is_empty():
		rec = PlayerOps.impression(w, c)
	var lo: = 0
	var hi: = 0
	var bands: Array = (rec["real"] as Array).duplicate()
	if rec.has("mi_real"):
		bands.append(rec["mi_real"])
	for b in bands:
		if (b as Array).is_empty():
			continue
		lo += int(b[0])
		hi += int(b[1])
	return str(lo) if lo == hi else "%d–%d" % [lo, hi]


func _task_text(c: Character) -> String:
	var parts: Array = []
	var st: = PlayerOps.study_of(w, c)
	if st != "":
		parts.append("Học: " + str(PlayerOps.TASKS[st]["name"]).replace("Theo học ", "").replace("Rèn luyện ở ", "").replace("Học việc ở ", "").replace("Làm ở ", "") + (" (ngưng)" if PlayerOps.study_pause(w, c) != "" else ""))
	var task: = PlayerOps.job_of(w, c)
	if task == "day_do":
		var stu: = w.ch(str(w.play.get("teach", {}).get(c.id, "")))
		parts.append("Dạy dỗ %s" % (stu.name if stu != null else "?"))
	elif task != "":
		parts.append(str(PlayerOps.TASKS[task]["name"]) + (" (ngưng)" if PlayerOps.task_pause(w, c) != "" else ""))
	if parts.is_empty():
		parts.append("Rảnh rỗi")
	var s: = " · ".join(parts)
	if PlayerOps.both_on(w, c):
		s += " · vừa học vừa làm"
	if c.mentor_m > 0:
		s += " · có thầy"
	return s


static func _plain_range(b: Array) -> String:
	if b.is_empty():
		return "?"
	return str(b[0]) if int(b[0]) == int(b[1]) else "%d–%d" % [int(b[0]), int(b[1])]


func _court() -> void :
	var keep: = court_tabs.current_tab
	for ch in court_tabs.get_children():
		court_tabs.remove_child(ch)
		ch.queue_free()
	var p: = w.player()
	var order: Array = []
	if w.nations.has(p.nation_id):
		order.append(p.nation_id)
	for nid in w.nations:
		if not order.has(nid):
			order.append(nid)
	for nid in order:
		court_tabs.add_child(_court_page(str(nid)))
		court_tabs.set_tab_title(court_tabs.get_tab_count() - 1, str(w.nations[nid]["name"]) + (" ★" if nid == p.nation_id else "") + (" ⚔" if not War.wars_of(w, nid).is_empty() else ""))
	if keep >= 0 and keep < court_tabs.get_tab_count():
		court_tabs.current_tab = keep



func _court_page(nid: String) -> Control:
	var nat: Dictionary = w.nations[nid]
	var p: = w.player()
	var own: = nid == p.nation_id
	var page: = UIKit.vbox(6)
	page.name = "N_" + nid
	var head: = UIKit.rich(true)
	var s: = "[font_size=18]%s[/font_size]  %s\n" % [UIKit.col(str(nat["name"]), UIKit.GOLD), UIKit.col(("bản quốc" if own else "ngoại quốc") + " · vua " + str(nat.get("ruler", "")) + " · kinh đô " + w.city_name(str(nat["capital"])), UIKit.DIM)]
	s += "Ổn định %s · Quân %dk · Ngân khố %d%s · Ảnh hưởng của bạn %d\n" % [UIKit.col(str(roundi(nat["stability"])), UIKit.grade_color(float(nat["stability"]))), roundi(float(nat["troops"]) / 1000.0), 
		roundi(float(nat.get("treasury", 0))), UIKit.col(" · thiếu lương", UIKit.RED) if bool(nat.get("shortage", false)) else "", roundi(float(w.play["influence"].get(nid, 0.0)))]
	var rels: Array = []
	for other in w.nations:
		if other == nid:
			continue
		var rv: = w.relation(nid, other)
		var tag: = War.rel_name(rv)
		var col: = UIKit.DIM
		if War.allied(w, nid, other):
			tag = "Đồng minh"
			col = UIKit.GREEN
		if War.at_war(w, nid, other):
			tag = "GIAO CHIẾN"
			col = UIKit.RED
		elif int(War.pact(w, nid, other)["truce"]) > w.m:
			tag += " · đình chiến"
		rels.append("%s %s" % [w.nation_name(other), UIKit.col("%s (%+d)" % [tag, roundi(rv)], col)])
	s += "Bang giao: " + " · ".join(rels) + "\n"
	for wr in War.wars_of(w, nid):
		var attacking: = str(wr["a"]) == nid
		var sc: = float(wr["score"]) * (1.0 if attacking else -1.0)
		s += UIKit.col("⚔ %s %s · tiền tuyến %s · chiến cục %+d (%s)" % ["Đang đánh" if attacking else "Bị đánh bởi", w.nation_name(str(wr["b"] if attacking else wr["a"])), w.city_name(str(wr["front"])), roundi(sc), "ta ưu thế" if sc > 0 else "địch ưu thế"], UIKit.RED) + "\n"
	var clans: Array = []
	for rid in w.rivals:
		var rv2: Dictionary = w.rivals[rid]
		if str(rv2["nation"]) == nid and not Rivals.is_fallen(rv2):
			clans.append("%s (%d ghế)" % [rv2["name"], Rivals.officials(w, str(rid)).size()])
	if not clans.is_empty():
		s += UIKit.col("Thế gia: " + ", ".join(clans), UIKit.PURPLE) + "\n"
	head.text = s
	page.add_child(UIKit.panel(head, UIKit.PANEL2, 8))
	var t: = _tree(["Chức vụ", "Người giữ", "Thế lực", "Tiếng tăm"], [170, 170, 120, 90])
	t.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(t)
	var root: = t.create_item()
	var central: = _section(t, root, "Trung ương")
	var city_sec: = {}
	for key in nat["offices"]:
		var slot: Dictionary = nat["offices"][key]
		var oid: = Appointment.office_of_key(str(key))
		var parent: = central
		var label: = str(Defs.OFFICES[oid]["name"])
		if bool(Defs.OFFICES[oid].get("per_city", false)):
			var cid: = str(slot["city"])
			if not city_sec.has(cid):
				city_sec[cid] = _section(t, root, "Thành " + w.city_name(cid))
			parent = city_sec[cid]
		var c: = w.office_holder(nid, str(key))
		var it: = t.create_item(parent)
		it.set_text(0, label)
		if c == null:
			it.set_text(1, "(trống)")
			it.set_custom_color(1, UIKit.RED)
			it.set_selectable(0, false)
			continue
		it.set_text(1, ("★ " if PlayerOps.is_starred(w, c.id) else "") + c.name)
		var side: = ""
		var scol: = UIKit.DIM
		if c.recommender == p.id:
			side = "◆ người của bạn"
			scol = UIKit.GOLD
		elif Rivals.backer(c) != "" and w.rivals.has(Rivals.backer(c)):
			side = str(w.rivals[Rivals.backer(c)]["name"])
			scol = UIKit.PURPLE
		it.set_text(2, side)
		it.set_custom_color(2, scol)
		var sc2: = Appraisal.perceived_office_score(w, c, oid)
		it.set_text(3, "~%d" % (roundi(sc2 / 5.0) * 5))
		it.set_custom_color(3, UIKit.grade_color(sc2))
		var pt: = Portraits.tex(w, c)
		if pt != null:
			it.set_icon(1, pt)
			it.set_icon_max_width(1, 22)
		it.set_tooltip_text(1, UIKit.wrap_tip(_person_tip(c), 70))
		it.set_tooltip_text(3, UIKit.wrap_tip(_score_tip(c, nid, str(key), [["Đang giữ chức %d năm (thâm niên)" % (c.office_months / 12), Appointment.incumbency(c)]]), 70))
		it.set_metadata(0, "npc:" + c.id)
		if c.recommender == p.id:
			it.set_custom_color(1, UIKit.GOLD)
	var foot: = UIKit.wrap_label("Tiếng tăm = điều triều đình đánh giá (Đôi Mắt của bạn có thể thấy khác). Tiến cử phải đứng ở kinh đô nước nhận người. Đưa người sang nước khác thưởng nhiều hơn nhưng bản quốc nghi kỵ (hiện %d/60)." % roundi(float(w.play["suspicion"])), 12, UIKit.DIM)
	page.add_child(foot)
	return page


func _news() -> void :
	var s: = ""
	var n: = w.news.size()
	var shown: = 0
	for k in range(n - 1, -1, -1):
		var e: Dictionary = w.news[k]
		if str(e["k"]) == "an":
			continue
		var c: = UIKit.TEXT
		match str(e["k"]):
			"bien_co", "chien_su":
				c = UIKit.RED
			"co_duyen":
				c = UIKit.GOLD
			"bo_nhiem":
				c = UIKit.BLUE
		s += "%s  %s\n" % [UIKit.col(World.date_cap(int(e["m"])), UIKit.DIM), UIKit.col(str(e["t"]), c)]
		shown += 1
		if shown >= 200:
			break
	news_txt.text = s if s != "" else UIKit.col("Thiên hạ chưa có tin gì.", UIKit.DIM)





func _more(text: String, cb: Callable, enabled: bool = true, tip: String = "") -> void :
	more_acts.append({"t": text, "cb": cb, "ok": enabled, "tip": tip})


func _flush_more() -> void :
	more_pending = false
	if more_acts.is_empty():
		return
	var items: = more_acts.duplicate()
	var title: = more_title
	var n: = items.filter( func(x: Dictionary) -> bool: return bool(x["ok"])).size()
	_act("Khác… (%d)" % n, func() -> void : _menu(title, items), true, "Các việc khác: " + ", ".join(items.map( func(x: Dictionary) -> String: return str(x["t"]).split(" (")[0].replace("…", ""))))



func _menu(title: String, items: Array) -> void :
	var body: = UIKit.modal(self, title, 1040)
	var grid: = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 8)
	body.add_child(grid)
	for it: Dictionary in items:
		var row: = UIKit.hbox(10)
		var tx: = UIKit.rich(true)
		tx.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tx.text = "%s\n%s" % [UIKit.col(str(it["t"]), UIKit.GOLD if bool(it["ok"]) else UIKit.DIM), UIKit.col(str(it["tip"]), UIKit.DIM if bool(it["ok"]) else UIKit.RED)]
		row.add_child(tx)
		var cb: Callable = it["cb"]
		var b: = UIKit.button("Chọn", func() -> void :
			UIKit.close_modal(body)
			cb.call())
		b.disabled = not bool(it["ok"])
		b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(b)
		var pn: = UIKit.panel(row, UIKit.PANEL, 8)
		pn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pn.custom_minimum_size.x = 500
		grid.add_child(pn)


func _clear_actions() -> void :
	more_acts = []
	more_title = "Việc khác"
	if not more_pending:
		more_pending = true
		call_deferred("_flush_more")
	for ch in action_box.get_children():
		ch.queue_free()
	for ch in eye_box.get_children():
		ch.queue_free()
	eye_line.visible = false


func _act(text: String, cb: Callable, enabled: bool = true, tip: String = "") -> Button:
	var b: = UIKit.button(text, cb, tip)
	b.disabled = not enabled
	action_box.add_child(b)
	return b



func _open_detail() -> void :
	if sel == "self":
		_char_detail_modal(w.player())
	elif sel.begins_with("npc:") and w.ch(sel.split(":")[1]) != null:
		_char_detail_modal(w.ch(sel.split(":")[1]))


func _detail() -> void :
	_clear_actions()
	detail_btn.visible = sel == "self" or sel.begins_with("npc:")
	if sel == "notice":
		detail_txt.text = UIKit.col("[font_size=18]Không tìm ra người[/font_size]", UIKit.RED) + "\n\n" + notice + "\n\n" + UIKit.col("Manh mối vẫn còn ở tab Tại đây; có thể Tìm gặp lại (lời đồn càng cũ càng khó tìm).", UIKit.DIM)
		return
	hint_txt.text = UIKit.col("Gợi ý: ", UIKit.GOLD) + _next_hint()
	if sel == "self":
		_detail_self()
		return
	if sel.begins_with("clan:"):
		if w.rivals.has(sel.substr(5)):
			_detail_clan(sel.substr(5))
			return
		sel = "self"
		_detail_self()
		return
	var parts: = sel.split(":")
	var c: = w.ch(parts[1]) if parts.size() > 1 else null
	if c == null:
		sel = "self"
		_detail_self()
		return
	if parts[0] == "lead":
		_detail_lead(c)
	else:
		_detail_npc(c)



func _next_hint() -> String:
	var here: = PlayerOps.here(w)
	if sel.begins_with("npc:"):
		var c: = w.ch(sel.split(":")[1])
		if c != null and c.alive:
			var ret: = PlayerOps.is_retainer(w, c)
			var met: = PlayerOps.met_now(w, c)
			var rec: Dictionary = w.notebook.get(c.id, {}).get("appr", {})
			if c.office_key != "" or (c.nation_id != "" and not ret):
				return "Người này đã thuộc về triều đình, không chiêu mộ hay tiến cử được. Bạn chỉ có thể gặp và thẩm định để biết họ giỏi đến đâu."
			if not ret and not met:
				if c.city_id == here:
					return "Bấm [b]Gặp gỡ[/b] trước. Gặp mặt rồi (trong %d ngày, còn ở cùng thành) mới thẩm định, chiêu mộ hay tiến cử được." % PlayerOps.MEET_WINDOW
				return "%s đang ở %s. Bấm thành đó trên bản đồ để đi tới, rồi Gặp gỡ." % [c.name, w.city_name(c.city_id)]
			if rec.is_empty() or int(rec["m"]) < w.m - 12:
				return "Bấm [b]Trung cấp[/b] ở hàng Thẩm định để thấy tiềm năng và thiên phú (tốn 2 Nhãn lực, không tốn ngày)."
			if not ret and PlayerOps.recruit_block(w, c) == "":
				return "Nếu tiềm năng cao (chữ vàng / cam), bấm [b]Chiêu mộ[/b] để nhận làm môn khách. Nếu đã có thực lực và bạn đang ở kinh đô, có thể [b]Tiến cử[/b] luôn."
			if ret and PlayerOps.job_of(w, c) == "" and PlayerOps.study_of(w, c) == "":
				return "Môn khách đang rảnh. Bấm [b]Đào tạo[/b] để họ rèn luyện đúng sở trường, hoặc [b]Giao việc[/b] để làm việc cho gia tộc."
			if ret and PlayerOps.capital_nations(w).is_empty():
				return "Muốn tiến cử môn khách này, hãy đến kinh đô: %s." % PlayerOps.capitals_text(w)
	if sel.begins_with("lead:"):
		return "Bấm [b]Tìm gặp[/b] để biết lời đồn nói về ai."
	var leads_here: = 0
	for l in w.play["leads"]:
		if str(l["city"]) == here:
			leads_here += 1
	if leads_here > 0:
		return "Có %d manh mối ở tab [b]Tại đây[/b]: bấm [b]Tìm gặp[/b] cạnh lời đồn để biết là ai." % leads_here
	for c: Character in PlayerOps.retainers(w):
		var rec2: Dictionary = w.notebook.get(c.id, {}).get("appr", {})
		var lo: = 0
		if not rec2.is_empty():
			for rb in rec2["real"]:
				lo = maxi(lo, int(rb[0]))
		if lo >= 45:
			if PlayerOps.capital_nations(w).is_empty():
				return "Môn khách %s đã khá (Thực ≥ %d). Đến kinh đô (%s) để tiến cử nhận thưởng." % [c.name, lo, PlayerOps.capitals_text(w)]
			return "Bạn đang ở kinh đô: mở tab [b]Môn khách[/b], chọn %s rồi bấm [b]Tiến cử[/b]." % c.name
	return "Bấm [b]Dò la[/b] (cạnh dòng Manh mối, tab Tại đây) để nghe lời đồn về người tài trong thành."



const HEAD_TIP: = {
	"Ấn tượng": "Điều thiên hạ và triều đình nhìn thấy: suy từ nghề nghiệp, danh tiếng, lời đồn. Khoảng rộng, có thể sai (người giấu tài, kẻ hư danh). Triều đình xét tiến cử theo Ấn tượng, không theo Thực.", 
	"Thực": "Năng lực hiện tại mà Đôi Mắt của bạn thấy khi thẩm định. Tầng thẩm định càng cao, khoảng càng hẹp. Người ta lớn lên hoặc sa sút theo thời gian, nên kết quả cũ có thể đã sai.", 
	"Tiềm năng": "Mức cao nhất người này có thể đạt nếu được rèn đúng hướng. Chỉ số Thực lớn dần tới đây, càng gần càng chậm; chỉ số ngoài hướng tu dưỡng chỉ lớn ×0,2. Biến cố, thầy giỏi, thiên phú có thể làm tiềm năng đổi.", 
	"Thám báo": "Tin do người bạn cử đi dò (không cần gặp mặt): tình hình ở thời điểm dò, độ chính xác theo mức thám báo.", 
	"Thực / TN": "Chỉ số thực hiện tại / tiềm năng (mức cao nhất có thể đạt).", 
	"Chỉ số": "Rê chuột lên tên từng chỉ số để xem nó dùng vào việc gì.", 
}
const STAT_TIP: = {
	"Võ lực": "Sức đánh, võ nghệ. Dùng cho: tự vệ khi gặp cướp, thách đấu, Hộ vệ, tướng ra trận, chính biến. Binh khí cộng thêm.", 
	"Trí lực": "Hiểu biết, mưu lược. Dùng cho: thẩm định (khoảng hẹp hơn), dò la (nhiều manh mối hơn), mưu sĩ, thầy thuốc, Mật thám; dễ tìm ra người trong lời đồn.", 
	"Quân sự": "Cầm quân, bày trận. Dùng cho: Tướng quân, Đô úy, Theo quân (đẩy chiến cục); quyết định thắng thua ở tiền tuyến.", 
	"Chính trị": "Cai trị, xử việc, lễ nghi. Dùng cho: quan văn (Thừa tướng, các bộ, Thái thú, Huyện lệnh), tiến cử, kết giao quan lại, Quản gia.", 
	"Sản xuất": "Làm ra của cải. Dùng cho: Công bộ, thu nhập gia tộc, xưởng, chế tác binh khí / y phục / tọa kỵ.", 
	"Thương nghiệp": "Buôn bán, tiền bạc. Dùng cho: Hộ bộ, Kinh doanh cho gia tộc, buôn chuyến, thu nhập gia tộc.", 
	"Mị lực": "Dung mạo, phong thái, ăn nói. Dùng cho: triều đình xét duyệt (dưới 25 có thể bị chê thẳng), chiêu mộ, thăm hỏi, khuyên nhủ, Thuyết khách. Y phục cộng thêm. Lớn chậm (×0,5), nhanh ở văn đàn, triều đình, thương hội.", 
}



func _label_tip(l: Label, tip: String) -> void :
	l.tooltip_text = UIKit.wrap_tip(tip)
	l.mouse_filter = Control.MOUSE_FILTER_PASS


static func _tip(text: String, tip: String) -> String:
	return "[hint=\"%s\"]%s[/hint]" % [UIKit.wrap_tip(tip.replace("\"", "'").replace("[", "(").replace("]", ")")), text]



func _stat_bb(shown: String) -> String:
	var key: = shown.replace("★", "").replace("•", "").strip_edges()
	return _tip(shown, key + ": " + STAT_TIP[key]) if STAT_TIP.has(key) else shown


func _stat_table(rows: Array, heads: Array) -> String:
	var s: = "[table=%d]" % heads.size()
	for h in heads:
		var hs: = UIKit.col(str(h), UIKit.DIM)
		s += "[cell]%s   [/cell]" % (_tip(hs, HEAD_TIP[str(h)]) if HEAD_TIP.has(str(h)) else hs)
	for r in rows:
		for k in r.size():
			s += "[cell]%s   [/cell]" % (_stat_bb(str(r[k])) if k == 0 else str(r[k]))
	return s + "[/table]"



func _stat_explain(heads: Array) -> String:
	var s: = "\n" + UIKit.col("Cách đọc bảng", UIKit.GOLD) + "\n"
	for h in heads:
		if HEAD_TIP.has(str(h)) and str(h) != "Chỉ số":
			s += "%s: %s\n" % [UIKit.col(str(h), UIKit.TEXT), UIKit.col(HEAD_TIP[str(h)], UIKit.DIM)]
	s += "\n" + UIKit.col("Các chỉ số", UIKit.GOLD) + "\n"
	for k in STAT_TIP:
		s += "%s: %s\n" % [UIKit.col(str(k), UIKit.TEXT), UIKit.col(STAT_TIP[k], UIKit.DIM)]
	s += UIKit.col("Mức đánh giá (màu chữ): dưới 20 Kém (xám) · 20–39 Bình thường (trắng) · 40–59 Khá (xanh lá) · 60–74 Xuất sắc (xanh lam) · 75–89 Thiên tài (vàng) · 90–99 Tuyệt thế (cam) · 100 Truyền kỳ (đỏ).", UIKit.DIM) + "\n"
	return s


func _detail_self() -> void :
	var p: = w.player()
	var s: = "[font_size=22]%s[/font_size]  %s\n" % [UIKit.col(p.name, UIKit.GOLD), UIKit.col("(%d tuổi · vòng đời thứ %d)" % [p.age(w.m), w.life], UIKit.DIM)]
	s += "Mệnh cách %s · Ngộ tính %s\n" % [UIKit.col(p.destiny, UIKit.PURPLE), _ngo_bb(p.ngo)]
	s += "%s · %s · Sức khỏe %s\n" % [w.clan["name"], PlayerOps.CLAN_TIER_NAMES[PlayerOps.clan_tier(w)], UIKit.col(str(roundi(p.health)), UIKit.GREEN if p.health >= 70.0 else UIKit.RED)]
	if p.office_key != "":
		s += UIKit.col("Đang giữ chức %s\n" % Appointment.office_label_of(w, p), UIKit.GOLD)
	s = _with_portrait(p, s)
	s += _stat_compact_text()
	detail_txt.text = s
	var tn: = PlayerOps.trained_this_month(w)
	_act("Tự tu dưỡng…" + _d("train"), _train_modal, tn < PlayerOps.TRAIN_MAX, 
		"Đã tu dưỡng %d / %d lần tháng này" % [tn, PlayerOps.TRAIN_MAX])
	var mb: = Daily.meditate_block(w)
	_act("Tĩnh tâm" + _d("meditate"), func() -> void : _do_pop(Daily.meditate(w), "Tĩnh tâm"), mb == "", 
		mb if mb != "" else "Hồi %d Nhãn lực (kinh đô / thành có Học phủ: 2), tối đa %d lần mỗi tháng" % [Daily.meditate_gain(w), Daily.MEDITATE_MAX])
	more_title = "Việc của gia tộc"
	_more("Chính biến…", _coup_modal, true, "Xem điều kiện phát động chính biến đoạt quyền bản quốc")
	_more("Mộ tư binh" + _d("troops"), func() -> void : _do(PlayerOps.recruit_troops(w)), true, 
		"%d lượng mộ %d lính, nuôi %.1f lượng/lính/tháng. Tư binh giúp chính biến, theo quân, đánh cướp." % [PlayerOps.TROOP_COST, PlayerOps.TROOP_BATCH, PlayerOps.TROOP_UPKEEP])
	_act("Kho đồ…", func() -> void : _items_modal(w.player_id), true, "Trang bị, chế tác, mua bán binh khí, y phục, tọa kỵ")
	_more("Sắm xe ngựa · %d" % PlayerOps.CART_COST, func() -> void : _do(PlayerOps.buy_cart(w)), 
		int(w.clan.get("carts", 0)) < PlayerOps.CART_MAX and PlayerOps.money(w) >= PlayerOps.CART_COST, 
		"Thêm 1 người theo hầu (tối đa %d xe); phí %d lượng/tháng" % [PlayerOps.CART_MAX, int(PlayerOps.CART_UPKEEP)])
	_more("Mở xưởng" + _d("workshop"), func() -> void : _do(PlayerOps.build_workshop(w)), int(w.clan.get("workshops", 0)) < PlayerOps.WORKSHOP_MAX, 
		"%d lượng, thu ~%d lượng/tháng (theo Sản xuất của bạn)." % [PlayerOps.WORKSHOP_COST, roundi(PlayerOps.workshop_income(w))])
	if p.office_key != "":
		_more("Từ quan", func() -> void : _do(PlayerOps.resign_office(w)), true, "Thôi làm quan: mất lương và Ảnh hưởng hằng tháng, được rảnh 6 ngày đầu tháng")
	for b in PlayerOps.BRANCH_ORDER:
		if not PlayerOps.has_branch(w, b) and PlayerOps.branch_points(w) >= int(PlayerOps.BRANCHES[b]["cost"]):
			var bid: String = b
			var bd2: Dictionary = PlayerOps.BRANCHES[b]
			_act("Mở %s (%d điểm)" % [bd2["name"], int(bd2["cost"])], func() -> void : _do(PlayerOps.unlock_branch(w, bid)), 
				PlayerOps.branch_points(w) >= int(bd2["cost"]), str(bd2["desc"]))




func _stat_compact_text() -> String:
	var p: = w.player()
	var strong: = PlayerOps.strength_stat(w)
	var sug: = PlayerOps.train_suggestion(w)
	var s: = "Nên tu dưỡng: %s\n" % (UIKit.col(PlayerOps.pstat_name(sug), UIKit.GREEN) if sug >= 0 else UIKit.col("các chỉ số đã gần trần", UIKit.DIM))
	s += "[table=2]"
	for g in PlayerOps.STAT_GROUPS:
		var parts: Array = []
		for i in g["stats"]:
			var idx: = int(i)
			var v: Array = PlayerOps.pstat(w, idx)
			var nm: = ("★" if idx == strong else "") + PlayerOps.pstat_name(idx) + ("•" if idx < Defs.N_STATS and p.in_focus(idx) else "")
			parts.append("%s %s/%s" % [_stat_bb(nm), UIKit.col(str(roundi(v[0])), UIKit.grade_color(float(v[0]))), UIKit.col(str(roundi(v[1])), UIKit.grade_color(float(v[1])))])
		s += "[cell]%s   [/cell][cell]%s[/cell]" % [UIKit.col("[b]%s[/b]" % str(g["name"]).to_upper(), UIKit.GOLD), "   ".join(parts)]
	s += "[/table]\n" + UIKit.col("★ sở trường · • đang tu dưỡng · thực / tiềm năng. Tác dụng từng chỉ số: Chi tiết…", UIKit.DIM) + "\n"
	return s


func _stat_groups_text() -> String:
	var p: = w.player()
	var strong: = PlayerOps.strength_stat(w)
	var sug: = PlayerOps.train_suggestion(w)
	var effects: = PlayerOps.stat_effects(w)
	var sv: Array = PlayerOps.pstat(w, strong)
	var s: = "Sở trường: %s %s · " % [UIKit.col("★ " + PlayerOps.pstat_name(strong), UIKit.GOLD), UIKit.col("(tiềm năng %d, %s)" % [roundi(sv[1]), Defs.grade(float(sv[1]))], UIKit.DIM)]
	s += "Nên tu dưỡng: %s\n\n" % (UIKit.col(PlayerOps.pstat_name(sug), UIKit.GREEN) if sug >= 0 else UIKit.col("các chỉ số đã gần trần", UIKit.DIM))
	s += "[table=3]"
	s += "[cell]%s   [/cell][cell]%s   [/cell][cell]%s[/cell]" % [UIKit.col("Chỉ số", UIKit.DIM), _tip(UIKit.col("Thực / TN", UIKit.DIM), HEAD_TIP["Thực / TN"]), UIKit.col("Đang giúp gì", UIKit.DIM)]
	for g in PlayerOps.STAT_GROUPS:
		var best: = -1
		for i in g["stats"]:
			if best < 0 or float(PlayerOps.pstat(w, int(i))[1]) > float(PlayerOps.pstat(w, best)[1]):
				best = int(i)
		var bv: Array = PlayerOps.pstat(w, best)
		s += "[cell] [/cell][cell] [/cell][cell] [/cell]"
		s += "[cell]%s[/cell][cell]%s[/cell][cell]%s[/cell]" % [UIKit.col("[b]%s[/b]" % str(g["name"]).to_upper(), UIKit.GOLD), 
			UIKit.col(Defs.grade(float(bv[1])) + "   ", UIKit.grade_color(float(bv[1]))), UIKit.col("[font_size=13]%s[/font_size]" % g["use"], UIKit.DIM)]
		for i in g["stats"]:
			var idx: = int(i)
			var v: Array = PlayerOps.pstat(w, idx)
			var nm: = PlayerOps.pstat_name(idx)
			if idx == strong:
				nm = "★ " + nm
			if idx < Defs.N_STATS and p.in_focus(idx):
				nm += " •"
			s += "[cell]  %s   [/cell][cell]%s / %s   [/cell][cell]%s[/cell]" % [_stat_bb(nm), 
				UIKit.col(str(roundi(v[0])), UIKit.grade_color(float(v[0]))), UIKit.col(str(roundi(v[1])), UIKit.grade_color(float(v[1]))), 
				UIKit.col("[font_size=13]%s[/font_size]" % effects[idx][1], UIKit.DIM)]
	s += "[/table]\n" + UIKit.col("★ sở trường của Mệnh cách · • đang tu dưỡng · Thực / TN = chỉ số thực / tiềm năng", UIKit.DIM) + "\n"
	return s


func _detail_lead(c: Character) -> void :
	var lead: Dictionary = {}
	for l in w.play["leads"]:
		if str(l["id"]) == c.id:
			lead = l
	if lead.is_empty():
		sel = "self"
		_detail_self()
		return
	var s: = "[font_size=20]%s[/font_size]\n\n" % UIKit.col("Manh mối", UIKit.GOLD)
	s += "❝ %s ❞\n\n" % str(lead["text"])
	s += UIKit.col("Nghe được ở %s, %s. Lời đồn có thể đúng, có thể phóng đại. Gặp mặt để biết là ai, rồi dùng Đôi Mắt để thẩm định." % [w.city_name(str(lead["city"])), World.date_of(int(lead["m"]))], UIKit.DIM)
	detail_txt.text = s
	var here: = str(lead["city"]) == PlayerOps.here(w)
	if here:
		detail_txt.text += "\n" + UIKit.col("Khả năng không tìm ra người: ~%d%% (lời đồn càng cũ càng khó tìm; Trí lực cao thì dễ hơn)." % roundi(PlayerOps.lead_miss_chance(w, lead) * 100.0), UIKit.DIM)
	_act("Tìm gặp" + _d("meet"), func() -> void : _meet_lead(c.id), here, "" if here else "Phải ở %s" % w.city_name(str(lead["city"])))


func _detail_npc(c: Character) -> void :
	var met: = PlayerOps.met_now(w, c)
	var ret: = PlayerOps.is_retainer(w, c)
	var s: = _npc_summary(c)
	detail_txt.text = s
	if not c.alive:
		_act("Bỏ lưu tâm" if PlayerOps.is_starred(w, c.id) else "★ Lưu tâm", func() -> void : _do(PlayerOps.toggle_star(w, c.id)))
		return

	var starred: = PlayerOps.is_starred(w, c.id)
	var sb: = _act("Bỏ lưu tâm" if starred else "★ Lưu tâm", func() -> void : _do(PlayerOps.toggle_star(w, c.id)), true, 
		"Ghim người này lên đầu Sổ nhân vật; khi ở cùng thành, bạn sẽ hay tin biến động của họ (không tốn ngày)")
	if not starred:
		sb.add_theme_color_override("font_color", UIKit.GOLD)
	var here: = c.city_id == PlayerOps.here(w)
	if not ret and not here:
		var pb: = PlayerOps.probe_block(w, c)
		_more("Thăm dò…", func() -> void : _probe_modal(c), pb == "", pb if pb != "" else "Cử người đi dò tin (tốn ngân lượng, không tốn ngày)")
	if not ret and not met:
		_act("Gặp gỡ" + _d("meet"), func() -> void : _do(PlayerOps.meet(w, c.id)), here, "" if here else "Phải đến %s" % w.city_name(c.city_id))
	if not ret and w.notebook.has(c.id) and int(w.notebook[c.id].get("met_m", -99)) >= 0:
		var vb: = PlayerOps.visit_block(w, c)
		_act("Thăm hỏi…" + _d("visit"), func() -> void : _visit_modal(c), vb == "", 
			vb if vb != "" else "Ghé thăm, có thể kèm lễ vật: tăng ân tình (tối đa %d), giúp chiêu mộ dễ hơn. Cũng tính là gặp mặt trong tháng." % int(PlayerOps.VISIT_CAP))
	more_title = "Việc khác với %s" % c.name
	if not ret and w.notebook.has(c.id) and int(w.notebook[c.id].get("met_m", -99)) >= 0:
		var ob: = Daily.observe_block(w, c)
		_act("Quan sát kỹ" + _d("observe"), func() -> void : _do_pop(Daily.observe(w, c.id), "Quan sát %s" % c.name), ob == "", 
			ob if ob != "" else "Không tốn Nhãn lực: theo dõi, dò hỏi hàng xóm, thu hẹp khoảng Ấn tượng của một chỉ số (Trí lực cao thì hẹp hơn); đôi khi nghe được gợi ý về ngộ tính, sở trường, tính cách")
		var chb: = Daily.chat_block(w, c)
		_more("Đàm đạo" + _d("chat"), func() -> void : _do_pop(Daily.chat(w, c.id), "Đàm đạo với %s" % c.name), chb == "", 
			chb if chb != "" else "Uống trà, đánh cờ: ân tình tăng ít (không tốn tiền), kèm thấy thêm một chỉ số như Quan sát kỹ")
	var et: = PlayerOps.eye_tier(w)
	eye_line.visible = true
	eye_head.text = "Thẩm định\n%d NL" % int(w.play["eye"])
	for t in range(1, et + 1):
		var cost: int = Defs.TIER_COST[t]
		var tier: int = t
		var again: = PlayerOps.appraise_redundant(w, c, tier)
		var b: = UIKit.button("%s · %d" % [Defs.TIER_NAMES[t], cost], func() -> void : _do(PlayerOps.appraise(w, c.id, tier)), 
			again if again != "" else "Thẩm định tầng %s, tốn %d Nhãn lực (không tốn ngày)" % [Defs.TIER_NAMES[t], cost])
		b.disabled = again != "" or not ((met or ret) and int(w.play["eye"]) >= cost)
		eye_box.add_child(b)
	if et < 4:
		var lk: = UIKit.label("%s: cần %d Ngộ đạo" % [Defs.TIER_NAMES[et + 1], int(PlayerOps.TIER_UNLOCK[et + 1])], 13, UIKit.DIM)
		lk.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		eye_box.add_child(lk)
	var rb: = PlayerOps.recruit_block(w, c)
	if not ret:
		_act(("Lôi kéo" if c.patron != "" else "Chiêu mộ") + _d("recruit"), func() -> void : _recruit_modal(c), rb == "", rb)
	if c.alive and not ret and not Rivals.plots_for(w, c, "").is_empty():
		_more("Âm mưu…", func() -> void : _plot_modal(c, ""), true, "Thổi phồng, vu cáo, ám sát, hạ độc")
	var cb: = PlayerOps.recommend_block(w, c)
	_act("Tiến cử" + _d("recommend"), func() -> void : _recommend_modal(c), cb == "", cb)
	if c.office_key != "" and c.recommender != w.player_id and w.notebook.get(c.id, {}).has("appr"):
		var eb: = Repute.expose_block(w, c)
		_more("Vạch trần…" + _d("expose"), func() -> void : _expose_modal(c), eb == "", 
			eb if eb != "" else ("Bạn là quan lớn hơn: hặc tấu thẳng, có thể đề cử người thay." if Repute.outranks(w, c) else "Dâng sớ chỉ ra người này bất tài (Danh vọng ≥ %d). Đúng thì họ mất chức; sai thì bạn mang tiếng vu khống." % int(Repute.EXPOSE_PRESTIGE)) + " Kết quả có sau vài ngày thẩm tra.")
	if c.office_key == "" and (ret or met):
		var sb2: = Repute.show_block(w, c)
		_more("Thi tài" + _d("showcase"), func() -> void : _do_pop(Repute.showcase(w, c.id), "Thi tài: %s" % c.name), sb2 == "", 
			sb2 if sb2 != "" else "Tổ chức cho %s trổ tài trước quan lại kinh thành (%d lượng, Danh vọng ≥ %d): người tài thật sẽ được triều đình nhìn đúng, danh tiếng tăng mạnh." % [c.name, Repute.SHOW_COST, int(Repute.SHOW_PRESTIGE)])
	if not c.crisis.is_empty() and (met or ret):
		_act("Khuyên nhủ…" + _d("counsel"), func() -> void : _counsel_modal(c), true)
	if c.office_key == "" and c.patron == "" and w.notebook.has(c.id) and int(w.notebook[c.id].get("met_m", -99)) >= 0:
		var kb: = PlayerOps.career_block(w, c)
		_more("Khuyên đổi nghề…" + _d("career"), func() -> void : _career_modal(c), kb == "", 
			kb if kb != "" else "Khuyên người này theo nghề hợp tiềm năng (hướng tu dưỡng mới). Có thể bị từ chối, hoặc vài tháng sau bỏ dở.")
	if ret:
		_act("Đào tạo…", func() -> void : _study_modal(c), true, "Cho đi học: Quân doanh, Học viện, Thương hội, Công xưởng, Giao du văn đàn")
		_act("Giao việc…", func() -> void : _assign_modal(c), true, "Làm việc cho gia tộc: kinh doanh, quản gia, hộ vệ, thuyết khách, mật thám, dạy dỗ")
		var lc: = PlayerOps.loc(w, c)
		if (str(lc.get("st", "")) == "house" or str(lc.get("st", "")) == "inn") and str(lc["city"]) == PlayerOps.here(w):
			_act("Theo hầu", func() -> void : _do(PlayerOps.take_along(w, c.id)), PlayerOps.follow_count(w) < PlayerOps.follow_cap(w), 
				"Đi theo bạn (%d / %d chỗ theo hầu). Hộ vệ, Thuyết khách chỉ có tác dụng khi theo hầu; việc rèn ở tư trạch sẽ tạm ngưng." % [PlayerOps.follow_count(w), PlayerOps.follow_cap(w)])
		if (str(lc.get("st", "")) == "follow" or str(lc.get("st", "")) == "inn") and PlayerOps.house_cap(w, PlayerOps.here(w)) > 0 and str(lc.get("city", PlayerOps.here(w))) == PlayerOps.here(w):
			var full: = PlayerOps.house_count(w, PlayerOps.here(w)) >= PlayerOps.house_cap(w, PlayerOps.here(w))
			_act("Để lại tư trạch", func() -> void : _do(PlayerOps.leave_here(w, c.id)), not full, 
				"Tư trạch ở đây đã đầy" if full else "Ở lại tư trạch %s để làm việc được giao" % w.city_name(PlayerOps.here(w)))
		if not PlayerOps.on_road(w, c):
			_more("Điều đi…", func() -> void : _send_modal(c), true, "Gửi thư điều tới thành khác (thư đi + đường đi; bạn không mất ngày). Không có tư trạch thì ở trọ chờ bạn %d ngày." % PlayerOps.INN_DAYS)
		var tb: = Daily.tutor_block(w, c)
		_more("Tự tay chỉ dạy" + _d("tutor"), func() -> void : _do_pop(Daily.tutor(w, c.id), "Chỉ dạy %s" % c.name), tb == "", 
			tb if tb != "" else "Bạn kèm %s 2 tháng ở chỉ số họ đang rèn (như thầy giỏi), Trung thành +3" % c.name)
		_more("Trang bị…", func() -> void : _items_modal(c.id), true, "Cho môn khách dùng đồ trong kho gia tộc")
		_more("Tiền bạc…", func() -> void : _purse_modal(c), true, "Túi riêng %d lượng: ban thưởng, vay, trả nợ, bày cớ thu tiền" % roundi(c.purse))
		_more("Dự thi: có (bấm để thôi)" if PlayerOps.exam_flag(w, c.id) else "Cho đi thi", func() -> void : _do(PlayerOps.toggle_exam(w, c.id)), true, 
			"Dự Khoa cử (tháng 3) và Võ cử (tháng 9). Đỗ đạt thì danh tiếng vang dội, nhưng triều đình sẽ muốn giành người.")
		var sk: = PlayerOps.seek_block(w, c)
		_more("Tìm danh sư" + _d("seek_master"), func() -> void : _do_pop(PlayerOps.seek_master(w, c.id), "Tìm danh sư cho %s" % c.name), sk == "", 
			sk if sk != "" else "Tốn %d lượng: ~%d%% tìm được thầy giỏi dạy 12 tháng (×1,6), có khi được chân truyền; còn lại là gặp kẻ bịp." % [PlayerOps.SEEK_COST, roundi(PlayerOps.seek_chance(w) * 100.0)])
		_more("Cho rời đi", func() -> void :
			var r: = PlayerOps.dismiss(w, c.id)
			_do_pop(r, "Cho %s rời đi" % c.name), true, "%s rời gia tộc (Trung thành −20, đồ của gia tộc trả về kho)" % c.name)


const ROLE_ENV: = {"tuong": "Quân doanh", "ho_ve": "Quân doanh", "quan_su": "Học viện", "quan_van": "Học viện", "thuong_nhan": "Thương hội", "cong_tuong": "Công xưởng"}


func _branch_text(c: Character, rec: Dictionary) -> String:
	var s: = ""
	if PlayerOps.has_branch(w, "phan_tich"):
		var fit: = PlayerOps.role_fit(rec)
		var parts: Array = []
		for k in mini(3, fit.size()):
			var f: Dictionary = fit[k]
			var fut: = "" if float(f["phi"]) < 0.0 else ", tối đa %d–%d" % [roundi(f["plo"]), roundi(f["phi"])]
			parts.append("%s %d–%d%s" % [Defs.ROLES[f["role"]]["name"], roundi(f["lo"]), roundi(f["hi"]), fut])
		s += "\n" + UIKit.col("Phân tích: ", UIKit.GREEN) + " · ".join(parts) + ". Nên rèn ở %s.\n" % ROLE_ENV[str(fit[0]["role"])]
	if PlayerOps.has_branch(w, "du_doan"):
		var p5: = PlayerOps.project_from_record(w, c, rec, 60)
		var p10: = PlayerOps.project_from_record(w, c, rec, 120)
		var order: Array = [0, 1, 2, 3, 4, 5]
		order.sort_custom( func(a: int, b: int) -> bool: return float(p10[a]) > float(p10[b]))
		var parts2: Array = []
		for k in 3:
			var i: int = order[k]
			var rb: Array = rec["real"][i]
			parts2.append("%s %d → %d → %d" % [Defs.STAT_SHORT[i], roundi((float(rb[0]) + float(rb[1])) / 2.0), roundi(p5[i]), roundi(p10[i])])
		s += UIKit.col("Dự đoán (nay → 5 năm → 10 năm, nếu giữ nếp sống hiện tại): ", UIKit.GREEN) + " · ".join(parts2) + "\n"
	if PlayerOps.has_branch(w, "nhan_qua") and int(rec["tier"]) >= 2:
		var lg: = PlayerOps.causal_log(c)
		s += UIKit.col("Nhân quả:", UIKit.GREEN) + (" chưa có biến đổi nào.\n" if lg.is_empty() else "\n")
		for k in range(maxi(0, lg.size() - 6), lg.size()):
			s += UIKit.col("   %s: %s\n" % [World.date_of(int(lg[k]["m"])), lg[k]["t"]], UIKit.DIM)
	return s



func _conditions(c: Character) -> String:
	var s: = ""
	if not PlayerOps.is_retainer(w, c):
		var rb: = PlayerOps.recruit_block(w, c)
		s += "%s %s\n" % [UIKit.col("Chiêu mộ:", UIKit.DIM), UIKit.col("được", UIKit.GREEN) if rb == "" else UIKit.col(rb, UIKit.DIM)]
	var cb: = PlayerOps.recommend_block(w, c)
	s += "%s %s\n" % [UIKit.col("Tiến cử:", UIKit.DIM), UIKit.col("được", UIKit.GREEN) if cb == "" else UIKit.col(cb, UIKit.DIM)]
	return s




func _recruit_modal(c: Character) -> void :
	var body: = UIKit.modal(self, "Chiêu mộ %s" % c.name, 700)
	var rec: Dictionary = w.notebook.get(c.id, {}).get("appr", {})
	var exact: = rec.has("traits")
	body.add_child(UIKit.wrap_label("Lễ vật và lương tính theo những gì thiên hạ thấy ở người này. Thiện chí phải đạt khoảng 50 (±10 tùy may rủi) thì họ mới nhận lời.", 14, UIKit.DIM))
	var fs: = PlayerOps.free_slot(w)
	body.add_child(UIKit.label("Nhận lời thì sẽ %s." % ("ở tư trạch %s" % w.city_name(PlayerOps.here(w)) if fs == "house" else "theo hầu bạn (tư trạch ở đây không còn chỗ)"), 14, UIKit.GOLD))

	var base: = PlayerOps.recruit_preview(w, c, false)
	var lines: = "%s\n" % UIKit.col("Thiện chí của %s" % c.name, UIKit.GOLD)
	var rows: Array = [_factor_row(PlayerOps.RECRUIT_BASE, "Nền")]
	var hid_sum: = 0.0
	for x in PlayerOps.recruit_factors(w, c, false):
		if bool(x["hid"]) and not exact:
			hid_sum += float(x["v"])
		elif absf(float(x["v"])) >= 0.5:
			rows.append(_factor_row(float(x["v"]), str(x["t"])))
	if not exact:
		rows.append([UIKit.col("?", UIKit.DIM), UIKit.col("Tính cách, chí hướng của họ (thẩm định tầng Cao cấp để biết)", UIKit.DIM)])
	lines += "[table=2]"
	for r in rows:
		lines += "[cell]%s    [/cell][cell]%s[/cell]" % r
	lines += "[/table]\n"
	if not exact:
		var known: = float(base["score"]) - hid_sum
		lines += "Phần bạn biết: %s · cần ~50" % UIKit.col("%d" % roundi(known), UIKit.GREEN if known >= 50.0 else UIKit.RED)
	else:
		var sc: = float(base["score"])
		lines += "Tổng: %s · cần ~50" % UIKit.col("%d" % roundi(sc), UIKit.GREEN if sc >= 50.0 else UIKit.RED)
	var tb: = UIKit.rich(true)
	tb.text = lines
	body.add_child(UIKit.panel(tb, UIKit.PANEL, 10))

	for lavish in [false, true]:
		var pr: = PlayerOps.recruit_preview(w, c, lavish)
		var row: = UIKit.hbox(12)
		var txt: = UIKit.rich(true)
		txt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var chance: = "%s%s" % [PlayerOps.chance_words(float(pr["chance"])), " (~%d%%)" % roundi(float(pr["chance"]) * 100.0) if exact else ""]
		var extra: = ""
		if lavish:
			var d: = float(pr["score"]) - float(base["score"])
			extra = " · thiện chí +%d" % roundi(d if exact else 15.0)
		txt.text = "%s%s\nLễ vật %s lượng · lương %d/tháng · %s" % [UIKit.col("Hậu đãi" if lavish else "Đãi ngộ thường", UIKit.GOLD), UIKit.col(extra, UIKit.DIM), UIKit.col(str(pr["fee"]), UIKit.GOLD), int(pr["salary"]), chance]
		row.add_child(txt)
		var lv: bool = lavish
		var b: = UIKit.button("Mời", func() -> void :
			UIKit.close_modal(body)
			var rr: = PlayerOps.recruit(w, c.id, lv)
			_do(rr)
			if rr["ok"] and str(w.play["over"]) == "":
				_recruit_result(c, rr))
		b.disabled = PlayerOps.money(w) < float(pr["fee"])
		row.add_child(b)
		body.add_child(UIKit.panel(row, UIKit.PANEL, 10))
	if float(PlayerOps.recruit_preview(w, c, true)["chance"]) < 0.35:
		body.add_child(UIKit.wrap_label("Cách nâng thiện chí: Thăm hỏi nhiều lần (ân tình +, người ẩn dật cần 3 lần), giao môn khách Mị cao việc Thuyết khách, nâng Gia thế, hoặc đợi họ bớt danh tiếng / tham vọng.", 13, UIKit.DIM))



func _items_modal(who: String) -> void :
	var tgt: = w.ch(who)
	if not Items.can_dress(w, tgt):
		tgt = w.player()
	var body: = UIKit.modal(self, "Kho đồ %s" % w.clan["name"], 780)
	var again: = func(r: Dictionary) -> void :
		UIKit.close_modal(body)
		_do(r)
		_items_modal(tgt.id)
	body.add_child(UIKit.wrap_label("Đồ chỉ cộng chỉ số hiệu lực khi đang dùng. Y phục đẹp giúp cả ấn tượng với triều đình: người Mị lực thấp mặc áo gấm đỡ bị chê.", 14, UIKit.DIM))
	var scroll: = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(740, 560)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var list: = UIKit.vbox(6)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)

	var who_row: = HFlowContainer.new()
	who_row.add_theme_constant_override("h_separation", 6)
	who_row.add_child(UIKit.label("Trang bị cho:", 14, UIKit.DIM))
	var people: Array = [w.player()] + PlayerOps.retainers(w)
	for pc: Character in people:
		var pid: = pc.id
		var bb: = UIKit.button("Bạn" if pc.is_player else pc.name, func() -> void :
			UIKit.close_modal(body)
			_items_modal(pid))
		if pid == tgt.id:
			bb.add_theme_color_override("font_color", UIKit.GOLD)
		who_row.add_child(bb)
	list.add_child(who_row)

	list.add_child(UIKit.label("Đang dùng: %s" % ("bạn" if tgt.is_player else tgt.name), 16, UIKit.GOLD))
	for k in Items.KINDS:
		var kind: String = k
		var row: = UIKit.hbox(10)
		var lb: = UIKit.label(str(Items.KIND[kind]["name"]), 14, UIKit.DIM)
		lb.custom_minimum_size.x = 90
		row.add_child(lb)
		var q: = Items.gear_q(tgt, kind)
		row.add_child(UIKit.label("%s · %s" % [Items.name_of(kind, q), Items.effect_text(kind, q)] if q > 0 else "—", 14, UIKit.TEXT if q > 0 else UIKit.DIM))
		row.add_child(UIKit.spacer())
		if q > 0:
			row.add_child(UIKit.button("Cất vào kho", func() -> void : again.call(Items.unequip(w, tgt.id, kind))))
		list.add_child(row)

	var st: = Items.store(w)
	var mq: = Items.market_q(w)
	list.add_child(UIKit.label("Kho: %d / %d món" % [st.size(), Items.STORE_CAP], 16, UIKit.GOLD))
	if st.is_empty():
		list.add_child(UIKit.label("Trống. Chế tác ở xưởng hoặc mua ở chợ.", 14, UIKit.DIM))
	for it in st:
		var uid: = int(it["uid"])
		var kd: = str(it["k"])
		var qq: = int(it["q"])
		var row: = UIKit.hbox(10)
		var nm: = UIKit.label(Items.name_of(kd, qq), 14, UIKit.TEXT)
		nm.custom_minimum_size.x = 170
		row.add_child(nm)
		row.add_child(UIKit.label("%s · %s" % [Items.Q_NAMES[qq], Items.effect_text(kd, qq)], 13, UIKit.DIM))
		row.add_child(UIKit.spacer())
		row.add_child(UIKit.button("Dùng", func() -> void : again.call(Items.equip(w, uid, tgt.id)), 
			"Trang bị cho %s" % ("bạn" if tgt.is_player else tgt.name)))
		var sb: = UIKit.button("Bán %d" % Items.sell_price(kd, qq), func() -> void : again.call(Items.sell(w, uid)), 
			"Bán ở chợ (thành Kinh tế ≥ %d)" % int(Items.MARKET_KT))
		sb.disabled = mq == 0
		row.add_child(sb)
		list.add_child(row)

	var cr: = Items.crafter(w)
	var od: = Items.craft_odds(w)
	var cb: = Items.craft_block(w)
	list.add_child(UIKit.label("Chế tác (%d ngày, mỗi xưởng 1 món / tháng)" % PlayerOps.act_days(w, "craft"), 16, UIKit.GOLD))
	var ct: = UIKit.rich(true)
	ct.text = "Thợ giỏi nhất: %s, Sản xuất %d. Ra phẩm: Thường %d%% · Tốt %d%% · Tinh xảo %d%%. %s" % [cr[1], roundi(float(cr[0])), roundi(float(od[1]) * 100.0), roundi(float(od[2]) * 100.0), roundi(float(od[3]) * 100.0), 
		UIKit.col(cb, UIKit.RED) if cb != "" else UIKit.col("Còn %d lượt tháng này." % Items.crafts_left(w), UIKit.GREEN)]
	list.add_child(ct)
	list.add_child(UIKit.wrap_label("Sản xuất ≥ 50 bắt đầu ra đồ Tốt, ≥ 80 ra đồ Tinh xảo. Giao môn khách giỏi Sản xuất việc Công xưởng để họ cầm chính.", 13, UIKit.DIM))
	var crow: = HFlowContainer.new()
	crow.add_theme_constant_override("h_separation", 6)
	for k in Items.KINDS:
		var kind: String = k
		var cost: = Items.craft_cost(kind)
		var b: = UIKit.button("Làm %s · %d lượng" % [str(Items.KIND[kind]["name"]).to_lower(), cost], func() -> void : again.call(Items.craft(w, kind)))
		b.disabled = cb != "" or PlayerOps.money(w) < float(cost)
		crow.add_child(b)
	list.add_child(crow)

	list.add_child(UIKit.label("Chợ %s" % w.city_name(PlayerOps.here(w)), 16, UIKit.GOLD))
	if mq == 0:
		list.add_child(UIKit.label("Thành này không có chợ lớn (cần Kinh tế ≥ %d)." % int(Items.MARKET_KT), 14, UIKit.DIM))
	else:
		var mrow: = HFlowContainer.new()
		mrow.add_theme_constant_override("h_separation", 6)
		for k in Items.KINDS:
			for q in range(1, mq + 1):
				var kind: String = k
				var qb: int = q
				var pr: = Items.price(kind, qb)
				var b: = UIKit.button("%s · %d" % [Items.name_of(kind, qb), pr], func() -> void : again.call(Items.buy(w, kind, qb)), 
					"%s, phẩm %s: %s" % [Items.KIND[kind]["name"], Items.Q_NAMES[qb], Items.effect_text(kind, qb)])
				b.disabled = PlayerOps.money(w) < float(pr) or st.size() >= Items.STORE_CAP
				mrow.add_child(b)
		list.add_child(mrow)




func _world_map_modal(view: String = "") -> void :
	var body: = UIKit.modal(self, "Bản đồ thế giới", 1240)
	var tabs_row: = UIKit.hbox(6)
	var views: Array = [["", "Thiên hạ"]]
	for nd in GameData.world_def()["nations"]:
		views.append([str(nd["id"]), "Vùng " + str(nd["name"])])
	for v in views:
		var vid: String = v[0]
		var b: = UIKit.button(str(v[1]), func() -> void :
			UIKit.close_modal(body)
			_world_map_modal(vid))
		if vid == view:
			b.add_theme_color_override("font_color", UIKit.GOLD)
		tabs_row.add_child(b)
	body.add_child(tabs_row)
	var mv: Control = MapView.new()
	mv.setup(w)
	mv.big = true
	mv.mode = "world" if view == "" else "region"
	mv.region = view
	mv.custom_minimum_size = Vector2(1200, 700)
	body.add_child(UIKit.panel(mv, UIKit.PANEL, 4))
	mv.city_pressed.connect( func(id: String) -> void :
		UIKit.close_modal(body)
		_on_city(id))



func _send_modal(c: Character) -> void :
	var body: = UIKit.modal(self, "Điều %s đi" % c.name, 700)
	body.add_child(UIKit.wrap_label("Bạn gửi thư (đi theo đường, nhanh gấp đôi nếu gửi từ thành có Trạm dịch), %s nhận thư rồi lên đường; bạn không mất ngày. Nơi có tư trạch còn chỗ thì vào ở. Nơi khác thì ở trọ chờ bạn %d ngày (%d lượng, trả trước): bạn tới kịp thì gọi theo hầu hoặc tiến cử được; quá hạn không gặp thì thất vọng (Trung thành −%d) và quay về. Hiện %s." % [c.name, PlayerOps.INN_DAYS, PlayerOps.inn_cost(), int(PlayerOps.LETDOWN_LOYALTY), PlayerOps.loc_text(w, c)], 14, UIKit.DIM))
	var scroll: = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(660, 480)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var list: = UIKit.vbox(4)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	var order: Array = PlayerOps.houses(w).keys()
	var others: Array = []
	for cid in w.cities:
		if not order.has(cid):
			others.append(cid)
	others.sort_custom( func(a: String, b: String) -> bool: return PlayerOps.path_days(w, PlayerOps.here(w), a) < PlayerOps.path_days(w, PlayerOps.here(w), b))
	for to in order + others:
		var blk: = PlayerOps.send_block(w, c, str(to))
		if blk.ends_with("rồi."):
			continue
		var row: = UIKit.hbox(10)
		var txt: = UIKit.rich(true)
		txt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var sd: = PlayerOps.send_days(w, c, str(to))
		var inn: = PlayerOps.sends_to_inn(w, str(to))
		var where: = ("tư trạch %d/%d" % [PlayerOps.house_count(w, str(to)), PlayerOps.house_cap(w, str(to))]) if not inn else ("ở trọ %d lượng" % PlayerOps.inn_cost() + (" (tư trạch đầy)" if PlayerOps.house_cap(w, str(to)) > 0 else ""))
		txt.text = "%s  %s" % [UIKit.col(w.city_name(str(to)), UIKit.GOLD if not inn else UIKit.TEXT), UIKit.col("thư %d + đường %d ngày · %s" % [int(sd[0]), int(sd[1]), where], UIKit.DIM) + (UIKit.col("  " + blk, UIKit.RED) if blk != "" else "")]
		row.add_child(txt)
		var dest: String = to
		var b: = UIKit.button("Điều tới", func() -> void :
			UIKit.close_modal(body)
			_do(PlayerOps.send(w, c.id, dest)))
		b.disabled = blk != ""
		row.add_child(b)
		list.add_child(row)




func _clans_tab() -> void :
	clan_tree.clear()
	var root: = clan_tree.create_item()
	for rid in w.rivals:
		var rv: Dictionary = w.rivals[rid]
		var it: = clan_tree.create_item(root)
		var nmem: = Rivals.members(w, rv).size()
		var fallen: = Rivals.is_fallen(rv)
		var cells: Array = [str(rv["name"]), w.nation_name(str(rv["nation"])) if w.nations.has(str(rv["nation"])) else "(mất nước)", w.city_name(str(rv["city"])), 
			"Đã sụp đổ" if fallen else PlayerOps.CLAN_TIER_NAMES[clampi(int(rv["tier"]), 1, 5)], "—" if fallen else "%s %+d" % [Rivals.stance(rv), roundi(float(rv["rel"]))], 
			str(Rivals.officials(w, str(rid)).size()), str(nmem) if int(rv.get("spy", 0)) > 0 else "?"]
		for i in cells.size():
			it.set_text(i, str(cells[i]))
		it.set_metadata(0, "clan:" + str(rid))
		if fallen:
			for i in cells.size():
				it.set_custom_color(i, UIKit.DIM)
			continue
		var st: = Rivals.stance(rv)
		it.set_custom_color(4, UIKit.GREEN if st == "Liên minh" or st == "Thông gia" else (UIKit.RED if st == "Thù địch" else UIKit.DIM))
		if sel == "clan:" + str(rid):
			it.select(0)


func _detail_clan(rid: String) -> void :
	var rv: Dictionary = w.rivals[rid]
	var head: = Rivals.head_of(w, rv)
	var s: = "[font_size=22]%s[/font_size]  %s\n" % [UIKit.col(str(rv["name"]), UIKit.GOLD), UIKit.col("%s · quê %s" % [w.nation_name(str(rv["nation"])), w.city_name(str(rv["city"]))], UIKit.DIM)]
	s += UIKit.col(str(rv.get("desc", "")), UIKit.DIM) + "\n\n"
	if Rivals.is_fallen(rv):
		s += UIKit.col("Đã sụp đổ %s: %s." % [World.date_of(int(rv.get("fall_m", 0))), rv["fallen"]], UIKit.RED) + "\n"
		detail_txt.text = s
		return
	if str(rv.get("past_fall", "")) != "":
		s += UIKit.col("Thiên Thư: ở kiếp trước nhà này sụp đổ vì %s." % rv["past_fall"], UIKit.PURPLE) + "\n"
	s += UIKit.col("Thu ~%d · chi ~%d lượng/tháng%s" % [roundi(Rivals.income(w, rv)), roundi(Rivals.expense(w, rv)), " · đang nợ %d tháng" % int(rv.get("broke_m", 0)) if int(rv.get("broke_m", 0)) > 0 else ""], UIKit.DIM) + "\n" if int(rv.get("spy", 0)) > 0 else ""
	if Rivals.known_kind(rv):
		var kd: Dictionary = Rivals.KINDS[str(rv["kind"])]
		s += "%s: %s\n" % [UIKit.col(str(kd["name"]), UIKit.PURPLE), kd["desc"]]
	else:
		s += UIKit.col("Chưa rõ là hạng nhà nào (bái phỏng hoặc cài nội gián để biết).", UIKit.DIM) + "\n"
	var st: = Rivals.stance(rv)
	s += "Quan hệ với bạn: %s\n" % UIKit.col("%s (%+d)" % [st, roundi(float(rv["rel"]))], UIKit.GREEN if st == "Liên minh" or st == "Thông gia" else (UIKit.RED if st == "Thù địch" else UIKit.TEXT))
	s += "Gia thế %s · Danh vọng %d\n" % [PlayerOps.CLAN_TIER_NAMES[clampi(int(rv["tier"]), 1, 5)], roundi(float(rv["prestige"]))]
	if head != null:
		s += "Gia chủ: %s%s\n" % [head.name, "" if head.alive else UIKit.col(" (đã mất)", UIKit.RED)]
	if int(rv.get("spy", 0)) > 0:
		s += UIKit.col("Nội gián của bạn còn ở đây %d tháng: mọi âm mưu họ nhắm vào bạn dễ bị phát hiện hơn." % int(rv["spy"]), UIKit.BLUE) + "\n"
	var offs: = Rivals.officials(w, rid)
	s += "\n" + UIKit.col("Người của họ trong triều (%d)" % offs.size(), UIKit.GOLD) + "\n"
	for c: Character in offs:
		s += "  %s · %s\n" % [c.name, Appointment.office_label_of(w, c)]
	var mem: = Rivals.members(w, rv)
	s += "\n" + UIKit.col("Môn khách", UIKit.GOLD) + "\n"
	var shown: = 0
	for c: Character in mem:
		if int(rv.get("spy", 0)) > 0 or c.fame >= 40.0 or w.notebook.has(c.id):
			s += "  %s · %s · %s\n" % [c.name, Defs.prof_name(c.profession), w.city_name(c.city_id)]
			shown += 1
	if shown < mem.size():
		s += UIKit.col("  … và những người bạn chưa biết (cài nội gián để thấy hết).", UIKit.DIM) + "\n"
	var strong: = Rivals.strongest(w)
	if str(strong[0]) == rid and int(strong[1]) > 0:
		s += "\n" + UIKit.col("Thế gia nắm nhiều ghế chủ chốt nhất thiên hạ (%d / %d)." % [int(strong[1]), int(strong[2])], UIKit.RED) + "\n"
	detail_txt.text = s
	var vb: = Rivals.visit_block(w, rv)
	_act("Bái phỏng…", func() -> void : _clan_visit_modal(rid), vb == "", vb if vb != "" else "Ghé thăm gia chủ, có thể kèm lễ: quan hệ tăng, biết họ là hạng nhà nào (%d ngày)" % Rivals.VISIT_DAYS)
	if not bool(rv.get("kin", false)):
		var mb: = Rivals.marry_block(w, rv)
		_act("Kết thông gia · %d" % Rivals.KIN_COST, func() -> void : _do(Rivals.marry(w, rid)), mb == "", 
			mb if mb != "" else "Đồng minh vĩnh viễn; người họ tiến cử tính là người của bạn cho các kết thúc")
	_act("Âm mưu…", func() -> void : _plot_modal(null, rid), true, "Cài nội gián; có nội gián rồi thì Tố giác mưu phản (tịch biên cả nhà)")
	if head != null and head.alive:
		var hid: = head.id
		_act("Xem gia chủ", func() -> void : select("npc:" + hid))


func _clan_visit_modal(rid: String) -> void :
	var rv: Dictionary = w.rivals[rid]
	var body: = UIKit.modal(self, "Bái phỏng %s" % rv["name"], 600)
	body.add_child(UIKit.wrap_label("Quan hệ hiện %+d (%s). Từ 50 là liên minh: họ báo tin người tài, nói đỡ khi bạn tiến cử ở %s, không lôi kéo hay hãm hại bạn. Từ 70 có thể kết thông gia. Tốn %d ngày." % [roundi(float(rv["rel"])), Rivals.stance(rv), w.nation_name(str(rv["nation"])), Rivals.VISIT_DAYS], 14, UIKit.DIM))
	var names: = ["Tay không", "Lễ vừa", "Hậu lễ"]
	for gi in Rivals.GIFTS.size():
		var gift: int = gi
		var cost: = int(Rivals.GIFTS[gift][0])
		var row: = UIKit.hbox(10)
		var txt: = UIKit.rich(true)
		txt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		txt.text = "%s\n%s · quan hệ +%d" % [UIKit.col(names[gift], UIKit.GOLD), "không tốn bạc" if cost == 0 else "%d lượng" % cost, roundi(Rivals.visit_gain(w, rv, gift))]
		row.add_child(txt)
		var b: = UIKit.button("Bái phỏng", func() -> void :
			UIKit.close_modal(body)
			_do(Rivals.visit(w, rid, gift)))
		b.disabled = PlayerOps.money(w) < float(cost)
		row.add_child(b)
		body.add_child(UIKit.panel(row, UIKit.PANEL, 8))



func _plot_modal(target: Character, rid: String) -> void :
	var title: = "Âm mưu với %s" % (target.name if target != null else str(w.rivals[rid]["name"]))
	var body: = UIKit.modal(self, title, 720)
	body.add_child(UIKit.wrap_label("Việc do một môn khách đang theo hầu hoặc ở tư trạch nơi này làm (tự chọn người hợp nhất). Lộ ra thì Danh vọng giảm và nhà bị hại thù bạn; thất bại thì dễ lộ hơn.", 14, UIKit.DIM))
	for pid in Rivals.plots_for(w, target, rid):
		var plot: String = pid
		var pd: Dictionary = Rivals.PLOTS[plot]
		var blk: = Rivals.plot_block(w, plot, target, rid)
		var ag: Array = Rivals.best_agent(w, plot, target, rid)
		var p: = float(ag[1])
		var row: = UIKit.hbox(10)
		var txt: = UIKit.rich(true)
		txt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var who: = (ag[0] as Character).name if ag[0] != null else "chưa có người"
		txt.text = "%s  %s\n%s\n%s" % [UIKit.col(str(pd["name"]), UIKit.GOLD), UIKit.col("%d lượng · %d ngày · người làm: %s · thành ~%d%% · lộ ~%d%%" % [int(pd["cost"]), int(pd["days"]), who, roundi(p * 100.0), roundi(float(pd["expose"]) * 100.0)], UIKit.DIM), 
			UIKit.col(str(pd["desc"]), UIKit.DIM), UIKit.col(blk, UIKit.RED) if blk != "" else ""]
		row.add_child(txt)
		var tid: = "" if target == null else target.id
		var b: = UIKit.button("Ra tay", func() -> void :
			UIKit.close_modal(body)
			_do(Rivals.plot(w, plot, tid, rid)))
		b.disabled = blk != ""
		row.add_child(b)
		body.add_child(UIKit.panel(row, UIKit.PANEL, 8))



func _recruit_result(c: Character, r: Dictionary) -> void :
	var ok: = bool(r.get("accepted", false))
	var body: = UIKit.modal(self, ("%s nhận lời" if ok else "%s từ chối") % c.name, 600)
	var t: = UIKit.rich(true)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var prow: = UIKit.hbox(14)
	var pt: = Portraits.tex(w, c)
	if pt != null:
		var tr: = TextureRect.new()
		tr.texture = pt
		tr.custom_minimum_size = Vector2(112, 140)
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		if not ok:
			tr.modulate = Color(0.75, 0.75, 0.75)
		prow.add_child(tr)
	prow.add_child(t)
	if ok:
		var where: = "tư trạch %s" % w.city_name(PlayerOps.here(w)) if str(r.get("slot", "")) == "house" else "theo hầu bạn"
		t.text = """%s

%s
Lễ vật %s lượng · lương %s/tháng.

%s""" %[
			UIKit.col("%s chắp tay nhận lời về làm môn khách của %s." % [c.name, w.clan["name"]], UIKit.GREEN), 
			"Nơi ở: %s." % where, UIKit.col(str(r.get("fee", 0)), UIKit.GOLD), UIKit.col(str(r.get("salary", 0)), UIKit.GOLD), 
			UIKit.col("Cho đi học (Quân doanh, Học viện…) để họ rèn luyện, hoặc giao việc cho gia tộc; người theo hầu chỉ làm được Hộ vệ, Thuyết khách.", UIKit.DIM)]
	else:
		var why: = str(r.get("why", ""))
		t.text = """%s

%s%s

%s""" %[
			UIKit.col("%s khéo léo từ chối lời mời." % c.name, UIKit.RED), 
			("""Điều cản trở lớn nhất: %s.
""" %why) if why != "" else "", 
			"Có thể mời lại từ %s." % World.date_of(int(r.get("until", w.m + 6))), 
			UIKit.col("Cách nâng thiện chí: Thăm hỏi (ân tình; mỗi lần thăm rút ngắn 2 tháng chờ), Hậu đãi, Thuyết khách theo hầu, nâng Gia thế.", UIKit.DIM)]
	body.add_child(prow)
	var row: = UIKit.hbox(10)
	row.add_child(UIKit.spacer())
	if ok:
		row.add_child(UIKit.button("Cho đi học", func() -> void :
			UIKit.close_modal(body)
			sel = "npc:" + c.id
			refresh_all()
			_study_modal(c)))
		row.add_child(UIKit.button("Giao việc ngay", func() -> void :
			UIKit.close_modal(body)
			sel = "npc:" + c.id
			refresh_all()
			_assign_modal(c)))
	row.add_child(UIKit.button("Đóng", func() -> void : UIKit.close_modal(body)))
	body.add_child(row)


func _factor_row(v: float, t: String) -> Array:
	return [UIKit.col("%+d" % roundi(v), UIKit.GREEN if v > 0.0 else UIKit.RED), t]


func _visit_modal(c: Character) -> void :
	var body: = UIKit.modal(self, "Thăm hỏi %s" % c.name, 620)
	var vs: = PlayerOps.visits(w, c.id)
	var info: = "Ân tình hiện %d (thăm hỏi nâng được tới %d). Đã thăm %d lần." % [roundi(c.favor), int(PlayerOps.VISIT_CAP), vs]
	if int(w.notebook.get(c.id, {}).get("visit_m", -99)) == w.m - 1:
		info += " Vừa tới tháng trước, tới dày quá thì kém hiệu quả."
	body.add_child(UIKit.wrap_label(info, 14, UIKit.DIM))
	for g in PlayerOps.VISIT_GIFTS.size():
		var gift: int = g
		var cost: = PlayerOps.gift_cost(w, c, gift)
		var gain: = PlayerOps.visit_gain(w, c, gift)
		var row: = UIKit.hbox(12)
		var txt: = UIKit.rich(true)
		txt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		txt.text = "%s\n%s · ân tình %s" % [UIKit.col(str(PlayerOps.VISIT_GIFTS[gift]["name"]), UIKit.GOLD), "không tốn bạc" if cost == 0 else "%s lượng" % UIKit.col(str(cost), UIKit.GOLD), UIKit.col("+%d" % roundi(gain), UIKit.GREEN) if gain >= 0.5 else UIKit.col("không tăng thêm", UIKit.DIM)]
		row.add_child(txt)
		var b: = UIKit.button("Thăm", func() -> void :
			UIKit.close_modal(body)
			_do_pop(PlayerOps.visit(w, c.id, gift)))
		b.disabled = PlayerOps.money(w) < float(cost)
		row.add_child(b)
		body.add_child(UIKit.panel(row, UIKit.PANEL, 10))
	var st: = Items.store(w)
	if not st.is_empty():
		body.add_child(UIKit.wrap_label("Tặng đồ trong kho (võ nhân thích binh khí, ngựa; người trọng thể diện thích y phục: ×1,5)", 14, UIKit.GOLD))
	for it in st:
		var uid: = int(it["uid"])
		var gain2: = PlayerOps.visit_gain(w, c, 0, uid)
		var row2: = UIKit.hbox(12)
		var txt2: = UIKit.rich(true)
		txt2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var like: = Items.likes(c, str(it["k"]))
		txt2.text = "%s %s%s\ntrị giá %d lượng · ân tình %s" % [UIKit.col(Items.name_of(str(it["k"]), int(it["q"])), UIKit.GOLD), UIKit.col("(%s)" % Items.Q_NAMES[int(it["q"])], UIKit.DIM), UIKit.col(" · hợp ý" if like else "", UIKit.GREEN), 
			Items.price(str(it["k"]), int(it["q"])), UIKit.col("+%d" % roundi(gain2), UIKit.GREEN) if gain2 >= 0.5 else UIKit.col("không tăng thêm", UIKit.DIM)]
		row2.add_child(txt2)
		var b2: = UIKit.button("Tặng", func() -> void :
			UIKit.close_modal(body)
			_do_pop(PlayerOps.visit(w, c.id, 0, uid)))
		row2.add_child(b2)
		body.add_child(UIKit.panel(row2, UIKit.PANEL, 10))



func _person_tip(c: Character) -> String:
	var t: = "%s (%s, %d tuổi) · %s\n" % [c.name, "nữ" if c.female else "nam", c.age(w.m), _role_public(c)]
	var side: Array = []
	if c.nation_id != "" and w.nations.has(c.nation_id):
		var facs: Dictionary = w.nations[c.nation_id]["factions"]
		if c.faction_id != "" and facs.has(c.faction_id):
			side.append("phe %s" % facs[c.faction_id]["name"])
	if c.recommender == w.player_id:
		side.append("người bạn tiến cử")
	elif Rivals.backer(c) != "" and w.rivals.has(Rivals.backer(c)):
		side.append("người của %s" % w.rivals[Rivals.backer(c)]["name"])
	t += "Thế lực: %s · Danh tiếng %d\n" % [", ".join(side) if not side.is_empty() else "không phe phái", roundi(c.fame)]
	var pv: = Appraisal.perceived_vals(w, c)
	var parts: Array = []
	for i in Defs.N_STATS:
		parts.append("%s ~%d" % [Defs.STAT_SHORT[i], roundi(float(pv[i]))])
	parts.append("Mị ~%d" % roundi(float(pv[Defs.N_STATS])))
	t += "Triều đình thấy: " + ", ".join(parts)
	var rec: Dictionary = w.notebook.get(c.id, {}).get("appr", {})
	if not rec.is_empty():
		t += "\n(Bạn đã thẩm định: xem hồ sơ để so với thực tài)"
	return t



func _score_tip(c: Character, nid: String, key: String, extra: Array) -> String:
	if key == "":
		return ""
	var oid: = Appointment.office_of_key(key)
	var lines: Array = []
	var tot: = 0.0
	for pr in Appointment.score_parts(w, c, nid, oid) + extra:
		if absf(float(pr[1])) < 0.5:
			continue
		lines.append("• %s: %+d" % [pr[0], roundi(float(pr[1]))])
		tot += float(pr[1])
	return "Triều đình chấm %s ~%d điểm cho chức %s.\nChức này cần: %s.\n%s" % [c.name, roundi(tot), Defs.OFFICES[oid]["name"], Appointment.needs_text(oid), "\n".join(lines)]


func _recommend_modal(c: Character, vouch: bool = false, tab: int = -1) -> void :
	var body: = UIKit.modal(self, "Tiến cử %s" % c.name, 900)
	var vb: = Repute.vouch_block(w)
	var vc: = CheckBox.new()
	vc.text = "Bảo cử: cược %d Danh vọng để triều đình nể mặt; một năm sau làm tốt thì được +%d, kém thì mất cược" % [int(Repute.VOUCH_STAKE), int(Repute.VOUCH_STAKE * 2.0)]
	vc.button_pressed = vouch
	vc.disabled = vb != ""
	vc.tooltip_text = UIKit.wrap_tip(vb if vb != "" else "Đem uy tín gia tộc ra bảo lãnh cho người tài mà triều đình chưa thấy rõ: điểm xét +%d." % int(Repute.VOUCH_BONUS))
	body.add_child(vc)
	var opts: Array = PlayerOps.recommend_options(w, c, vouch)
	var nid0: = str(opts[0]["nid"]) if not opts.is_empty() else ""
	if nid0 != "":
		var foreign: = nid0 != w.player().nation_id
		body.add_child(UIKit.wrap_label("%s%s · năm nay triều đình còn nhận %d / %d lời tiến cử của bạn · Danh vọng %d. Triều đình chỉ thấy danh tiếng và năng lực bề ngoài; muốn thay người đang giữ ghế phải được chấm cao hơn họ (người giữ lâu năm có lợi thế thâm niên). Rê chuột lên tên và điểm để xem chi tiết." % [
			w.nation_name(nid0), " (ngoại quốc: thưởng ×1,5 nhưng bản quốc nghi kỵ)" if foreign else " (bản quốc)", 
			maxi(0, PlayerOps.rec_cap(w) - PlayerOps.rec_used(w, nid0)), PlayerOps.rec_cap(w), roundi(PlayerOps.prestige(w))], 14, UIKit.DIM))
	var tc: = TabContainer.new()
	tc.custom_minimum_size = Vector2(860, 470)
	body.add_child(tc)
	var first_open: = -1
	for k in PlayerOps.REC_TIERS.size():
		var lock: = PlayerOps.rec_tier_block(w, nid0, k) if nid0 != "" else ""
		if lock == "" and first_open < 0:
			first_open = k
		var page: = UIKit.vbox(6)
		page.name = "T%d" % k
		page.add_child(UIKit.label(("Mở: " if lock == "" else "Khóa: ") + (("cần Danh vọng ≥ %d" % int(PlayerOps.REC_TIERS[k][1])) if k > 0 else "ai cũng tiến cử được") + ("" if lock == "" else " · " + lock), 13, UIKit.GREEN if lock == "" else UIKit.RED))
		var scroll: = ScrollContainer.new()
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		page.add_child(scroll)
		var list: = UIKit.vbox(4)
		list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.add_child(list)
		for o in opts:
			if int(o["tier"]) == k:
				list.add_child(_rec_row(body, c, o, vouch))
		tc.add_child(page)
		tc.set_tab_title(k, ("" if lock == "" else "🔒 ") + str(PlayerOps.REC_TIERS[k][2]))
	tc.current_tab = tab if tab >= 0 else maxi(0, first_open)
	vc.toggled.connect( func(on: bool) -> void :
		var cur: = tc.current_tab
		UIKit.close_modal(body)
		_recommend_modal(c, on, cur))


func _rec_row(body: Control, c: Character, o: Dictionary, vouch: bool) -> Control:
	var nid: = str(o["nid"])
	var key: = str(o["key"])
	var row: = UIKit.hbox(10)
	var rw: = PlayerOps.reward_estimate(w, c, key, bool(o["foreign"]))
	var t: = UIKit.rich(true)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var inc_c: Character = w.office_holder(nid, key) if key != "" else null
	var who: = ""
	if inc_c != null:
		who = "thay " + _tip(UIKit.col("[u]%s[/u]" % inc_c.name, UIKit.DIM), _person_tip(inc_c) + "\nĐã giữ chức %d tháng." % inc_c.office_months) + (UIKit.col(" (người của bạn)", UIKit.GOLD) if bool(o["mine"]) else "")
	elif key != "":
		who = UIKit.col("ghế trống", UIKit.GREEN)
	var col: = UIKit.GREEN if bool(o["ok"]) else UIKit.DIM
	var mine_extra: Array = [["Thế lực của bạn khi tiến cử (Chính trị, Danh vọng, Ảnh hưởng, người quen trong triều)", PlayerOps.rec_bonus(w, nid)]]
	if key != "" and bool(Defs.OFFICES[Appointment.office_of_key(key)]["military"]):
		mine_extra.append(["Tài cầm quân của bạn (chức võ)", PlayerOps.general_bonus(w)])
	if vouch:
		mine_extra.append(["Bạn bảo cử", Repute.VOUCH_BONUS])
	var cand: = _tip(UIKit.col("[u]~%d[/u]" % roundi(float(o["cand"])), col), 
		_score_tip(c, nid, key, mine_extra) if key != "" else "Vào triều: triều đình xét năng lực bề ngoài ở vai trò hợp nhất của %s; đủ 35 thì nhận, có ghế trống sẽ bổ nhiệm." % c.name)
	var need: = ""
	if key == "":
		need = "cần ≥ 35"
	elif inc_c == null:
		need = "cần > ~%d (mức tối thiểu)" % roundi(float(o["inc"]))
	else:
		need = "cần hơn " + _tip(UIKit.col("[u]~%d[/u]" % roundi(float(o["inc"])), col), _score_tip(inc_c, nid, key, 
			[["Đang giữ chức %d năm (thâm niên)" % (inc_c.office_months / 12), Appointment.incumbency(inc_c)], ["Dư đảng nhà đã sụp", - Rivals.remnant_penalty(w, inc_c)]])) + UIKit.col(" của người đang giữ", col)
	var line3: = ""
	if key != "":
		line3 = "\n" + UIKit.col("Cần: " + Appointment.needs_text(Appointment.office_of_key(key)), UIKit.DIM)
	t.text = "%s  %s\n%s%s%s%s" % [UIKit.col(str(o["label"]), UIKit.TEXT), who, 
		UIKit.col("Triều đình chấm ứng viên ", col), cand, UIKit.col(", ", col) + (need if need.begins_with("cần hơn") else UIKit.col(need, col)), 
		UIKit.col(" · thưởng ~%d lượng, Danh vọng +%d" % [int(rw[0]), roundi(float(rw[1]))], col) + line3]
	if float(o.get("snub", 0.0)) > 0.0:
		t.text += UIKit.col("  · ~%d%% bị chê vì Mị lực thấp" % roundi(float(o["snub"]) * 100.0), UIKit.RED)
	row.add_child(t)
	var ok: = bool(o["ok"]) and not bool(o["mine"])
	var lock: = str(o.get("lock", ""))
	var b: = UIKit.button("Tiến cử" + _d("recommend") if ok else ("Khóa" if lock != "" else "Không đủ"), func() -> void :
		UIKit.close_modal(body)
		_do_pop(PlayerOps.recommend(w, c.id, nid, key, vouch), "Tiến cử %s" % c.name), 
		lock if lock != "" else ("" if ok else "Điểm của ứng viên chưa hơn người đang giữ ghế."))
	b.disabled = not ok
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(b)
	return UIKit.panel(row, UIKit.PANEL, 6)


func _office_modal() -> void :
	var body: = UIKit.modal(self, "Xin chức cho bản thân", 820)
	body.add_child(UIKit.wrap_label("Triều đình đánh giá bạn như mọi ứng viên (năng lực bề ngoài, danh tiếng), cộng thế lực của gia tộc. Làm quan: có lương, Ảnh hưởng +1 và Danh vọng +0,5 mỗi tháng, ghế của bạn tính vào \"người của bạn\" cho các kết thúc; đổi lại 6 ngày đầu mỗi tháng phải lo việc công (chức trọng như Lục bộ có thuộc lại thì không).", 14, UIKit.DIM))
	var scroll: = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(780, 380)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var list: = UIKit.vbox(4)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	for o in PlayerOps.office_options(w):
		var row: = UIKit.hbox(10)
		var t: = UIKit.rich(true)
		var holder: = str(o["holder"])
		t.text = "%s  %s\n%s" % [UIKit.col(str(o["label"]), UIKit.TEXT), UIKit.col("ghế trống" if holder == "" else "thay " + holder, UIKit.DIM), 
			UIKit.col("Bạn ~%d, cần > ~%d · lương %d lượng/tháng" % [roundi(float(o["cand"])), roundi(float(o["inc"])), int(o["salary"])], UIKit.GREEN if bool(o["ok"]) else UIKit.DIM)]
		row.add_child(t)
		var nid: = str(o["nid"])
		var key: = str(o["key"])
		var b: = UIKit.button("Xin chức" if bool(o["ok"]) else "Không đủ", func() -> void :
			UIKit.close_modal(body)
			_do(PlayerOps.seek_office(w, nid, key)))
		b.disabled = not bool(o["ok"])
		row.add_child(b)
		list.add_child(UIKit.panel(row, UIKit.PANEL, 6))


func _probe_modal(c: Character) -> void :
	var body: = UIKit.modal(self, "Thăm dò %s" % c.name, 660)
	var dist: = w.travel_months(PlayerOps.here(w), c.city_id)
	body.add_child(UIKit.wrap_label("%s đang ở %s, cách bạn %d tháng đường. Người bạn cử đi sẽ ghi lại tình hình lúc này rồi mang tin về, nên tin tới tay đã cũ đúng bằng thời gian chờ. Trả ít thì tin chậm, mơ hồ, có khi sai. Thăm dò không cho biết tiềm năng: điều đó phải tận mắt nhìn bằng Đôi Mắt." % [c.name, w.city_name(c.city_id), dist], 14, UIKit.DIM))
	for t in PlayerOps.PROBE_TIERS.size():
		var td: Dictionary = PlayerOps.PROBE_TIERS[t]
		var row: = UIKit.hbox(10)
		var tx: = UIKit.rich(true)
		tx.text = "%s  %s\n%s\n%s" % [UIKit.col("Trả " + str(td["name"]).to_lower(), UIKit.GOLD), UIKit.col("%d lượng" % int(td["cost"]), UIKit.GOLD), 
			UIKit.col(str(td["desc"]), UIKit.DIM), 
			"Tin về sau ~%d tháng · năng lực ±%d · %s" % [PlayerOps.probe_delay(w, c, t), int(td["half"]), "có thể sai" if float(td["wrong"]) > 0.0 else "đáng tin"]]
		row.add_child(tx)
		var tier: int = t
		var b: = UIKit.button("Cử người", func() -> void :
			UIKit.close_modal(body)
			_do(PlayerOps.probe(w, c.id, tier)))
		b.disabled = PlayerOps.money(w) < float(td["cost"])
		row.add_child(b)
		body.add_child(UIKit.panel(row, UIKit.PANEL, 8))


func _counsel_modal(c: Character) -> void :
	var body: = UIKit.modal(self, "Khuyên nhủ %s" % c.name, 620)
	var rec: Dictionary = w.notebook.get(c.id, {}).get("appr", {})
	var probs: Dictionary = rec.get("crisis", {}) if not rec.is_empty() and int(rec["m"]) == w.m else {}
	body.add_child(UIKit.wrap_label("%s đang khủng hoảng sau biến cố. Họ sẽ tự chọn con đường; lời khuyên của bạn (dựa vào Mị lực và ân tình) làm nghiêng cán cân. Thẩm định Cao cấp trong tháng này cho thấy xác suất hiện tại." % c.name, 14, UIKit.DIM))
	for path in Crisis.PATHS:
		if path == "sa_nga":
			continue
		var row: = UIKit.hbox(10)
		var t: = UIKit.rich(true)
		t.text = "%s\n%s%s" % [UIKit.col(Crisis.PATH_NAMES[path], UIKit.GOLD), PlayerOps.PATH_HINT[path], UIKit.col("  (hiện ~%d%%)" % roundi(float(probs[path]) * 100.0), UIKit.DIM) if probs.has(path) else ""]
		row.add_child(t)
		var pth: String = path
		row.add_child(UIKit.button("Khuyên", func() -> void :
			UIKit.close_modal(body)
			_do(PlayerOps.counsel(w, c.id, pth))))
		body.add_child(UIKit.panel(row, UIKit.PANEL, 8))


func _assign_modal(c: Character) -> void :
	_task_modal(c, false)


func _study_modal(c: Character) -> void :
	_task_modal(c, true)



func _task_modal(c: Character, study: bool) -> void :
	var body: = UIKit.modal(self, ("Đào tạo %s" if study else "Giao việc cho %s") % c.name, 1120)
	var cur: = PlayerOps.study_of(w, c) if study else PlayerOps.job_of(w, c)
	body.add_child(UIKit.wrap_label("Đang: %s. Học và Việc là hai ô riêng: theo hầu thì làm Hộ vệ / Thuyết khách, về tư trạch thì học; ở tư trạch vừa học vừa làm thì cả hai ×0,75. Hướng tu dưỡng theo việc học khi đang học. %s" % [
		_task_text(c), 
		"Đi học cần cơ sở ở thành họ đang ở; tư trạch ở thành có Học phủ, Võ đường… học nhanh hơn ×1,3." if study else ""], 14, UIKit.DIM))
	var grid: = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 8)
	body.add_child(grid)
	for task in PlayerOps.task_list(study):
		var td: Dictionary = PlayerOps.TASKS[task]
		var row: = UIKit.hbox(10)
		var t: = UIKit.rich(true)
		t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var desc: = str(td["desc"])
		if task == "":
			desc = ("Không học nữa. " if study else "Không giao việc. ") + "Khi không học, không làm thì sống theo nghề cũ: %s. %s" % [_prof_bb(c.profession, c), _prof_info(c.profession)]
		t.text = "%s%s\n%s" % [UIKit.col("Thôi học" if study and task == "" else str(td["name"]), UIKit.GOLD), UIKit.col("  (đang làm)", UIKit.GREEN) if task == cur else "", 
			UIKit.col("%s%s" % [desc, "  Chi phí %d lượng/tháng." % int(td["cost"]) if int(td["cost"]) > 0 else ""], UIKit.DIM)]
		row.add_child(t)
		var tk: String = task
		var block: = PlayerOps.study_block(w, c, task)
		if block != "" and task != cur:
			var near: Array = PlayerOps.study_places_near(w, task, PlayerOps.task_city(w, c))
			t.text += "\n" + UIKit.col(block, UIKit.RED)
			if not near.is_empty():
				t.text += UIKit.col(" Nên tới: " + ", ".join(near.map( func(x: Array) -> String: return "%s (%d ngày)" % [w.city_name(str(x[0])), int(x[1])])), UIKit.DIM)
		var b: = UIKit.button("Chọn", func() -> void :
			UIKit.close_modal(body)
			if tk == "day_do":
				_student_modal(c)
			elif study:
				_do(PlayerOps.set_study(w, c.id, tk))
			else:
				_do(PlayerOps.assign(w, c.id, tk)))
		b.disabled = (task == cur and task != "day_do") or block != ""
		if block != "":
			b.tooltip_text = block
		if task == "day_do" and PlayerOps.retainers(w).size() < 2:
			b.disabled = true
			b.tooltip_text = "Cần ít nhất 2 môn khách."
		b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(b)
		if block != "" and task != cur and not PlayerOps.on_road(w, c):
			var sbtn: = UIKit.button("Điều đi…", func() -> void :
				UIKit.close_modal(body)
				_send_modal(c), "Gửi thư điều %s tới thành có cơ sở" % c.name)
			sbtn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			row.add_child(sbtn)
		var pn: = UIKit.panel(row, UIKit.PANEL2 if task == cur else UIKit.PANEL, 8)
		pn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pn.custom_minimum_size.x = 530
		grid.add_child(pn)


func _expose_modal(c: Character) -> void :
	var body: = UIKit.modal(self, "Vạch trần %s" % c.name, 640)
	var est: = Repute.expose_estimate(w, c)
	var rv: Dictionary = Rivals.of(w, c) if Rivals.backer(c) == "" else w.rivals.get(Rivals.backer(c), {})
	var r: = UIKit.rich(true)
	r.text = "%s đang giữ chức %s.\nTriều đình chấm khoảng %s; theo kết quả thẩm định của bạn, thực tài ở chức này kém hơn khoảng %s điểm.\n\n%s\n%s\n%s" % [
		c.name, Appointment.office_label_of(w, c), UIKit.col("~%d" % roundi(Appraisal.perceived_office_score(w, c, Appointment.office_id_of(c))), UIKit.GOLD), 
		UIKit.col(str(roundi(float(est["gap"]))), UIKit.GOLD if float(est["gap"]) >= 8.0 else UIKit.RED), 
		UIKit.col("Ước khả năng thành công: ~%d%% (dải thẩm định còn rộng thì ước có thể sai)." % roundi(float(est["p"]) * 100.0), UIKit.TEXT), 
		UIKit.col("Thành: cách chức họ, Ảnh hưởng +10, Danh vọng +5, Ngộ đạo +5.", UIKit.GREEN), 
		UIKit.col("Hụt: bị coi là vu khống, Danh vọng −8, Ảnh hưởng −5.", UIKit.RED) + (UIKit.col("\nNgười này do %s tiến cử: họ sẽ thù bạn." % rv["name"], UIKit.PURPLE) if not rv.is_empty() else "")]
	r.text += UIKit.col("\nKết quả trả sau khi thẩm tra (%s ngày); thế gia đứng sau có thể đút lót để ém vụ việc." % ("6–9" if Repute.outranks(w, c) else "10–15"), UIKit.DIM)
	body.add_child(r)
	if Repute.outranks(w, c):
		var parts: = c.office_key.split("/")
		var key: = str(parts[1]) if parts.size() > 1 else ""
		body.add_child(UIKit.label("Bạn là quan lớn hơn: hặc tấu thẳng (+%d%%), và có thể đề cử người thay (các quan vẫn phải duyệt)" % roundi(Repute.OUTRANK_BONUS * 100.0), 15, UIKit.GOLD))
		var flow: = HFlowContainer.new()
		flow.add_theme_constant_override("h_separation", 8)
		for nm: Character in Repute.nominees(w):
			var nid2: = nm.id
			flow.add_child(UIKit.button("Hặc tấu, đề cử %s (~%d%%)" % [nm.name, roundi(Repute.nominee_chance(w, nm, c.nation_id, key) * 100.0)], func() -> void :
				UIKit.close_modal(body)
				_do_pop(Repute.expose(w, c.id, nid2), "Hặc tấu %s" % c.name), "Nếu %s bị cách chức, %s được đề cử vào ghế này" % [c.name, nm.name]))
		body.add_child(flow)
	var row: = UIKit.hbox(8)
	row.add_child(UIKit.spacer())
	row.add_child(UIKit.button(("Hặc tấu" if Repute.outranks(w, c) else "Dâng sớ") + _d("expose"), func() -> void :
		UIKit.close_modal(body)
		_do_pop(Repute.expose(w, c.id), "Vạch trần %s" % c.name)))
	row.add_child(UIKit.button("Thôi", func() -> void : UIKit.close_modal(body)))
	body.add_child(row)


func _purse_modal(c: Character) -> void :
	var body: = UIKit.modal(self, "Tiền bạc với %s" % c.name, 760)
	var info: = UIKit.rich(true)
	var s: = "Túi riêng: %s lượng · lương %d/tháng (giữ lại ~60%%)\n" % [UIKit.col(str(roundi(c.purse)), UIKit.GOLD), int(w.play["salary"].get(c.id, 0))]
	if not c.purse_last.is_empty():
		s += UIKit.col("Tháng trước: +%d / −%d (%s)\n" % [int(c.purse_last["in"]), int(c.purse_last["out"]), ", ".join(c.purse_last["notes"])], UIKit.DIM)
	s += UIKit.col("Túi dày thì họ tự sắm đồ hợp sở trường (đồ riêng, rời đi thì mang theo). Người trung thành có khi biếu Tết. Túi rỗng, lương thấp thì dễ bị thế gia khác lôi kéo.", UIKit.DIM)
	info.text = s
	body.add_child(info)
	var close_then: = func(r: Dictionary) -> void :
		UIKit.close_modal(body)
		_do_pop(r, "Tiền bạc với %s" % c.name)

	var rb: = Purse.reward_block(w, c)
	var row: = UIKit.hbox(8)
	row.add_child(UIKit.label("Ban thưởng", 15, UIKit.GOLD))
	row.add_child(UIKit.spacer())
	for k in Purse.REWARDS.size():
		var tier: int = k
		var b: = UIKit.button("%d lượng · TT +%d" % [int(Purse.REWARDS[k][0]), int(Purse.REWARDS[k][1])], func() -> void : close_then.call(Purse.reward(w, c.id, tier)), 
			rb if rb != "" else "Tăng trung thành (người tham tài ×1,5); mỗi tháng một lần")
		b.disabled = rb != "" or PlayerOps.money(w) < float(Purse.REWARDS[k][0])
		row.add_child(b)
	body.add_child(UIKit.panel(row, UIKit.PANEL, 8))

	var row2: = UIKit.hbox(8)
	var dbt: = Purse.debt_of(w, c.id)
	row2.add_child(UIKit.label("Vay tiền" if dbt.is_empty() else "Đang nợ %d lượng (hạn %s)" % [int(dbt["amt"]), World.date_of(int(dbt["due"]))], 15, UIKit.GOLD))
	row2.add_child(UIKit.spacer())
	if dbt.is_empty():
		var bb: = Purse.borrow_block(w, c)
		var vb: = UIKit.button("Vay %d lượng" % Purse.loan_amount(c), func() -> void : close_then.call(Purse.borrow(w, c.id)), 
			bb if bb != "" else "Hẹn trả trong %d tháng; quá hạn thì Trung thành giảm dần mỗi tháng" % Purse.LOAN_DAYS_M)
		vb.disabled = bb != ""
		row2.add_child(vb)
	else:
		var tb: = UIKit.button("Trả nợ", func() -> void : close_then.call(Purse.repay(w, c.id)), "Trả đúng hẹn: Trung thành +3")
		tb.disabled = PlayerOps.money(w) < float(dbt["amt"])
		row2.add_child(tb)
	body.add_child(UIKit.panel(row2, UIKit.PANEL, 8))

	var row3: = UIKit.hbox(8)
	var pk: = Purse.pick_block(w, c)
	row3.add_child(UIKit.label("Bày cớ thu tiền", 15, UIKit.RED))
	row3.add_child(UIKit.spacer())
	var pb: = UIKit.button("Thu %d lượng" % roundi(floorf(c.purse * Purse.PICK_SHARE)), func() -> void : close_then.call(Purse.pickpocket(w, c.id)), 
		pk if pk != "" else "Lấy một nửa túi riêng (\"góp quỹ\", \"phạt lỗi\"): Trung thành −20; ~%d%% bị lộ, cả nhà môn khách mất lòng, Danh vọng −3" % roundi(Purse.pick_risk(c) * 100.0))
	pb.disabled = pk != ""
	row3.add_child(pb)
	body.add_child(UIKit.panel(row3, UIKit.PANEL, 8))


func _career_modal(c: Character) -> void :
	var body: = UIKit.modal(self, "Khuyên %s đổi nghề" % c.name, 1120)
	var rec: Dictionary = w.notebook.get(c.id, {}).get("appr", {})
	body.add_child(UIKit.wrap_label("Nghề hiện tại: %s. %s Bạn giúp vốn %d lượng nếu họ nhận lời. Nghề mới hợp tiềm năng thì dễ trụ; không hợp thì vài tháng sau dễ bỏ dở, quay về nghề cũ.%s" % [
		Defs.prof_name(c.profession), _prof_info(c.profession), PlayerOps.CAREER_COST, 
		" Với môn khách: nghề quyết định hướng rèn khi không học, không làm, và khi rời gia tộc." if PlayerOps.is_retainer(w, c) else ""], 14, UIKit.DIM))
	if ProfTree.rank(c) > 1:
		body.add_child(UIKit.wrap_label("⚠ Đổi nghề thì mất danh xưng %s (bậc %d/4), về bậc 1 của nghề mới." % [ProfTree.title(c), ProfTree.rank(c)], 14, UIKit.RED))
	var nx: Array = ProfTree.next_options(c)
	if not nx.is_empty():
		body.add_child(UIKit.label("Khuyên định hướng (giữ nghề; lần lên bậc tới, khoảng %d tháng nữa) · nhận lời ~%d%%" % [ProfTree.months_to_next(c), roundi(PlayerOps.path_chance(w, c) * 100.0)], 15, UIKit.GOLD))
		var prow: = HFlowContainer.new()
		prow.add_theme_constant_override("h_separation", 8)
		for n: Dictionary in nx:
			var nid: = str(n["id"])
			var st: = int(n["stat"])
			var band: Array = []
			if not rec.is_empty():
				band = rec.get("mi_pot", []) if st == ProfTree.MI else rec["pot"][st]
			var pb: = UIKit.button("%s · %s %s" % [n["name"], ProfTree.stat_name(st), _plain_range(band)], func() -> void :
				UIKit.close_modal(body)
				_do_pop(PlayerOps.advise_path(w, c.id, nid), "Khuyên %s định hướng" % c.name), "Khi lên bậc, nghiêng mạnh về nhánh này (thêm %s vào hướng tu dưỡng)" % ProfTree.stat_name(st))
			pb.disabled = c.prof_hint == nid
			prow.add_child(pb)
		body.add_child(prow)
		body.add_child(UIKit.label("Hoặc khuyên đổi hẳn sang nghề khác", 15, UIKit.GOLD))
	var grid: = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 8)
	body.add_child(grid)
	for pid in PlayerOps.CAREERS:
		if pid == c.profession:
			continue
		var pd: Dictionary = Defs.PROFESSIONS[pid]
		var fit: Array = []
		if PlayerOps.MI_ENVS.has(str(pd["env"])):
			fit.append("Mị lực %s (×%s)" % [UIKit.range_text(rec.get("mi_pot", []) if not rec.is_empty() else []), str(PlayerOps.MI_ENVS[str(pd["env"])]).replace(".", ",")])
		for i in pd["focus"]:
			var band: Array = rec.get("pot", [])[int(i)] if not rec.is_empty() else []
			fit.append("%s %s" % [Defs.STAT_NAMES[int(i)], UIKit.range_text(band)])
		var cc: = PlayerOps.career_chance(w, c, str(pid))
		var tips: Array = []
		for pr in cc["parts"]:
			if absf(float(pr[1])) >= 0.005:
				tips.append("%s %+d%%" % [pr[0], roundi(float(pr[1]) * 100.0)])
		var row: = UIKit.hbox(10)
		var tx: = UIKit.rich(true)
		tx.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tx.text = "%s  %s\n%s" % [_prof_bb(str(pid)), UIKit.col("· nhận lời ~%d%%" % roundi(float(cc["p"]) * 100.0), UIKit.GREEN if float(cc["p"]) >= 0.5 else UIKit.DIM), 
			UIKit.col("Tiềm năng: ", UIKit.DIM) + (" · ".join(fit) if not fit.is_empty() else UIKit.col("không có hướng rèn", UIKit.DIM))]
		row.add_child(tx)
		var pk: String = pid
		var b: = UIKit.button("Khuyên", func() -> void :
			UIKit.close_modal(body)
			_do_pop(PlayerOps.advise_career(w, c.id, pk), "Khuyên %s đổi nghề" % c.name), "Gốc 45%; " + " · ".join(tips))
		b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(b)
		var pn: = UIKit.panel(row, UIKit.PANEL, 8)
		pn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pn.custom_minimum_size.x = 530
		grid.add_child(pn)


func _student_modal(t: Character) -> void :
	var body: = UIKit.modal(self, "%s nhận dạy ai?" % t.name, 620)
	body.add_child(UIKit.wrap_label("Thầy dạy chỉ số trong hướng tu dưỡng của trò mà thầy giỏi nhất. Thầy giỏi bằng tiềm năng của trò (trừ 10) thì trò lớn ×1,6; giỏi hơn trò 10 điểm thì ×1,3.", 14, UIKit.DIM))
	for st: Character in PlayerOps.retainers(w):
		if st.id == t.id:
			continue
		var eff: = PlayerOps.mentor_effect(w, t, st)
		var row: = UIKit.hbox(10)
		var tx: = UIKit.rich(true)
		tx.text = "%s  %s\nDạy %s · hiệu quả %s" % [UIKit.col(st.name, UIKit.GOLD), UIKit.col("(%d tuổi)" % st.age(w.m), UIKit.DIM), Defs.STAT_NAMES[int(eff["stat"])], 
			UIKit.col(str(eff["word"]), UIKit.GREEN if float(eff["mult"]) >= 1.6 else (UIKit.TEXT if float(eff["mult"]) > 1.0 else UIKit.RED))]
		row.add_child(tx)
		var sid: = st.id
		row.add_child(UIKit.button("Kèm người này", func() -> void :
			UIKit.close_modal(body)
			_do(PlayerOps.assign(w, t.id, "day_do", sid))))
		body.add_child(UIKit.panel(row, UIKit.PANEL, 8))


func _coup_modal() -> void :
	var body: = UIKit.modal(self, "Phát động chính biến", 680)
	body.add_child(UIKit.wrap_label("Đoạt quyền triều đình bản quốc. Thành công: Thay triều đổi đại, vòng đời khép lại trong vinh quang. Thất bại: người của bạn trong triều bị thanh trừng, mất hết Ảnh hưởng và nhiều Danh vọng; ~%d%% bạn bị xử trảm (giảm theo Võ lực của bạn / Hộ vệ)." % roundi(Endings.coup_death_chance(w) * 100.0), 14, UIKit.DIM))
	var tx: = UIKit.rich(true)
	var s: = ""
	for c in Endings.coup_conditions(w):
		s += "%s %s\n" % [UIKit.col("✓", UIKit.GREEN) if bool(c["ok"]) else UIKit.col("✗", UIKit.RED), c["text"]]
	s += "\nKhả năng thành công: %s" % UIKit.col("%d%%" % roundi(Endings.coup_chance(w) * 100.0), UIKit.GOLD)
	s += UIKit.col("  (+8% cho mỗi người của bạn trong triều còn ân tình, +20% nếu triều đình bất ổn, tư binh +%d%%)" % roundi(PlayerOps.troop_coup_bonus(w) * 100.0), UIKit.DIM)
	tx.text = s
	body.add_child(tx)
	var row: = UIKit.hbox(10)
	row.add_child(UIKit.spacer())
	var b: = UIKit.button("  Phát động  ", func() -> void :
		UIKit.close_modal(body)
		var r: = Endings.coup(w)
		if str(w.play["over"]) != "":
			main.show_end(w)
			return
		_do(r))
	b.disabled = not Endings.coup_ready(w)
	row.add_child(b)
	body.add_child(row)


func _choices_modal() -> void :
	var list: = PlayerOps.choices(w)
	if list.is_empty():
		return
	var body: = UIKit.modal(self, "Việc chờ bạn quyết (%d)" % list.size(), 760)
	body.add_child(UIKit.wrap_label("Quá hạn mà chưa quyết thì việc tự ngả theo phương án cuối cùng.", 13, UIKit.DIM))
	for ch in list:
		var box: = UIKit.vbox(6)
		var tx: = UIKit.rich(true)
		tx.text = "%s\n%s" % [str(ch["text"]), UIKit.col("Hạn: %s" % World.date_of(int(ch["until"])), UIKit.DIM)]
		box.add_child(tx)
		var uid: = int(ch["uid"])
		for o in ch["opts"]:
			var row: = UIKit.hbox(10)
			var key: = str(o[0])
			row.add_child(UIKit.button(str(o[1]), func() -> void :
				UIKit.close_modal(body)
				var r: = PlayerOps.resolve_choice(w, uid, key)
				_do(r)
				if not PlayerOps.choices(w).is_empty():
					_choices_modal()))
			row.add_child(UIKit.wrap_label(str(o[2]), 13, UIKit.DIM))
			(row.get_child(1) as Control).size_flags_horizontal = Control.SIZE_EXPAND_FILL
			box.add_child(row)
		body.add_child(UIKit.panel(box, UIKit.PANEL, 10))


func _train_modal() -> void :
	var body: = UIKit.modal(self, "Tự tu dưỡng", 640)
	var tn: = PlayerOps.trained_this_month(w)
	body.add_child(UIKit.wrap_label("Tốn %d ngày, tối đa %d lần mỗi tháng (lần thứ 2 chỉ được một nửa). Chỉ số càng gần tiềm năng càng khó tăng; tuổi càng lớn càng chậm. Rèn ở nơi hợp (thành mạnh về mặt đó, Mị lực ở kinh đô) được thêm 30%%. Chỉ số được chọn cũng thành hướng tu dưỡng hằng tháng của bạn." % [PlayerOps.act_days(w, "train"), PlayerOps.TRAIN_MAX], 14, UIKit.DIM))
	var tn_txt: = "Tháng này đã tu dưỡng %d / %d lần." % [tn, PlayerOps.TRAIN_MAX]
	if tn == PlayerOps.TRAIN_MAX - 1:
		tn_txt += "  Lần này chỉ được MỘT NỬA."
	body.add_child(UIKit.label(tn_txt, 16 if tn > 0 else 14, UIKit.GOLD if tn == 0 else UIKit.RED))
	var sug: = PlayerOps.train_suggestion(w)
	var strong: = PlayerOps.strength_stat(w)
	for g in PlayerOps.STAT_GROUPS:
		var head: = UIKit.label("%s  ·  %s" % [str(g["name"]).to_upper(), g["use"]], 14, UIKit.GOLD)
		body.add_child(head)
		for i in g["stats"]:
			var idx: = int(i)
			var v: Array = PlayerOps.pstat(w, idx)
			var r: = float(v[0])
			var pt: = float(v[1])
			var gain: = PlayerOps.train_gain(w, idx)
			var row: = UIKit.hbox(10)
			var nm: = ("★ " if idx == strong else "") + PlayerOps.pstat_name(idx)
			var lb: = UIKit.label(nm, 15, UIKit.TEXT)
			lb.custom_minimum_size.x = 170
			var key: = PlayerOps.pstat_name(idx)
			_label_tip(lb, "%s: %s" % [key, STAT_TIP.get(key, "")] + ("\n★ Sở trường của Mệnh cách." if idx == strong else ""))
			row.add_child(lb)
			var vl: = UIKit.label("%d / %d" % [roundi(r), roundi(pt)], 15, UIKit.grade_color(r))
			vl.custom_minimum_size.x = 80
			_label_tip(vl, "Thực %d / Tiềm năng %d (%s). %s" % [roundi(r), roundi(pt), Defs.grade(r), HEAD_TIP["Tiềm năng"]])
			row.add_child(vl)
			var gl: = UIKit.label("+%.1f" % gain, 15, UIKit.GREEN)
			gl.custom_minimum_size.x = 50
			_label_tip(gl, "Tăng dự kiến nếu rèn lần này: theo khoảng cách tới tiềm năng, tuổi, Ngộ tính, nơi rèn%s." % (" (lần thứ 2 trong tháng chỉ được một nửa)" if tn >= 1 else ""))
			row.add_child(gl)
			if PlayerOps.train_place_ok(w, idx):
				var pl: = UIKit.label("nơi hợp", 13, UIKit.BLUE)
				_label_tip(pl, "Đang ở nơi hợp để rèn chỉ số này (%s): thêm 30%%." % PlayerOps.train_place_name(idx))
				row.add_child(pl)
			else:
				var pl2: = UIKit.label("", 13, UIKit.DIM)
				row.add_child(pl2)
				_label_tip(lb, lb.tooltip_text + "\nRèn ở %s thì được thêm 30%%." % PlayerOps.train_place_name(idx))
			row.add_child(UIKit.spacer())
			if idx == sug:
				row.add_child(UIKit.label("nên rèn", 13, UIKit.GREEN))
			var si: int = idx
			var b: = UIKit.button("Rèn luyện", func() -> void :
				UIKit.close_modal(body)
				var go: = func() -> void : _do(PlayerOps.train(w, si))
				if PlayerOps.trained_this_month(w) >= 1:
					_confirm_once("warn_train_half", "Tu dưỡng lần thứ 2 trong tháng", 
						"Lần thứ 2 trong cùng một tháng chỉ được [b]một nửa[/b] (+%.1f %s), vẫn tốn %d ngày. Sang tháng sau rèn thì được đủ.\n\nVẫn rèn luyện?" % [PlayerOps.train_gain(w, si), PlayerOps.pstat_name(si), PlayerOps.act_days(w, "train")], 
						"Vẫn rèn", go)
				else:
					go.call(), 
				"Rèn ở %s được thêm 30%%" % PlayerOps.train_place_name(idx))
			b.disabled = tn >= PlayerOps.TRAIN_MAX
			row.add_child(b)
			body.add_child(row)




func _on_city(cid: String) -> void :
	if cid == PlayerOps.here(w):
		tabs.current_tab = 0
		return
	if PlayerOps.travel_days(w, cid) < 0:
		_do(PlayerOps.travel(w, cid))
		return

	map_view.play_travel(PlayerOps.here(w), cid, func() -> void : _do(PlayerOps.travel(w, cid)))


func _end_month() -> void :
	_do(PlayerOps.rest(w))


func show_report(rep: Dictionary) -> void :
	var body: = UIKit.modal(self, "Báo cáo đầu %s" % World.date_of(w.m), 760)
	var s: = ""
	var lines: Array = rep["lines"]
	if not lines.is_empty():
		s += UIKit.col("Việc của gia tộc", UIKit.GOLD) + "\n"
		for l in lines:
			s += "• %s\n" % l
		s += "\n"
	var news: Array = rep["news"]
	if not news.is_empty():
		s += UIKit.col("Thiên hạ", UIKit.GOLD) + "\n"
		for e in news:
			s += "• %s\n" % UIKit.col(str(e["t"]), UIKit.RED if str(e["k"]) in ["bien_co", "chien_su"] else UIKit.TEXT)
	if s == "":
		s = UIKit.col("Một tháng bình lặng trôi qua.", UIKit.DIM)
	var r: = UIKit.rich()
	r.custom_minimum_size = Vector2(720, mini(460, 60 + 24 * (lines.size() + news.size() + 3)))
	r.text = s
	body.add_child(r)
	var nch: = PlayerOps.choices(w).size()
	if nch > 0:
		body.add_child(UIKit.wrap_label("Có %d việc đang chờ bạn quyết định." % nch, 15, UIKit.RED))
	var row: = UIKit.hbox()
	row.add_child(UIKit.spacer())
	row.add_child(UIKit.button("  Xem việc chờ  " if nch > 0 else "  Tiếp tục  ", func() -> void :
		UIKit.close_modal(body)
		if not PlayerOps.choices(w).is_empty():
			_choices_modal()))
	body.add_child(row)
