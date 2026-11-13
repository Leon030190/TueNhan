extends Node





const GOOD_POT: = 66.0
const READY: = 45.0
const BROKER: = 42.0
const RESERVE: = 500.0
const SPEEDS: = [1.2, 0.7, 0.4, 0.2, 0.08]
const CHOICE_PREF: = ["Giữ lại", "Ra mặt bảo vệ", "Đề phòng", "Giúp đỡ", "Đồng ý", "Góp vốn", "Tự đấu"]

var main: Node
var speed: = 2
var paused: = false
var lives_left: = 1
var step_n: = 0
var hud: Label
var mem: = {}


func setup(m: Node, lives: int) -> void :
	main = m
	lives_left = lives


func _ready() -> void :
	var layer: = CanvasLayer.new()
	layer.layer = 50
	add_child(layer)
	var box: = PanelContainer.new()
	box.add_theme_stylebox_override("panel", UIKit.sb(Color(0.08, 0.07, 0.05, 0.92), UIKit.GOLD, 8))
	box.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	box.position = Vector2(412, -44)
	box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(box)
	hud = Label.new()
	hud.add_theme_font_size_override("font_size", 14)
	hud.add_theme_color_override("font_color", UIKit.GOLD)
	box.add_child(hud)
	mem = {"m": -1, "dry": {}}
	_loop()


func _unhandled_key_input(e: InputEvent) -> void :
	if not (e is InputEventKey and e.pressed):
		return
	match (e as InputEventKey).keycode:
		KEY_SPACE:
			paused = not paused
		KEY_EQUAL, KEY_KP_ADD:
			speed = mini(speed + 1, SPEEDS.size() - 1)
		KEY_MINUS, KEY_KP_SUBTRACT:
			speed = maxi(speed - 1, 0)
		KEY_ESCAPE:
			stop()


func stop() -> void :
	if main != null and main.has_method("bot_stopped"):
		main.bot_stopped()
	queue_free()


func _say(t: String) -> void :
	if OS.get_cmdline_user_args().has("--bot_print"):
		var g: Node = main.current if main != null else null
		print("[%d] %s · %s" % [step_n, World.date_cap(g.w.m) + " ngày %d" % (PlayerOps.day(g.w) + 1) if g != null and "w" in g and g.w != null else "", t])
	hud.text = "Bot%s: %s  ·  tốc độ %d/%d (+/−) · Space dừng · Esc tắt" % [" (tạm dừng)" if paused else "", t, speed + 1, SPEEDS.size()]


func _loop() -> void :
	while is_inside_tree():
		await get_tree().create_timer(SPEEDS[speed]).timeout
		if not is_inside_tree():
			return
		if paused:
			_say("…")
			continue
		step_n += 1
		await _step()




func _buttons(root: Node, prefix: String, out: Array) -> void :
	if root is Button:
		var b: = root as Button
		if b.text.strip_edges().begins_with(prefix) and not b.disabled and b.is_visible_in_tree():
			out.append(b)
	for ch in root.get_children():
		_buttons(ch, prefix, out)


func _find(root: Node, prefix: String) -> Button:
	var out: Array = []
	_buttons(root, prefix, out)
	return null if out.is_empty() else out[0]



func _press(b: Button, what: String) -> void :
	_say(what)
	var old: = b.modulate
	b.modulate = Color(1.6, 1.4, 0.7)
	await get_tree().create_timer(minf(0.35, SPEEDS[speed] * 0.6)).timeout
	if is_instance_valid(b):
		b.modulate = old
		b.pressed.emit()



func _modal(g: Node) -> Array:
	var top: Control = null
	for ch in g.get_children():
		if ch is Control and ch.get_child_count() == 2 and ch.get_child(0) is ColorRect and not (ch as Control).is_queued_for_deletion():
			top = ch
	if top == null:
		return []
	return [top, _first_label(top)]


func _first_label(n: Node) -> String:
	if n is Label:
		return (n as Label).text
	for ch in n.get_children():
		var t: = _first_label(ch)
		if t != "":
			return t
	return ""




