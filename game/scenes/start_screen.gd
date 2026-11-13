extends Control


var main: Node
var life: = 1
var world_seed: = 1
var reroll: = 0
var cards: HBoxContainer
var seed_box: SpinBox
var years_opt: OptionButton
var intro: Label
var legacy_txt: RichTextLabel
var reroll_btn: Button


func setup(m: Node, _life_n: int, seed_v: int) -> void :
	main = m
	world_seed = seed_v


func _ready() -> void :
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	Music.set_context("chu_de")

	var margin: = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var safe: Rect2i = DisplayServer.get_display_safe_area()
	var win: Vector2i = DisplayServer.window_get_size()
	var pad_l: int = 16
	var pad_r: int = 16
	if win.x > 0 and safe.size.x > 0:
		var sx: float = get_viewport_rect().size.x / float(win.x)
		pad_l = maxi(16, int(safe.position.x * sx) + 4)
		pad_r = maxi(16, int((win.x - (safe.position.x + safe.size.x)) * sx) + 4)
	margin.add_theme_constant_override("margin_left", pad_l)
	margin.add_theme_constant_override("margin_right", pad_r)
	add_child(margin)

	var scroll: = ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	margin.add_child(scroll)
	var outer: = UIKit.hbox(0)
	outer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(outer)
	outer.add_child(UIKit.spacer())
	var col: = UIKit.vbox(10)
	col.custom_minimum_size.x = 1220
	col.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer.add_child(col)
	outer.add_child(UIKit.spacer())
	var top: = Control.new()
	top.custom_minimum_size.y = 6
	col.add_child(top)

	var trow: = UIKit.hbox(14)
	var back: = UIKit.button("← Menu", func() -> void : main.show_menu(), "Về menu chính")
	back.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	trow.add_child(back)
	trow.add_child(UIKit.spacer())
	trow.add_child(UIKit.label("TUỆ NHÃN", 44, UIKit.GOLD))
	var st: = UIKit.label("Thức Anh Hùng", 20, UIKit.DIM)
	st.size_flags_vertical = Control.SIZE_SHRINK_END
	trow.add_child(st)
	trow.add_child(UIKit.spacer())
	var gb: = UIKit.button("Hướng dẫn", func() -> void : Guide.open(self), "Cách chơi, giao diện, các hệ thống")
	gb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	trow.add_child(gb)
	col.add_child(trow)

	intro = UIKit.wrap_label("", 15, UIKit.TEXT)
	var how: = UIKit.rich(true)
	how.text = UIKit.col("Cách chơi: ", UIKit.GOLD) + UIKit.col("[b]Dò la[/b] → [b]Gặp gỡ[/b] → [b]Thẩm định[/b] bằng Đôi Mắt → [b]Chiêu mộ[/b] ngọc thô, nuôi dạy → lên kinh đô [b]Tiến cử[/b]. Xem nút [b]Hướng dẫn[/b] ở góc trên để biết thêm.", UIKit.DIM)
	var ibox: = UIKit.vbox(4)
	ibox.add_child(intro)
	ibox.add_child(how)
	col.add_child(UIKit.panel(ibox, UIKit.PANEL, 10))

	var lrow: = UIKit.hbox(10)
	legacy_txt = UIKit.rich(true)
	legacy_txt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	legacy_txt.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	lrow.add_child(legacy_txt)
	lrow.add_child(UIKit.button("Nâng cấp (Thiên Cơ)", _shop_modal, "Dùng Thiên Cơ tích lũy qua các đời để nâng cấp"))
	col.add_child(UIKit.panel(lrow, UIKit.PANEL2, 8))

	var srow: = UIKit.hbox(10)
	srow.alignment = BoxContainer.ALIGNMENT_CENTER
	srow.add_child(UIKit.label("Thế giới số", 15, UIKit.DIM))
	seed_box = SpinBox.new()
	seed_box.min_value = 1
	seed_box.max_value = 999999
	seed_box.value = world_seed
	seed_box.custom_minimum_size.x = 130
	seed_box.value_changed.connect( func(v: float) -> void :
		world_seed = int(v)
		reroll = 0
		_refresh())
	srow.add_child(seed_box)
	srow.add_child(UIKit.button("Ngẫu nhiên", func() -> void : seed_box.value = randi_range(1, 999999)))
	srow.add_child(UIKit.label("   Độ dài một đời", 15, UIKit.DIM))
	years_opt = OptionButton.new()
	for y in [10, 20, 30]:
		years_opt.add_item("%d năm" % y)
	srow.add_child(years_opt)
	col.add_child(srow)

	var hrow: = UIKit.hbox(10)
	hrow.add_child(UIKit.label("Chọn Mệnh cách", 20, UIKit.GOLD))
	hrow.add_child(UIKit.spacer())
	reroll_btn = UIKit.button("Tung lại Mệnh cách (1 lần)", func() -> void :
		reroll = 1
		_refresh(), "Nâng cấp Khởi đầu cấp 4")
	hrow.add_child(reroll_btn)
	col.add_child(hrow)
	cards = UIKit.hbox(10)
	cards.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(cards)
	var bottom: = Control.new()
	bottom.custom_minimum_size.y = 6
	col.add_child(bottom)
	_refresh()


