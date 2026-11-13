class_name Growth
extends RefCounted





static func env_mult(c: Character, i: int) -> float:
	var mult: = 1.0
	var e: Dictionary = Defs.ENVS.get(c.env, Defs.ENVS[""])
	var st: Array = e["stats"]
	if st.has(i):
		mult = float(e["mult"]) * c.env_bonus
	if c.mentor_m > 0 and c.mentor_stat == i:
		mult = maxf(mult, c.mentor_mult)
	return mult


static func delta(c: Character, i: int, age: int) -> float:
	var p: float = c.pot[i]
	var r: float = c.real[i]
	if p <= 0.0 or r >= p:
		return 0.0
	var k: float = Defs.GROWTH_BASE * float(Defs.NGO_MULT[c.ngo]) * Defs.age_growth(i, age)
	k *= float(Defs.MOOD_MULT.get(c.mood, 1.0))
	k *= 1.0 if c.in_focus(i) else Defs.OFF_FOCUS
	k *= env_mult(c, i)
	k *= ProfTree.growth_mult(c, i)
	k *= Talents.growth_mult(c, i, age)
	return k * (p - r) / p



static func mi_delta(c: Character, age: int) -> float:
	if c.mi_pot <= 0.0 or c.mi_real >= c.mi_pot:
		return 0.0
	var k: float = Defs.GROWTH_BASE * float(Defs.NGO_MULT[c.ngo]) * Defs.age_growth(Defs.CHINH, age) * 0.5
	k *= float(Defs.MOOD_MULT.get(c.mood, 1.0))
	if ProfTree.mi_bonus(c):
		k *= ProfTree.MI_MULT
	if c.env == "van_dan":
		k *= 1.8
	elif c.env == "trieu_dinh" or c.env == "thuong_hoi":
		k *= 1.3
	return k * (c.mi_pot - c.mi_real) / c.mi_pot


static func step(c: Character, m: int) -> void :
	var age: = c.age(m)
	for i in Defs.N_STATS:
		var v: float = float(c.real[i]) + delta(c, i, age) - Defs.age_decline(i, age)
		c.real[i] = clampf(v, 0.0, Defs.POT_HARD_CAP)
	c.mi_real = clampf(c.mi_real + mi_delta(c, age), 0.0, Defs.POT_CAP)
	if c.mentor_m > 0:
		c.mentor_m -= 1
	ProfTree.tick(c, m)


static func tick(w: World) -> void :
	for c: Character in w.chars.values():
		if c.alive:
			step(c, w.m)



static func project(c: Character, from_m: int, months: int) -> Array:
	var tmp: = Character.from_dict(c.to_dict())
	for k in months:
		step(tmp, from_m + k)
	return tmp.real