func _step() -> void :
	var cur: Node = main.current
	if cur == null:
		return
	var sname: = str(cur.get_script().resource_path.get_file())
	if sname == "end_screen.gd":
		if lives_left <= 1:
			_say("Hết đời, bot dừng.")
			stop()
			return
		var tb: = _find(cur, "Trùng sinh")
		if tb != null:
			lives_left -= 1
			await _press(tb, "Trùng sinh")
		return
	if sname == "start_screen.gd":
		var cb: = _find(cur, "Chọn mệnh này")
		if cb != null:
			await _press(cb, "Chọn Mệnh cách đầu tiên")
		return
	if sname != "game_screen.gd":
		return
	var g: Node = cur
	var w: World = g.w
	if mem["m"] != w.m:
		mem = {"m": w.m, "dry": mem.get("dry", {}), "scouted": false, "trained": false, "tries": {}, "appraised": {}}
	var md: = _modal(g)
	if not md.is_empty():
		await _handle_modal(g, w, md[0], str(md[1]))
		return
	await _decide(g, w)




func _handle_modal(g: Node, w: World, m: Control, title: String) -> void :
	if title.begins_with("Báo cáo đầu"):
		var b: = _find(m, "Xem việc chờ")
		await _press(b if b != null else _find(m, "Tiếp tục"), "Đọc báo cáo tháng")
	elif title.begins_with("Việc chờ"):
		for pref in CHOICE_PREF:
			var b: = _find(m, pref)
			if b != null:
				await _press(b, "Việc chờ: " + pref)
				return
		var all: Array = []
		_buttons(m, "", all)
		for b: Button in all:
			if b.text != "✕":
				await _press(b, "Việc chờ: " + b.text)
				return
	elif title.ends_with("nhận lời"):
		var nc: = _sel_char(g, w)
		if nc != null and PlayerOps.STUDY_TASKS.has(_best_task(w, nc)):
			await _press(_find(m, "Cho đi học"), "Cho người mới đi học")
		else:
			await _press(_find(m, "Giao việc ngay"), "Giao việc cho người mới")
	elif title.ends_with("từ chối"):
		await _press(_find(m, "Đóng"), "Bị từ chối")
	elif title.begins_with("Chiêu mộ") or title.begins_with("Lôi kéo"):
		var bs: Array = []
		_buttons(m, "Mời", bs)
		if bs.is_empty():
			await _press(_find(m, "✕"), "Không đủ tiền mời")
			return
		var lavish: = bs.size() > 1 and PlayerOps.money(w) > 2.0 * RESERVE + 600.0
		await _press(bs[1] if lavish else bs[0], "Mời (%s)" % ("hậu đãi" if lavish else "đãi ngộ thường"))
	elif title.begins_with("Giao việc cho") or title.begins_with("Đào tạo"):
		var c: = _sel_char(g, w)
		var task: = _best_task(w, c)
		var idx: = PlayerOps.task_list(title.begins_with("Đào tạo")).find(task)
		var all2: Array = []
		_all_buttons(m, "Chọn", all2)
		if idx >= 0 and idx < all2.size() and not (all2[idx] as Button).disabled:
			await _press(all2[idx], "Giao việc: " + str(PlayerOps.TASKS[task]["name"]))
		else:
			await _press(_find(m, "✕"), "Giữ việc cũ")
	elif title.begins_with("Tự tu dưỡng"):
		var b3: = _row_button_with_label(m, "nên rèn", "Rèn luyện")
		await _press(b3 if b3 != null else _find(m, "Rèn luyện"), "Rèn chỉ số nên rèn")
	elif title.begins_with("Tu dưỡng lần thứ 2"):
		await _press(_find(m, "Thôi"), "Không rèn lần 2 (chỉ được nửa)")
	elif title.begins_with("Tiến cử"):
		var bs4: Array = []
		_buttons(m, "Tiến cử", bs4)
		if bs4.is_empty():
			await _press(_find(m, "✕"), "Không ghế nào đủ sức")
		else:
			await _press(bs4[mini(1, bs4.size() - 1)], "Tiến cử vào ghế")
	elif title.begins_with("Thăm hỏi"):
		var bs5: Array = []
		_buttons(m, "Thăm", bs5)
		if bs5.is_empty():
			await _press(_find(m, "✕"), "Đóng")
		else:
			await _press(bs5[mini(1, bs5.size() - 1)] if PlayerOps.money(w) > 800.0 else bs5[0], "Thăm hỏi")
	else:
		var x: = _find(m, "✕")
		if x != null:
			await _press(x, "Đóng hộp \"%s\"" % title)


