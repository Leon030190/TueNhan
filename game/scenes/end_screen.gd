extends Control


var main: Node
var w: World


func setup(m: Node, world: World) -> void :
	main = m
	w = world


func _ready() -> void :
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	Music.set_context("trung_sinh")
	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var col: = UIKit.vbox(10)
	col.custom_minimum_size = Vector2(1040, 0)
	center.add_child(col)
	var over: = str(w.play["over"])
	var ending: = str(w.play.get("ending", ""))
	var p: = w.player()
	var title: = "%d năm đã qua" % roundi(PlayerOps.end_m(w) / 12.0)
	if over == "death":
		title = "Vòng đời kết thúc"
	elif ending != "":
		title = str(Endings.NAMES.get(ending, ending))
	var tl: = UIKit.label(title, 40, UIKit.PURPLE if ending != "" else UIKit.GOLD)
	tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(tl)
	if ending != "":
		var dl: = UIKit.wrap_label(str(Endings.DESCS.get(ending, "")), 17, UIKit.TEXT)
		dl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col.add_child(dl)
	var sub: = UIKit.wrap_label(
		("%s qua đời năm %d tuổi (%s)." % [p.name, p.age(p.death_m), p.death_cause]) if not p.alive else
		"%s, %d tuổi. %s nay là %s. %s." % [p.name, p.age(w.m), w.clan["name"], PlayerOps.CLAN_TIER_NAMES[PlayerOps.clan_tier(w)], World.date_cap(w.m)], 16, UIKit.DIM)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(sub)

	var sc: = PlayerOps.score(w)
	var lsum: Dictionary = w.play.get("legacy_sum", {})
	var s: = "[table=2]"
	for k in sc["parts"]:
		s += "[cell]%s   [/cell][cell]%s[/cell]" % [k, UIKit.col(str(roundi(float(sc["parts"][k]))), UIKit.GOLD)]
	s += "[cell]%s[/cell][cell]%s[/cell][/table]" % [UIKit.col("Điểm Thiên Mệnh", UIKit.GOLD), UIKit.col("[font_size=24]%d[/font_size]" % roundi(float(sc["total"])), UIKit.GOLD)]
	if not lsum.is_empty():
		s += "\n%s +%d   ·   Thiên Thư ghi thêm %d người (tổng %d ở thế giới này)\n" % [UIKit.col("Thiên Cơ", UIKit.PURPLE), int(lsum["thien_co"]), int(lsum["added"]), int(lsum["total"])]
	var st: Dictionary = w.play["stats"]
	s += "\nĐã gặp %d người · thẩm định %d lần · chiêu mộ %d · tiến cử %d (sang nước khác %d) · tiên đoán ứng nghiệm %d" % [int(st["met"]), int(st["appraised"]), int(st["recruited"]), int(st["recommended"]), int(st["foreign"]), int(st["predicted"])]
	var sh: = Endings.share(w)
	s += "\nNgười của bạn nắm %d / %d ghế chủ chốt khắp thiên hạ · thiên hạ còn %d nước" % [int(sh[0]), int(sh[1]), w.nations.size()]
	s += "\n\n" + UIKit.col("Những người bạn đưa ra giúp đời", UIKit.GOLD) + "\n"
	var any: = false
	for id in w.play["recommended"]:
		var c: = w.ch(str(id))
		if c == null:
			continue
		any = true
		var ti: = c.top_real()
		s += "• %s — %s · %s %d\n" % [c.name, PlayerOps.public_status(w, c), Defs.STAT_NAMES[ti], roundi(c.real[ti])]
	if not any:
		s += UIKit.col("(chưa tiến cử ai)\n", UIKit.DIM)
	s += "\n" + UIKit.col("Môn khách còn lại", UIKit.GOLD) + "\n"
	var rs: = PlayerOps.retainers(w)
	for c: Character in rs:
		var ti: = c.top_real()
		s += "• %s — %s %d / tiềm năng %d\n" % [c.name, Defs.STAT_NAMES[ti], roundi(c.real[ti]), roundi(c.pot[c.top_pot()])]
	if rs.is_empty():
		s += UIKit.col("(không có)\n", UIKit.DIM)
	var r: = UIKit.rich()
	r.custom_minimum_size = Vector2(1040, 430)
	r.text = s
	col.add_child(UIKit.panel(r, UIKit.PANEL, 14))
	var note: = UIKit.wrap_label("Trùng sinh: thế giới trở lại y hệt, bạn mang Mệnh cách mới. Thiên Thư giữ người đã gặp; Thiên Cơ dùng để nâng cấp ở màn đầu.", 14, UIKit.DIM)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(note)
	var row: = UIKit.hbox(10)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(UIKit.button("  Trùng sinh (vòng đời %d)  " % (main.legacy.lives_of(w.world_seed) + 1), func() -> void : main.show_start(w.life + 1, w.world_seed)))
	row.add_child(UIKit.button("Thế giới mới", func() -> void : main.show_start(1, randi_range(1, 999999))))
	row.add_child(UIKit.button("Xem thế giới (debug)", func() -> void : main.open_debug(w)))
	col.add_child(row)
