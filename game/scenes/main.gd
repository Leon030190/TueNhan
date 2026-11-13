extends Control














const SAVE_PATH: = "user://save.sav"
const LEGACY_PATH: = "user://legacy.sav"
const StartScreen: = preload("res://game/scenes/start_screen.gd")
const MenuScreen: = preload("res://game/scenes/menu_screen.gd")
const GameScreen: = preload("res://game/scenes/game_screen.gd")
const EndScreen: = preload("res://game/scenes/end_screen.gd")

var current: Control
var args: = {}
var save_path: = SAVE_PATH
var legacy_path: = LEGACY_PATH
var legacy: Legacy



const OLD_USER_DIR: = "Thiên Mệnh- Người Định Đoạt Thiên Hạ"
const CARRY_FILES: = ["save.sav", "legacy.sav", "settings.cfg"]




static func carry_old_saves() -> void :
	var old: = OS.get_data_dir().path_join("Godot/app_userdata").path_join(OLD_USER_DIR)
	if not DirAccess.dir_exists_absolute(old):
		return
	for f in CARRY_FILES:
		var src: = old.path_join(str(f))
		var dst: = ProjectSettings.globalize_path("user://" + str(f))
		if FileAccess.file_exists(src) and not FileAccess.file_exists(dst):
			DirAccess.make_dir_recursive_absolute(dst.get_base_dir())
			DirAccess.copy_absolute(src, dst)


const UiBot: = preload("res://game/scenes/ui_bot.gd")
var bot: Node = null



func toggle_bot(lives: int = 1) -> void :
	if bot != null and is_instance_valid(bot):
		bot.stop()
		return
	bot = UiBot.new()
	bot.setup(self, lives)
	add_child(bot)


func bot_stopped() -> void :
	bot = null


func _ready() -> void :
	if DisplayServer.has_method("screen_set_orientation"):
		DisplayServer.screen_set_orientation(DisplayServer.SCREEN_SENSOR_LANDSCAPE)
	carry_old_saves()
	theme = UIKit.make_theme()
	var bg: = ColorRect.new()
	bg.color = UIKit.BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	for a in OS.get_cmdline_user_args():
		var kv: = a.trim_prefix("--").split("=", true, 1)
		args[kv[0]] = kv[1] if kv.size() > 1 else "1"


	if (args.has("shot") or args.has("window")) and DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(1600, 900))
	elif bool(UIKit.pref("fullscreen", false)) and DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	if args.has("legacy_demo"):
		legacy_path = "user://_demo_legacy.sav"
		legacy = _demo_legacy()
	else:
		legacy = Legacy.load_file(legacy_path)
	if args.has("bot"):

		save_path = "user://_bot.sav"
		legacy_path = "user://_bot_legacy.sav"
		legacy = Legacy.load_file(legacy_path)
		var bs: = int(args.get("seed", "7"))
		start_game(bs, legacy.lives_of(bs) + 1, int(args.get("menh", "0")), 0, int(args.get("years", "10")))
		toggle_bot(int(args.get("lives", "1")))
		if args.has("speed"):
			bot.speed = clampi(int(args["speed"]) - 1, 0, 4)
	elif args.has("auto"):
		var parts: = str(args["auto"]).split(":")
		var sd: = int(parts[0])
		start_game(sd, legacy.lives_of(sd) + 1, int(parts[1]) if parts.size() > 1 else 0)
		_scripted()
	elif args.has("start_modal") or args.has("start"):
		show_start(1, int(args.get("seed", str(randi_range(1, 999999)))))
		if str(args.get("start_modal", "")) == "shop":
			current._shop_modal()
	else:
		show_menu()
		if args.has("guide"):
			Guide.open(current, int(args["guide"]))
		elif not args.has("shot") and not args.has("no_intro"):
			play_intro()
	if args.has("shot"):
		for k in 6:
			await get_tree().process_frame
		if args.has("shot_wait"):
			await get_tree().create_timer(float(args["shot_wait"])).timeout
		get_viewport().get_texture().get_image().save_png(str(args["shot"]))
		get_tree().quit()


