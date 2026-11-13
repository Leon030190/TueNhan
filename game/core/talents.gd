class_name Talents
extends RefCounted



static func add(c: Character, tid: String, apply_bonus: bool = true) -> void :
	if c.has_talent(tid) or GameData.talent(tid).is_empty():
		return
	c.talents.append(tid)
	if apply_bonus:
		_apply_bonus(c, tid)


static func _apply_bonus(c: Character, tid: String) -> void :
	var d: Dictionary = GameData.talent(tid)
	var pb: Dictionary = d.get("pot", {})
	var cap: = c.pot_cap()
	for k in pb:
		var i: = Defs.stat_index(k)
		var cur: float = c.pot[i]
		c.pot[i] = maxf(cur, minf(cap, cur + float(pb[k])))
	c.y_chi = clampf(c.y_chi + float(d.get("y_chi", 0)), 0.0, 100.0)
	c.concealment = clampf(c.concealment + float(d.get("concealment", 0)), 0.0, 100.0)


static func replace(w: World, c: Character, old_id: String, new_id: String, reason: String) -> void :
	c.talents.erase(old_id)
	add(c, new_id)
	var txt: = "Thiên phú %s chuyển hóa thành %s (%s)" % [GameData.talent_name(old_id), GameData.talent_name(new_id), reason]
	c.add_log(w.m, txt)
	w.add_news("%s: %s." % [c.name, txt], [c.id], "co_duyen")
	w.count("talent_evolve")


static func role_bonus(c: Character, role: String) -> float:
	var b: = 0.0
	for t in c.talents:
		var rb: Dictionary = GameData.talent(t).get("role", {})
		b += float(rb.get(role, 0.0))
	for t in c.traits:
		var rb2: Dictionary = GameData.trait_def(t).get("role", {})
		b += float(rb2.get(role, 0.0))
	return b



static func growth_mult(c: Character, i: int, age: int) -> float:
	var g: = 1.0
	for t in c.talents:
		var gr: Dictionary = GameData.talent(t).get("growth", {})
		g += float(gr.get("all", 0.0)) + float(gr.get(Defs.STAT_KEYS[i], 0.0))
	if c.has_talent("van_thanh"):
		g *= 0.6 if age < 30 else 1.5
	return g



static func evolve_tick(w: World) -> void :
	for c: Character in w.living():
		if c.battles >= 10 and not c.has_talent("bach_chien"):
			if c.has_talent("cuong_trang"):
				replace(w, c, "cuong_trang", "bach_chien", "trải qua %d trận" % c.battles)
			elif c.has_talent("than_luc"):
				replace(w, c, "than_luc", "bach_chien", "trải qua %d trận" % c.battles)
		if c.has_talent("tai_chinh") and c.office_key.ends_with("/ho_bo#0") and c.office_months >= 60:
			replace(w, c, "tai_chinh", "kinh_the", "5 năm chấp chưởng Hộ bộ")
		if c.has_talent("quan_than") and float(c.real[Defs.QUAN]) >= 90.0:
			replace(w, c, "quan_than", "binh_phap", "Quân sự đạt cảnh giới 90")
		if c.has_talent("kheo_tay") and float(c.real[Defs.SX]) >= 70.0:
			if w.rng(["evo", c.id]).randf() < 0.003:
				replace(w, c, "kheo_tay", "bach_cong", "tay nghề đạt tới hóa cảnh")