func _refresh() -> void :
	var lg: Legacy = main.legacy
	life = lg.lives_of(world_seed) + 1
	var bk: = lg.book(world_seed).size()
	if life > 1:
		intro.text = "Thế giới số %d · vòng đời thứ %d. Thế giới vẫn như cũ, những con người ấy vẫn ở đó, nhưng bạn đã tái sinh với một mệnh cách mới. Thiên Thư còn ghi %d người." % [world_seed, life, bk]
	else:
		intro.text = "Bạn là con cháu Tô gia, một gia tộc quý tộc nhỏ ở Lạc Thủy, sinh ra với Đôi Mắt Thẩm Định: nhìn thấu chỉ số, tiềm năng và thiên phú của người khác. Triều đình chỉ thấy bề ngoài; bạn thấy được người ta có thể trở thành ai."
	var ups: Array = []
	for b in Legacy.UPGRADE_ORDER:
		ups.append("%s %d" % [Legacy.UPGRADES[b]["name"], lg.level(b)])
	var ends: Array = []
	for e in lg.endings:
		ends.append("%s ×%d" % [Endings.NAMES.get(e, e), int(lg.endings[e])])
	legacy_txt.text = "%s %s   ·   Nâng cấp: %s   ·   Đã sống %d đời%s" % [
		UIKit.col("Thiên Cơ", UIKit.PURPLE), UIKit.col(str(lg.thien_co), UIKit.GOLD), ", ".join(ups), lg.history.size(), 
		("   ·   Kết thúc đã đạt: " + ", ".join(ends)) if not ends.is_empty() else ""]
	reroll_btn.visible = lg.can_reroll()
	reroll_btn.disabled = reroll > 0
	_fill_cards()


func _fill_cards() -> void :
	for ch in cards.get_children():
		ch.queue_free()
	var lg: Legacy = main.legacy
	var opts: = WorldGen.roll_destinies(world_seed, life, lg.destiny_count(), reroll)
	var wcard: = 1200.0 / opts.size() - 10.0
	for k in opts.size():
		var d: Dictionary = opts[k]
		var v: = UIKit.vbox(4)
		v.custom_minimum_size.x = wcard
		v.add_child(UIKit.label(str(d["name"]), 22, UIKit.PURPLE))
		v.add_child(UIKit.label("Thiên hướng: " + str(d["hint"]), 15, UIKit.TEXT))
		var r: = UIKit.rich(true)
		var s: = "[table=3][cell]%s   [/cell][cell]%s   [/cell][cell]%s[/cell]" % [UIKit.col("Chỉ số", UIKit.DIM), UIKit.col("Thực", UIKit.DIM), UIKit.col("Tiềm năng", UIKit.DIM)]
		for i in Defs.N_STATS:
			var rv: = float(d["real"][i])
			var pv: = float(d["pot"][i])
			s += "[cell]%s   [/cell][cell]%s   [/cell][cell]%s[/cell]" % [Defs.STAT_NAMES[i], UIKit.col(str(roundi(rv)), UIKit.grade_color(rv)), UIKit.col(str(roundi(pv)), UIKit.grade_color(pv))]
		s += "[cell]Mị lực   [/cell][cell]%s   [/cell][cell]%s[/cell][/table]\n" % [UIKit.col(str(roundi(float(d["mi_real"]))), UIKit.grade_color(float(d["mi_real"]))), UIKit.col(str(roundi(float(d["mi_pot"]))), UIKit.grade_color(float(d["mi_pot"])))]
		s += "Ngộ tính: %s\n" % Defs.NGO_NAMES[int(d["ngo"])]
		for tl in d["talents"]:
			var td: = GameData.talent(str(tl))
			s += "%s %s\n%s\n" % [UIKit.col(str(td["name"]), UIKit.GOLD), UIKit.col("[%s]" % Defs.RARITY_NAMES[int(td["rarity"])], UIKit.DIM), UIKit.col(str(td.get("desc", "")), UIKit.DIM)]
		r.text = s
		v.add_child(r)
		var sp: = Control.new()
		sp.size_flags_vertical = Control.SIZE_EXPAND_FILL
		v.add_child(sp)
		var idx: int = k
		v.add_child(UIKit.button("Chọn mệnh này", func() -> void :
			main.start_game(world_seed, life, idx, reroll, [10, 20, 30][years_opt.selected])))
		var p: = UIKit.panel(v, UIKit.PANEL, 10)
		p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		p.size_flags_vertical = Control.SIZE_EXPAND_FILL
		cards.add_child(p)


func _shop_modal() -> void :
	var lg: Legacy = main.legacy
	var body: = UIKit.modal(self, "Nâng cấp bằng Thiên Cơ (đang có %d)" % lg.thien_co, 820)
	body.add_child(UIKit.wrap_label("Thiên Cơ nhận được khi kết thúc mỗi vòng đời: theo Điểm Thiên Mệnh, kết thúc đạt được và số lời tiên đoán ứng nghiệm. Nâng cấp giữ mãi qua mọi đời, mọi thế giới.", 14, UIKit.DIM))
	for b in Legacy.UPGRADE_ORDER:
		var ud: Dictionary = Legacy.UPGRADES[b]
		var box: = UIKit.vbox(4)
		var head: = UIKit.hbox(10)
		head.add_child(UIKit.label("%s – cấp %d" % [ud["name"], lg.level(b)], 18, UIKit.GOLD))
		head.add_child(UIKit.spacer())
		var cost: = lg.next_cost(b)
		var bid: String = b
		var btn: = UIKit.button("Mua cấp tiếp (%d)" % cost if cost >= 0 else "Đã tối đa", func() -> void :
			lg.buy(bid)
			main.save_legacy()
			UIKit.close_modal(body)
			_refresh()
			_shop_modal())
		btn.disabled = cost < 0 or lg.thien_co < cost
		head.add_child(btn)
		box.add_child(head)
		var lvls: Array = ud["levels"]
		for i in lvls.size():
			var owned: = i < lg.level(b)
			box.add_child(UIKit.label("%s Cấp %d (%d): %s" % ["✓" if owned else "·", i + 1, int(lvls[i]["cost"]), lvls[i]["desc"]], 14, UIKit.GREEN if owned else UIKit.DIM))
		body.add_child(UIKit.panel(box, UIKit.PANEL, 10))