const INTRO_PATH: = "res://assets/art/promo/intro.ogv"



func play_intro() -> void :
	if not ResourceLoader.exists(INTRO_PATH) and not FileAccess.file_exists(INTRO_PATH):
		return
	var stream: = VideoStreamTheora.new()
	stream.file = INTRO_PATH
	var layer: = ColorRect.new()
	layer.color = Color.BLACK
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	var vp: = VideoStreamPlayer.new()
	vp.stream = stream
	vp.expand = true
	vp.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(vp)
	var hint: = UIKit.label("Bấm phím bất kỳ để bỏ qua", 12, Color(UIKit.DIM, 0.7))
	hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	hint.position -= Vector2(210, 28)
	layer.add_child(hint)
	add_child(layer)
	Music.hold()
	var done: = func() -> void :
		if not is_instance_valid(layer) or layer.has_meta("closing"):
			return
		layer.set_meta("closing", true)
		Music.release()
		var tw: = create_tween()
		tw.tween_property(layer, "modulate:a", 0.0, 0.5)
		tw.tween_callback(layer.queue_free)
	vp.finished.connect(done)
	layer.gui_input.connect( func(e: InputEvent) -> void :
		if e is InputEventMouseButton and e.pressed:
			done.call())
	_intro_skip = done
	vp.play()


var _intro_skip: Callable


func _unhandled_key_input(e: InputEvent) -> void :
	if _intro_skip.is_valid() and e.is_pressed():
		_intro_skip.call()
		_intro_skip = Callable()


func _swap(c: Control) -> void :
	if current != null:
		current.queue_free()
	current = c
	add_child(c)


func show_menu() -> void :
	var s: = MenuScreen.new()
	s.setup(self)
	_swap(s)


func show_start(life: int, world_seed: int) -> void :
	var s: = StartScreen.new()
	s.setup(self, life, world_seed)
	_swap(s)


func start_game(world_seed: int, life: int, destiny: int, reroll: int = 0, years: int = 10) -> void :
	var w: = WorldGen.generate(world_seed, destiny, life, legacy.destiny_count(), reroll)
	w.play["end_m"] = years * 12
	legacy.apply_to_world(w)
	save_game(w)
	show_game(w)


func save_legacy() -> void :
	legacy.save_file(legacy_path)


func show_game(w: World) -> void :
	var g: = GameScreen.new()
	g.setup(self, w)
	_swap(g)
	if not bool(UIKit.pref("guide_seen", false)) and not args.has("auto") and not args.has("bot") and not args.has("shot"):
		UIKit.set_pref("guide_seen", true)
		Guide.open(g, 0)


func show_end(w: World) -> void :
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	if not bool(w.play.get("recorded", false)):
		w.play["recorded"] = true
		w.play["legacy_sum"] = legacy.record_life(w, str(w.play.get("ending", "")), float(PlayerOps.score(w)["total"]))
		save_legacy()
	var e: = EndScreen.new()
	e.setup(self, w)
	_swap(e)


func save_game(w: World) -> void :
	w.save_file(save_path)


func has_save() -> bool:
	return FileAccess.file_exists(save_path)


func continue_game() -> void :
	var w: = World.load_file(save_path)
	if w != null:
		show_game(w)


func open_debug(_w: World = null) -> void :
	get_tree().change_scene_to_file("res://game/scenes/debug_world.tscn")