func _all_buttons(root: Node, prefix: String, out: Array) -> void :
	if root is Button and (root as Button).text.strip_edges().begins_with(prefix):
		out.append(root)
	for ch in root.get_children():
		_all_buttons(ch, prefix, out)


func _row_button_with_label(root: Node, label: String, prefix: String) -> Button:
	if root is HBoxContainer:
		var has: = false
		var btn: Button = null
		for ch in root.get_children():
			if ch is Label and (ch as Label).text == label:
				has = true
			if ch is Button and (ch as Button).text.begins_with(prefix) and not (ch as Button).disabled:
				btn = ch
		if has and btn != null:
			return btn
	for ch in root.get_children():
		var r: = _row_button_with_label(ch, label, prefix)
		if r != null:
			return r
	return null


func _sel_char(g: Node, w: World) -> Character:
	var s: = str(g.sel)
	return w.ch(s.split(":")[1]) if s.begins_with("npc:") else null


func _best_task(w: World, c: Character) -> String:
	if c == null:
		return ""
	var t: String = ["quan_doanh", "hoc_vien", "quan_doanh", "hoc_vien", "cong_xuong", "thuong_hoi"][c.top_pot()]
	if not PlayerOps.at_house(w, c):
		t = "ho_ve" if c.top_pot() == Defs.VO else "thuyet_khach"
	return t




