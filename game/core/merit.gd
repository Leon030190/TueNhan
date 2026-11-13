class_name Merit
extends RefCounted




const FAME_PER_MERIT: = 0.15


static func hoan_canh(w: World, nid: String, oid: String) -> float:
	var nat: Dictionary = w.nations[nid]
	var h: = 1.0
	var mil: bool = Defs.OFFICES[oid]["military"]
	if mil and bool(nat.get("shortage", false)):
		h *= 0.5
	if not mil and float(nat["stability"]) < 30.0:
		h *= 0.7
	return h


static func tick(w: World) -> void :
	for nid in w.nations:
		var offices: Dictionary = w.nations[nid]["offices"]
		for key in offices:
			var c: = w.office_holder(nid, key)
			if c == null:
				continue
			var oid: = Appointment.office_of_key(key)
			var merit: = c.office_score(oid) * float(Defs.OFFICES[oid]["weight"]) / 100.0 * hoan_canh(w, nid, oid)
			c.merit_m = merit
			c.merit_y += merit
			c.merit_total += merit
			c.office_months += 1
	if w.month() == 12:
		for c: Character in w.living():
			if c.merit_y > 0.0:
				if c.recommender != "" and c.recommender == w.player_id:
					PlayerOps.on_merit_year(w, c, c.merit_y)
				c.fame = minf(100.0, c.fame + c.merit_y * FAME_PER_MERIT)
				c.merit_y = 0.0