func _scripted() -> void :
	var g: = current
	var w: World = g.w
	for k in int(args.get("months", "0")):
		PlayerOps.end_month(w)
	if args.has("demo"):
		PlayerOps.scout(w)
		var leads: Array = w.play["leads"]
		if not leads.is_empty():
			var id: = str(leads[0]["id"])
			PlayerOps.meet(w, id)
			PlayerOps.appraise(w, id, 2)
			g.sel = "npc:" + id
	if args.has("scout"):
		for k in int(args["scout"]):
			w.play["day"] = 0
			PlayerOps.scout(w)
	if args.has("scenario"):
		_scenario_m23(g, w)
	if args.has("city") and w.cities.has(str(args["city"])):
		w.player().city_id = str(args["city"])
		g.refresh_all()
	if args.has("select"):
		g.sel = str(args["select"])
	if args.has("probe"):

		var target: = w.office_holder("bac_nguyen", "thua_tuong#0")
		g.sel = "npc:" + target.id
		if str(args["probe"]) == "done":
			PlayerOps.probe(w, target.id, 1)
			for k in PlayerOps.probe_delay(w, target, 1):
				PlayerOps.end_month(w)
	if str(args.get("end", "")) != "":
		w.play["over"] = "time"
		if str(args["end"]) != "1":
			w.play["ending"] = str(args["end"])
			w.play["over"] = "ending"
		show_end(w)
		return
	g.refresh_all()
	if args.has("tab"):
		g.tabs.current_tab = int(args["tab"])
	if str(args.get("probe", "")) == "modal":
		g._probe_modal(w.ch(g.sel.split(":")[1]))
	if str(args.get("modal", "")) == "office":
		g._office_modal()
	if str(args.get("modal", "")) == "coup":
		g._coup_modal()
	if str(args.get("modal", "")) == "choices":
		g._choices_modal()
	if str(args.get("modal", "")) == "student":
		g._student_modal(PlayerOps.retainers(w)[0])
	match str(args.get("modal", "")):
		"clan":
			g.tabs.current_tab = g.tabs.get_tab_count() - 1
			g.select("clan:" + str(args.get("clan", "luc")))
		"plot":
			for c: Character in w.living():
				if c.city_id == PlayerOps.here(w) and not c.is_player and c.office_key == "" and c.nation_id == "" and not PlayerOps.is_retainer(w, c):
					g._plot_modal(c, "")
					break
		"map":
			g._world_map_modal(str(args.get("view", "")))
		"purse":
			var rs2: = PlayerOps.retainers(w)
			if not rs2.is_empty():
				rs2[0].purse = 420.0
				g._purse_modal(rs2[0])
		"career":
			if g.sel.begins_with("npc:"):
				g._career_modal(w.ch(g.sel.split(":")[1]))
		"recommend":
			var rs3: = PlayerOps.retainers(w)
			if not rs3.is_empty():
				w.player().city_id = str(w.nations[w.player().nation_id]["capital"])
				w.play["ret"][rs3[0].id] = {"st": "follow"}
				rs3[0].city_id = w.player().city_id
				g.refresh_all()
				g._recommend_modal(rs3[0])
		"exam":

			Exam._announce(w, "khoa_cu", w.year())
			var cap: = str(w.nations[w.player().nation_id]["capital"])
			w.player().city_id = cap
			for nid in w.play["exam_season"]["nat"]:
				for c: Character in w.living():
					if c.nation_id == "" and not c.is_player and not c.clan_retainer and w.nation_cities(nid).has(c.city_id) and Exam._fit(c, "khoa_cu"):
						w.play["exam_season"]["nat"][nid]["c"][c.id] = {"home": c.city_id, "st": 1, "at": cap}
						if nid == w.player().nation_id:
							c.city_id = cap
			g.refresh_all()
			g._exam_modal()
		"assign":
			var rs: = PlayerOps.retainers(w)
			if not rs.is_empty():
				if args.has("study"):
					g._study_modal(rs[0])
				else:
					g._assign_modal(rs[0])
		"items":

			w.clan["workshops"] = 1
			for kq in [["y_phuc", 2], ["binh_khi", 1], ["toa_ky", 2]]:
				Items.buy(w, str(kq[0]), int(kq[1]))
			Items.equip(w, int(Items.store(w)[0]["uid"]), w.player_id)
			g.refresh_all()
			g._items_modal(w.player_id)
		"report":
			var rep: = PlayerOps.end_month(w)
			g.refresh_all()
			g.show_report(rep)
		"train":
			g._train_modal()
		"detail":
			var dc: = w.ch(g.sel.split(":")[1]) if g.sel.begins_with("npc:") else w.player()
			g._char_detail_modal(dc)
			if args.has("page"):
				await get_tree().process_frame
				var tcs: = g.find_children("*", "TabContainer", true, false)
				(tcs[tcs.size() - 1] as TabContainer).current_tab = int(args["page"])
		"recruit_ok", "recruit_no":
			var rc: = w.ch(g.sel.split(":")[1]) if g.sel.begins_with("npc:") else null
			if rc != null:
				g._recruit_result(rc, {"accepted": true, "fee": 312, "salary": 9, "slot": "house"} if str(args["modal"]) == "recruit_ok"
					else {"accepted": false, "until": w.m + 6, "why": "Tham vọng của họ"})
		"recruit", "recommend", "visit":
			var c: = w.ch(g.sel.split(":")[1]) if g.sel.begins_with("npc:") else null
			if c != null:
				if str(args["modal"]) == "recruit":
					g._recruit_modal(c)
				elif str(args["modal"]) == "visit":
					g._visit_modal(c)
				else:
					w.player().city_id = "thien_kinh"
					g.refresh_all()
					g._recommend_modal(c)