func _decide(g: Node, w: World) -> void :

	if not PlayerOps.choices(w).is_empty():
		var vb: = _find(g, "Việc chờ")
		if vb != null:
			await _press(vb, "Mở Việc chờ")
			return
	var here: = PlayerOps.here(w)

	if not PlayerOps.capital_nations(w).is_empty():
		for c: Character in PlayerOps.retainers(w):
			if c.max_real() >= READY and PlayerOps.recommend_block(w, c) == "" and _has_seat(w, c):
				await _open_and_press(g, "npc:" + c.id, "Tiến cử (", "Tiến cử %s" % c.name)
				return

	var ready: Array = []
	for c: Character in PlayerOps.retainers(w):
		if c.max_real() >= READY and c.age(w.m) >= 18:
			ready.append(c)
	var cap: = str(w.nations[w.player().nation_id]["capital"]) if w.nations.has(w.player().nation_id) else here
	var want: = cap if not ready.is_empty() else _hunt_city(w)
	if want != here and PlayerOps.days_left(w) >= 6:
		for c: Character in ready:
			if PlayerOps.at_house(w, c) and str(PlayerOps.loc(w, c)["city"]) == here and PlayerOps.follow_count(w) < PlayerOps.follow_cap(w):
				await _open_and_press(g, "npc:" + c.id, "Theo hầu", "%s theo hầu lên kinh" % c.name)
				return
		var hop: = _next_hop(w, here, want)
		var mb: Button = g.map_view.buttons.get(hop, null)
		if mb != null and mb.is_visible_in_tree():
			g.map_view.animate = true
			await _press(mb, "Đi tới %s (bấm trên bản đồ)" % w.city_name(hop))
			return

	if not bool(mem["scouted"]) and PlayerOps.days_left(w) >= 10:
		mem["scouted"] = true
		var sb: = _find(g, "Dò la")
		if sb != null:
			var nl: = (w.play["leads"] as Array).size()
			await _press(sb, "Dò la ở %s" % w.city_name(here))
			if (w.play["leads"] as Array).size() == nl and str(g.msg_lbl.text).contains("không còn ai"):
				mem["dry"][here] = w.m
			return

	for l in w.play["leads"]:
		var id: = str(l["id"])
		if str(l["city"]) != here or int(mem["tries"].get(id, 0)) >= 2 or PlayerOps.days_left(w) < 3:
			continue
		mem["tries"][id] = int(mem["tries"].get(id, 0)) + 1
		await _open_and_press(g, "lead:" + id, "Tìm gặp", "Tìm gặp người trong lời đồn")
		return

	for c: Character in w.living():
		if c.is_player or c.city_id != here or PlayerOps.is_retainer(w, c) or not PlayerOps.met_now(w, c) or c.office_key != "" or c.nation_id != "":
			continue
		if not mem["appraised"].has(c.id):
			mem["appraised"][c.id] = true
			var tier: = mini(PlayerOps.eye_tier(w), 3)
			while tier > 1 and int(w.play["eye"]) < int(Defs.TIER_COST[tier]):
				tier -= 1
			if PlayerOps.appraise_redundant(w, c, tier) == "" and int(w.play["eye"]) >= int(Defs.TIER_COST[tier]):
				await _open_and_press(g, "npc:" + c.id, Defs.TIER_NAMES[tier] + " ·", "Thẩm định %s tầng %s" % [c.name, Defs.TIER_NAMES[tier]])
				return
		var rec: Dictionary = w.notebook.get(c.id, {}).get("appr", {})
		if rec.is_empty() or mem["appraised"].get(c.id) is String:
			continue
		mem["appraised"][c.id] = "xong"
		var lo: = 0.0
		var hi: = 0.0
		for i in Defs.N_STATS:
			lo = maxf(lo, float(rec["real"][i][0]))
			if not (rec["pot"][i] as Array).is_empty():
				hi = maxf(hi, (float(rec["pot"][i][0]) + float(rec["pot"][i][1])) / 2.0)
		if lo >= BROKER and PlayerOps.recommend_block(w, c) == "" and _has_seat(w, c):
			await _open_and_press(g, "npc:" + c.id, "Tiến cử (", "Tiến cử luôn %s (đã có thực lực)" % c.name)
			return
		if hi >= GOOD_POT and PlayerOps.recruit_block(w, c) == "" and PlayerOps.money(w) > float(PlayerOps.recruit_preview(w, c, false)["fee"]) + RESERVE:
			if float(PlayerOps.recruit_preview(w, c, true)["chance"]) < 0.25 and PlayerOps.visit_block(w, c) == "":
				mem["appraised"][c.id] = true
				await _open_and_press(g, "npc:" + c.id, "Thăm hỏi", "Thăm hỏi %s trước khi mời" % c.name)
				return
			await _open_and_press(g, "npc:" + c.id, "Chiêu mộ (", "Chiêu mộ %s (tiềm năng ~%d)" % [c.name, roundi(hi)])
			return

	for c: Character in PlayerOps.retainers(w):
		if PlayerOps.is_following(w, c) and c.max_real() < READY and PlayerOps.house_cap(w, here) > PlayerOps.house_count(w, here):
			await _open_and_press(g, "npc:" + c.id, "Để lại tư trạch", "%s ở lại tư trạch rèn luyện" % c.name)
			return

	if not bool(mem["trained"]) and PlayerOps.days_left(w) >= 8 and PlayerOps.trained_this_month(w) == 0:
		mem["trained"] = true
		await _open_and_press(g, "self", "Tự tu dưỡng", "Tự tu dưỡng")
		return

	var rb: = _find(g, "Nghỉ hết tháng")
	if rb != null:
		await _press(rb, "Nghỉ hết tháng")


func _has_seat(w: World, c: Character) -> bool:
	for o in PlayerOps.recommend_options(w, c):
		if bool(o["ok"]) and not bool(o["foreign"]) and not bool(o["mine"]):
			return true
	return false



func _open_and_press(g: Node, sel: String, prefix: String, what: String) -> void :
	_say(what)
	g.select(sel)
	await get_tree().create_timer(minf(0.3, SPEEDS[speed] * 0.5)).timeout
	var b: = _find(g, prefix)
	if b != null:
		await _press(b, what)
	else:
		_say(what + " (không bấm được)")


func _hunt_city(w: World) -> String:
	var here: = PlayerOps.here(w)
	var best: = here
	var bd: = 1 << 30
	for cid in w.cities:
		if w.city_nation(cid) != w.player().nation_id or w.m - int(mem["dry"].get(cid, -99)) < 6:
			continue
		var d: = PlayerOps.path_days(w, here, str(cid))
		if d >= 0 and d < bd:
			bd = d
			best = str(cid)
	return best


func _next_hop(w: World, from: String, to: String) -> String:
	var best: = ""
	var bd: = 1 << 30
	for nb in w.cities[from]["links"]:
		var d: = PlayerOps.path_days(w, str(nb), to)
		if d >= 0 and d < bd:
			bd = d
			best = str(nb)
	return best
