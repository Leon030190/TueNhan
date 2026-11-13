class_name Life
extends RefCounted



static func tick(w: World) -> void :
	for c: Character in w.chars.values():
		if not c.alive:
			continue
		_injuries(w, c)
		var am: = c.age_months(w.m)
		if am < c.lifespan_m - 60:
			c.health = minf(c.max_health(), c.health + 1.0)
		if c.mood_m > 0:
			c.mood_m -= 1
			if c.mood_m == 0 and c.crisis.is_empty():
				c.mood = "binh_thuong"
		if am >= c.lifespan_m:
			die(w, c, "thọ chung")
		elif c.health <= 0.0:
			die(w, c, "bệnh tật")


static func _injuries(w: World, c: Character) -> void :
	var keep: Array = []
	for inj in c.injuries:
		var months: = int(inj["months"])
		if months > 0:
			months -= 1
			inj["months"] = months
			if months == 0:
				var rest: Array = inj.get("restore", [])
				for i in rest.size():
					c.real[i] = minf(float(c.pot[i]), float(c.real[i]) + float(rest[i]))
				c.add_log(w.m, "Hồi phục sau %s" % str(inj["name"]).to_lower())
				continue
		keep.append(inj)
	c.injuries = keep


static func die(w: World, c: Character, cause: String) -> void :
	if not c.alive:
		return
	var office: = ""
	if c.office_key != "":
		office = Appointment.office_label_of(w, c)
		Appointment.vacate(w, c, "qua đời")
	c.alive = false
	c.death_m = w.m
	c.death_cause = cause
	c.crisis = {}
	c.add_log(w.m, "Qua đời (%s), hưởng thọ %d tuổi" % [cause, c.age(w.m)])
	w.count("death:" + cause)
	if office != "" or c.fame >= 25.0 or c.is_player or c.special != "":
		var who: = c.name if office == "" else "%s %s" % [office, c.name]
		w.add_news("%s qua đời (%s), hưởng thọ %d tuổi." % [who, cause, c.age(w.m)], [c.id], "bien_co")