func _scenario_m23(g: Control, w: World) -> void :
	War.declare(w, "bac_nguyen", "dai_ha")
	w.play["ngo_dao"] = 70
	PlayerOps.unlock_branch(w, "phan_tich")
	PlayerOps.unlock_branch(w, "du_doan")
	var got: Array = []
	for c: Character in w.living():
		if c.city_id == PlayerOps.here(w) and c.nation_id == "" and c.office_key == "" and not c.is_player and c.age(w.m) >= 16:
			got.append(c)
		if got.size() == 2:
			break
	w.clan["money"] = 5000.0
	for c: Character in got:
		PlayerOps.note(w, c.id)["met_m"] = w.m
		c.favor = 100.0
		c.fame = 0.0
		c.tham_vong = 0.0
		w.play["day"] = 0
		PlayerOps.recruit(w, c.id, true)
		PlayerOps.appraise(w, c.id, 2)
	if got.size() == 2:
		var t: Character = got[0]
		t.real[Defs.TRI] = 80.0
		PlayerOps.assign(w, got[1].id, "hoc_vien")
		PlayerOps.assign(w, t.id, "day_do", got[1].id)
		PlayerOps.toggle_exam(w, got[1].id)
		g.sel = "npc:" + got[1].id
	for k in 3:
		PlayerOps.end_month(w)
	if got.size() == 2:
		var t2: Character = got[0]
		PlayerOps.push_choice(w, "xin_tien", t2.id, "Gia đình %s gặp nạn, xin gia tộc giúp 200 lượng." % t2.name, 
			[["cho", "Giúp đỡ", "−200 lượng, Trung thành +15, ân tình +10"], ["khong", "Từ chối", "Trung thành −10"]], {"amt": 200})
		PlayerOps.push_choice(w, "dau_tu", "", "Một thương nhân rủ Tô gia góp 300 lượng buôn chuyến hàng xa, hẹn 6 tháng chia lãi.", 
			[["gop_von", "Góp vốn", "−300 lượng; 6 tháng sau ~60% được 650 lượng, ~40% mất trắng"], ["thoi", "Thôi", "Không có gì xảy ra"]])



func _demo_legacy() -> Legacy:
	var lg: = Legacy.new()
	var w: = WorldGen.generate(7, 0, 1)
	lg.apply_to_world(w)
	for cid in ["lac_thuy", "thien_kinh", "van_chau"]:
		w.player().city_id = cid
		var n: = 0
		for c: Character in w.living():
			if c.city_id == cid and not c.is_player and c.office_key == "" and n < 3:
				w.play["day"] = 0
				w.play["eye"] = 10
				PlayerOps.meet(w, c.id)
				PlayerOps.appraise(w, c.id, 2)
				n += 1
	Sim.run(w, 48)
	lg.record_life(w, "", 600.0)
	lg.thien_co = 140
	lg.upgrades = {"tham_dinh": 1, "ky_uc": 3, "khoi_dau": 2}
	lg.endings = {"nguoi_dung_sau": 1}
	return lg
