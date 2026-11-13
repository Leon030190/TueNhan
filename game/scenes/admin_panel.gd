class_name AdminPanel
extends RefCounted

const UIKit: = preload("res://game/scenes/ui_kit.gd")
const PlayerOps: = preload("res://game/core/player_ops.gd")
const Sim: = preload("res://game/core/sim.gd")

## Bảng Điều Khiển Admin / Thiên Mệnh Toàn Năng cho Tuệ Nhãn
## Cho phép can thiệp toàn bộ tài nguyên, chỉ số nhân vật, môn khách, thành trì, thế giới và giao diện

static func _add_tab(tabs: TabContainer, title: String, content: Control) -> void :
	var scroll: = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(content)
	tabs.add_child(scroll)
	tabs.set_tab_title(tabs.get_tab_count() - 1, title)


static func open(host: Control) -> void:
	if host == null or not is_instance_valid(host):
		return
	var w: World = host.get("w")
	if w == null:
		return
	var p: Character = w.player()

	var body: = UIKit.modal(host, "👑 THIÊN MỆNH CHI CHỦ · BẢNG ĐIỀU KHIỂN ADMIN", 820)
	
	var tabs: = TabContainer.new()
	tabs.custom_minimum_size = Vector2(780, 480)
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(tabs)

	# ========================================================
	# TAB 1: TÀI NGUYÊN & GIA TỘC
	# ========================================================
	var tab_res: = UIKit.vbox(10)
	_add_tab(tabs, "💰 Tài Nguyên", tab_res)

	var res_info: = UIKit.label("Quản lý kho tàng, ngân lượng gia tộc, danh vọng và nhãn lực", 15, UIKit.DIM)
	tab_res.add_child(res_info)

	# Ngân lượng
	var r1: = UIKit.hbox(8)
	r1.add_child(UIKit.label("Ngân lượng:", 16, UIKit.GOLD))
	r1.add_child(UIKit.button("+50.000 Vàng", func():
		w.clan["money"] = float(w.clan["money"]) + 50000.0
		host.refresh_all()
		host.call("_msg", "[👑 Admin] Đã thêm +50.000 Vàng!")
	))
	r1.add_child(UIKit.button("+500.000 Vàng", func():
		w.clan["money"] = float(w.clan["money"]) + 500000.0
		host.refresh_all()
		host.call("_msg", "[👑 Admin] Đã thêm +500.000 Vàng!")
	))
	r1.add_child(UIKit.button("+5.000.000 Vàng", func():
		w.clan["money"] = float(w.clan["money"]) + 5000000.0
		host.refresh_all()
		host.call("_msg", "[👑 Admin] Đã thêm +5.000.000 Vàng!")
	))
	r1.add_child(UIKit.button("Max (99.999.999)", func():
		w.clan["money"] = 99999999.0
		host.refresh_all()
		host.call("_msg", "[👑 Admin] Ngân lượng đạt mức tối đa!")
	))
	tab_res.add_child(r1)

	# Danh vọng
	var r2: = UIKit.hbox(8)
	r2.add_child(UIKit.label("Danh vọng:  ", 16, UIKit.GOLD))
	r2.add_child(UIKit.button("+1.000 Danh vọng", func():
		w.clan["prestige"] = float(w.clan["prestige"]) + 1000.0
		host.refresh_all()
		host.call("_msg", "[👑 Admin] Đã thêm +1.000 Danh vọng!")
	))
	r2.add_child(UIKit.button("+10.000 Danh vọng", func():
		w.clan["prestige"] = float(w.clan["prestige"]) + 10000.0
		host.refresh_all()
		host.call("_msg", "[👑 Admin] Đã thêm +10.000 Danh vọng!")
	))
	r2.add_child(UIKit.button("Max (99.999)", func():
		w.clan["prestige"] = 99999.0
		host.refresh_all()
		host.call("_msg", "[👑 Admin] Danh vọng đạt mức tối đa!")
	))
	tab_res.add_child(r2)

	# Nhãn lực & Ngộ đạo
	var r3: = UIKit.hbox(8)
	r3.add_child(UIKit.label("Nhãn lực:   ", 16, UIKit.BLUE))
	r3.add_child(UIKit.button("Hồi Đầy Nhãn Lực", func():
		w.play["eye"] = w.play["eye_max"]
		host.refresh_all()
		host.call("_msg", "[👑 Admin] Đã hồi đầy Nhãn lực!")
	))
	r3.add_child(UIKit.button("+100 Max Nhãn Lực", func():
		w.play["eye_max"] = int(w.play["eye_max"]) + 100
		w.play["eye"] = w.play["eye_max"]
		host.refresh_all()
		host.call("_msg", "[👑 Admin] Max Nhãn lực tăng +100!")
	))
	r3.add_child(UIKit.button("Vô Hạn (999/999)", func():
		w.play["eye_max"] = 999
		w.play["eye"] = 999
		host.refresh_all()
		host.call("_msg", "[👑 Admin] Đã kích hoạt Vô Hạn Nhãn Lực!")
	))
	tab_res.add_child(r3)

	# Đôi Mắt Thần & Ngộ Đạo
	var r4: = UIKit.hbox(8)
	r4.add_child(UIKit.label("Đôi Mắt:    ", 16, UIKit.PURPLE))
	r4.add_child(UIKit.button("+100 Ngộ Đạo", func():
		w.play["ngo_dao"] = int(w.play["ngo_dao"]) + 100
		host.refresh_all()
		host.call("_msg", "[👑 Admin] Đã thêm +100 Ngộ Đạo!")
	))
	r4.add_child(UIKit.button("Mở Khóa Mắt Thần (Tầng 5)", func():
		w.play["ngo_dao"] = 200
		host.refresh_all()
		host.call("_msg", "[👑 Admin] Đã mở khóa Mắt Thần - Thấu thị vạn vật!")
	))
	r4.add_child(UIKit.button("Mở Khóa 3 Nhánh Thiên Phú Mắt", func():
		w.play["branches"] = {"phan_tich": true, "du_doan": true, "nhan_qua": true}
		host.refresh_all()
		host.call("_msg", "[👑 Admin] Đã mở khóa Phân Tích, Dự Đoán, Nhân Quả!")
	))
	tab_res.add_child(r4)

	# Hoạt động trong tháng (AP)
	var r5: = UIKit.hbox(8)
	r5.add_child(UIKit.label("Thời gian:  ", 16, UIKit.GREEN))
	r5.add_child(UIKit.button("Hồi 30 Ngày Hoạt Động (AP)", func():
		w.play["day"] = 0
		w.play["pending"] = []
		host.refresh_all()
		host.call("_msg", "[👑 Admin] Đã hồi đầy 30 ngày hoạt động trong tháng!")
	))
	r5.add_child(UIKit.button("+15 Ngày Phụ Trội", func():
		w.play["day"] = maxi(0, int(w.play["day"]) - 15)
		host.refresh_all()
		host.call("_msg", "[👑 Admin] Đã cộng thêm 15 ngày hành động!")
	))
	tab_res.add_child(r5)

	# Cấp bậc Gia tộc
	var r6: = UIKit.hbox(8)
	r6.add_child(UIKit.label("Cấp Gia tộc:", 16, UIKit.GOLD))
	r6.add_child(UIKit.button("Vương Tộc (Bậc 5 - Đỉnh Cao)", func():
		w.clan["tier"] = 5
		host.refresh_all()
		host.call("_msg", "[👑 Admin] Gia tộc đã thăng cấp thành VƯƠNG TỘC!")
	))
	r6.add_child(UIKit.button("Hào Tộc (Bậc 4)", func():
		w.clan["tier"] = 4
		host.refresh_all()
		host.call("_msg", "[👑 Admin] Gia tộc đã thăng cấp thành Hào Tộc!")
	))
	tab_res.add_child(r6)

	# ========================================================
	# TAB 2: NGƯỜI CHƠI & MÔN KHÁCH
	# ========================================================
	var tab_char: = UIKit.vbox(10)
	_add_tab(tabs, "⚡ Bản Thân & Môn Khách", tab_char)

	tab_char.add_child(UIKit.label("Tăng cường sức mạnh bản thân người chơi:", 16, UIKit.GOLD))

	var cp1: = UIKit.hbox(8)
	cp1.add_child(UIKit.button("⚡ Max 100 Toàn Bộ Chỉ Số Thực Lực", func():
		if p != null:
			p.real = [100.0, 100.0, 100.0, 100.0, 100.0, 100.0]
			host.refresh_all()
			host.call("_msg", "[👑 Admin] Toàn bộ 6 chỉ số thực lực đạt 100/100!")
	))
	cp1.add_child(UIKit.button("🌟 Max 100 Toàn Bộ Tiềm Năng", func():
		if p != null:
			p.pot = [100.0, 100.0, 100.0, 100.0, 100.0, 100.0]
			host.refresh_all()
			host.call("_msg", "[👑 Admin] Toàn bộ 6 tiềm năng đạt 100/100!")
	))
	cp1.add_child(UIKit.button("✨ Ngộ Tính 5 Sao", func():
		if p != null:
			p.ngo = 5
			host.refresh_all()
			host.call("_msg", "[👑 Admin] Ngộ tính đạt 5 sao cực hạn!")
	))
	tab_char.add_child(cp1)

	var cp2: = UIKit.hbox(8)
	cp2.add_child(UIKit.button("💖 Hồi 100% Máu & Trị Sạch Bệnh Tật, Thương Tích", func():
		if p != null:
			p.health = 100.0
			p.injuries = []
			p.lifespan_m = 1200
			host.refresh_all()
			host.call("_msg", "[👑 Admin] Sức khỏe hồi phục 100%, tuổi thọ gia tăng 100 năm!")
	))
	cp2.add_child(UIKit.button("😄 Tâm Trạng Hân Hoan Vĩnh Viễn", func():
		if p != null:
			p.mood = "han_hoan"
			p.mood_m = 9999
			p.y_chi = 100.0
			p.tham_vong = 100.0
			host.refresh_all()
			host.call("_msg", "[👑 Admin] Tâm trạng hân hoan, ý chí & tham vọng đạt cực hạn!")
	))
	tab_char.add_child(cp2)

	var cp3: = UIKit.hbox(8)
	cp3.add_child(UIKit.button("🎁 Nhận 10 Thiên Phú Cấp Thần", func():
		if p != null:
			var godly_talents = ["than_luc", "kiem_dao", "tai_chinh", "tam_co", "can_cu", "cuong_trang", "ham_hoc", "kheo_tay", "lanh_loi", "gan_da"]
			for t_id in godly_talents:
				if not p.talents.has(t_id):
					p.talents.append(t_id)
			host.refresh_all()
			host.call("_msg", "[👑 Admin] Đã thêm 10 Thiên Phú Thần Thoại cho bản thân!")
	))
	tab_char.add_child(cp3)

	tab_char.add_child(UIKit.divider(1))
	tab_char.add_child(UIKit.label("Nâng cấp toàn bộ Môn khách (Gia thần):", 16, UIKit.GOLD))

	var cr1: = UIKit.hbox(8)
	cr1.add_child(UIKit.button("❤️ Max 100 Trung Thành Cho Toàn Bộ Môn Khách", func():
		var ret_ids = w.clan.get("retainers", [])
		for rid in ret_ids:
			var c: Character = w.ch(str(rid))
			if c != null:
				c.loyalty = 100.0
				c.favor = 100.0
				c.hates_player = false
				c.mood = "han_hoan"
		host.refresh_all()
		host.call("_msg", "[👑 Admin] Toàn bộ môn khách đạt 100 Trung thành & Tận tụy!")
	))
	cr1.add_child(UIKit.button("🩹 Chữa Lành Mọi Môn Khách", func():
		var ret_ids = w.clan.get("retainers", [])
		for rid in ret_ids:
			var c: Character = w.ch(str(rid))
			if c != null:
				c.health = 100.0
				c.injuries = []
		host.refresh_all()
		host.call("_msg", "[👑 Admin] Toàn bộ môn khách được chữa lành hoàn toàn!")
	))
	tab_char.add_child(cr1)

	var cr2: = UIKit.hbox(8)
	cr2.add_child(UIKit.button("💪 +30 Mọi Chỉ Số Cho Toàn Bộ Môn Khách", func():
		var ret_ids = w.clan.get("retainers", [])
		for rid in ret_ids:
			var c: Character = w.ch(str(rid))
			if c != null:
				for i in range(c.real.size()):
					c.real[i] = minf(100.0, float(c.real[i]) + 30.0)
					c.pot[i] = minf(100.0, float(c.pot[i]) + 30.0)
		host.refresh_all()
		host.call("_msg", "[👑 Admin] Đã tăng +30 điểm cho toàn bộ môn khách!")
	))
	cr2.add_child(UIKit.button("💰 Thưởng 10.000 Vàng Túi Riêng Cho Mỗi Môn Khách", func():
		var ret_ids = w.clan.get("retainers", [])
		for rid in ret_ids:
			var c: Character = w.ch(str(rid))
			if c != null:
				c.purse += 10000.0
		host.refresh_all()
		host.call("_msg", "[👑 Admin] Đã thưởng 10.000 vàng cho từng môn khách!")
	))
	tab_char.add_child(cr2)

	# ========================================================
	# TAB 3: NHÂN VẬT ĐANG CHỌN
	# ========================================================
	var tab_sel: = UIKit.vbox(10)
	_add_tab(tabs, "🎯 Nhân Vật Đang Chọn", tab_sel)

	var target_id: String = str(host.get("sel"))
	var target_char: Character = w.ch(target_id)
	
	if target_char == null:
		tab_sel.add_child(UIKit.label("Chưa chọn nhân vật nào! Hãy bấm chọn 1 người ở danh sách hoặc bản đồ.", 16, UIKit.DIM))
	else:
		var target_info: String = "Đang chọn: [b]%s[/b] · %d tuổi · %s · Nơi ở: %s" % [
			target_char.name, target_char.age(w.m), target_char.profession, w.city_name(target_char.city_id)
		]
		tab_sel.add_child(UIKit.wrap_label(target_info, 16, UIKit.GOLD))

		var act1: = UIKit.hbox(8)
		act1.add_child(UIKit.button("🤝 Chiêu Mộ Tức Thì Làm Môn Khách (100% Thành công)", func():
			target_char.clan_retainer = true
			target_char.city_id = p.city_id
			if not (w.clan["retainers"] as Array).has(target_char.id):
				(w.clan["retainers"] as Array).append(target_char.id)
			target_char.loyalty = 100.0
			target_char.favor = 100.0
			target_char.hates_player = false
			w.play["tasks"][target_char.id] = ""
			w.play["salary"][target_char.id] = 10
			PlayerOps.note(w, target_char.id)
			host.refresh_all()
			host.call("_msg", "[👑 Admin] Đã chiêu mộ %s thành Môn khách trung thành!" % target_char.name)
		))
		tab_sel.add_child(act1)

		var act2: = UIKit.hbox(8)
		act2.add_child(UIKit.button("📈 Max 100 Tiềm Năng & Thực Lực", func():
			target_char.real = [100.0, 100.0, 100.0, 100.0, 100.0, 100.0]
			target_char.pot = [100.0, 100.0, 100.0, 100.0, 100.0, 100.0]
			target_char.ngo = 5
			host.refresh_all()
			host.call("_msg", "[👑 Admin] %s đã đạt 100/100 mọi chỉ số!" % target_char.name)
		))
		act2.add_child(UIKit.button("❤️ Đặt 100 Trung Thành & Thiện Cảm", func():
			target_char.loyalty = 100.0
			target_char.favor = 100.0
			target_char.hates_player = false
			host.refresh_all()
			host.call("_msg", "[👑 Admin] %s trung thành và kính ngưỡng bạn tuyệt đối!" % target_char.name)
		))
		tab_sel.add_child(act2)

		var act3: = UIKit.hbox(8)
		act3.add_child(UIKit.button("💊 Trị Lành Hoàn Toàn & Sức Khỏe 100", func():
			target_char.health = 100.0
			target_char.injuries = []
			host.refresh_all()
			host.call("_msg", "[👑 Admin] Đã chữa lành toàn bộ cho %s!" % target_char.name)
		))
		act3.add_child(UIKit.button("💵 Tặng 20.000 Vàng Túi Riêng", func():
			target_char.purse += 20000.0
			host.refresh_all()
			host.call("_msg", "[👑 Admin] Đã tặng 20.000 vàng cho %s!" % target_char.name)
		))
		tab_sel.add_child(act3)

		var act4: = UIKit.hbox(8)
		act4.add_child(UIKit.button("👁️ Thấu Thị Mắt Thần (Thẩm định toàn diện)", func():
			var nt: = PlayerOps.note(w, target_char.id)
			nt["tiers"] = [0, 1, 2, 3, 4, 5]
			nt["met_m"] = w.m
			host.refresh_all()
			host.call("_msg", "[👑 Admin] Đã thẩm định toàn diện số mệnh của %s!" % target_char.name)
		))
		tab_sel.add_child(act4)

	# ========================================================
	# TAB 4: THÀNH TRÌ & DỊCH CHUYỂN
	# ========================================================
	var tab_world: = UIKit.vbox(10)
	_add_tab(tabs, "🗺️ Thành Trì & Bản Đồ", tab_world)

	tab_world.add_child(UIKit.label("Dịch chuyển tức thời đến bất kỳ thành phố nào:", 16, UIKit.GOLD))

	var tp_box: = UIKit.hbox(8)
	var city_opt: = OptionButton.new()
	city_opt.custom_minimum_size.x = 240
	var city_keys: Array = w.cities.keys()
	city_keys.sort()
	for i in range(city_keys.size()):
		var ck = str(city_keys[i])
		city_opt.add_item("%s (%s)" % [w.city_name(ck), w.nation_name(w.city_nation(ck))], i)
		if ck == p.city_id:
			city_opt.select(i)
	tp_box.add_child(city_opt)

	tp_box.add_child(UIKit.button("🚀 Dịch Chuyển Ngay", func():
		var sel_idx = city_opt.get_selected_id()
		if sel_idx >= 0 and sel_idx < city_keys.size():
			var dest_cid = str(city_keys[sel_idx])
			p.city_id = dest_cid
			host.refresh_all()
			host.call("_msg", "[👑 Admin] Đã dịch chuyển tức thời đến %s!" % w.city_name(dest_cid))
	))
	tab_world.add_child(tp_box)

	tab_world.add_child(UIKit.divider(1))
	tab_world.add_child(UIKit.label("Chỉnh sửa Thành phố hiện tại (%s):" % w.city_name(p.city_id), 16, UIKit.GOLD))

	var city_acts: = UIKit.hbox(8)
	city_acts.add_child(UIKit.button("Max Kinh Tế (100)", func():
		if w.cities.has(p.city_id):
			w.cities[p.city_id]["kinh_te"] = 100.0
			host.refresh_all()
			host.call("_msg", "[👑 Admin] Kinh tế thành phố đạt 100!")
	))
	city_acts.add_child(UIKit.button("Max Sản Xuất (100)", func():
		if w.cities.has(p.city_id):
			w.cities[p.city_id]["sx"] = 100.0
			host.refresh_all()
			host.call("_msg", "[👑 Admin] Sản xuất thành phố đạt 100!")
	))
	city_acts.add_child(UIKit.button("Max An Ninh (100)", func():
		if w.cities.has(p.city_id):
			w.cities[p.city_id]["an_ninh"] = 100.0
			host.refresh_all()
			host.call("_msg", "[👑 Admin] An ninh thành phố đạt 100!")
	))
	city_acts.add_child(UIKit.button("Max Toàn Bộ Chỉ Số Thành", func():
		if w.cities.has(p.city_id):
			w.cities[p.city_id]["kinh_te"] = 100.0
			w.cities[p.city_id]["sx"] = 100.0
			w.cities[p.city_id]["an_ninh"] = 100.0
			w.cities[p.city_id]["giao_duc"] = 100.0
			host.refresh_all()
			host.call("_msg", "[👑 Admin] Toàn bộ chỉ số thành phố đã tối đa 100!")
	))
	tab_world.add_child(city_acts)

	tab_world.add_child(UIKit.divider(1))
	tab_world.add_child(UIKit.label("Hòa bình & Thời gian thiên hạ:", 16, UIKit.GOLD))

	var war_acts: = UIKit.hbox(8)
	war_acts.add_child(UIKit.button("🕊️ Thiết Lập Hòa Bình Thiên Hạ (Dập tắt chiến tranh)", func():
		w.wars = []
		host.refresh_all()
		host.call("_msg", "[👑 Admin] Thiên hạ thái bình! Toàn bộ chiến tranh đã chấm dứt.")
	))
	war_acts.add_child(UIKit.button("⏩ Qua 1 Tháng", func():
		Sim.run(w, 1)
		host.refresh_all()
		host.call("_msg", "[👑 Admin] Đã vận hành thời gian qua 1 tháng!")
	))
	war_acts.add_child(UIKit.button("⏩ Qua 6 Tháng", func():
		Sim.run(w, 6)
		host.refresh_all()
		host.call("_msg", "[👑 Admin] Đã vận hành thời gian qua 6 tháng!")
	))
	tab_world.add_child(war_acts)

	# ========================================================
	# TAB 5: SOI NGỌC THÔ & TÌM NHÂN TÀI
	# ========================================================
	var tab_find: = UIKit.vbox(10)
	_add_tab(tabs, "💎 Soi Ngọc Thô", tab_find)

	tab_find.add_child(UIKit.label("Thấu thị thiên tài & ngọc thô ẩn giấu trong thiên hạ:", 16, UIKit.GOLD))

	var frow: = UIKit.hbox(8)
	frow.add_child(UIKit.button("🔍 Thẩm Định Toàn Bộ Người Trong Thành Này", func():
		var count = 0
		for c: Character in w.chars.values():
			if c.alive and c.city_id == p.city_id:
				var nt: = PlayerOps.note(w, c.id)
				nt["tiers"] = [0, 1, 2, 3, 4, 5]
				nt["met_m"] = w.m
				count += 1
		host.refresh_all()
		host.call("_msg", "[👑 Admin] Đã quét và thẩm định toàn bộ %d người trong thành!" % count)
	))
	frow.add_child(UIKit.button("🌟 Thêm Mọi Thiên Tài (TN ≥ 80) Vào Sổ Nhân Vật", func():
		var count = 0
		for c: Character in w.chars.values():
			if c.alive and not c.is_player:
				var top_p = 0.0
				for pt in c.pot:
					if float(pt) > top_p:
						top_p = float(pt)
				if top_p >= 80.0:
					var nt: = PlayerOps.note(w, c.id)
					nt["tiers"] = [0, 1, 2, 3, 4, 5]
					nt["met_m"] = w.m
					count += 1
		host.refresh_all()
		host.call("_msg", "[👑 Admin] Đã phát hiện và ghi nhận %d viên ngọc thô (TN ≥ 80) vào Sổ!" % count)
	))
	tab_find.add_child(frow)

	# Danh sách top ngọc thô
	var scroll: = ScrollContainer.new()
	scroll.custom_minimum_size.y = 300
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var vbox_gems: = UIKit.vbox(4)
	vbox_gems.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox_gems)
	tab_find.add_child(scroll)

	var gems: Array = []
	for c: Character in w.chars.values():
		if c.alive and not c.is_player:
			var max_pot = 0.0
			for pt in c.pot:
				if float(pt) > max_pot:
					max_pot = float(pt)
			if max_pot >= 75.0:
				gems.append([c, max_pot])
	gems.sort_custom(func(a, b): return a[1] > b[1])

	for item in gems.slice(0, 30):
		var gc: Character = item[0]
		var gpot: float = item[1]
		var grow: = UIKit.hbox(8)
		var desc_lbl: = UIKit.label("%s (%d tuổi) · Nơi ở: %s · Nghề: %s · TN cao nhất: %d" % [
			gc.name, gc.age(w.m), w.city_name(gc.city_id), gc.profession, roundi(gpot)
		], 15, UIKit.TEXT)
		desc_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grow.add_child(desc_lbl)
		var view_btn: = UIKit.button("Xem / Chiêu mộ", func():
			host.call("select", gc.id)
			var nt: = PlayerOps.note(w, gc.id)
			nt["tiers"] = [0, 1, 2, 3, 4, 5]
			nt["met_m"] = w.m
			host.refresh_all()
			UIKit.close_modal(body)
			host.call("_msg", "[👑 Admin] Đã chọn %s vào bảng thông tin bên phải!" % gc.name)
		)
		grow.add_child(view_btn)
		vbox_gems.add_child(grow)

	# Đóng modal
	var close_row: = UIKit.hbox(8)
	close_row.add_child(UIKit.spacer())
	close_row.add_child(UIKit.button("Đóng Bảng Admin", func(): UIKit.close_modal(body)))
	body.add_child(close_row)
