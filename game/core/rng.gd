class_name Rng
extends RefCounted






static func hash32(s: String) -> int:
	var h: int = 2166136261
	for b in s.to_utf8_buffer():
		h = h ^ b
		h = (h * 16777619) & 4294967295
	return h


static func key(parts: Array) -> int:
	var s: = ""
	for p in parts:
		s += str(p) + "|"
	return hash32(s)


static func make(parts: Array) -> RandomNumberGenerator:
	var r: = RandomNumberGenerator.new()
	r.seed = key(parts)
	return r


static func pick_weighted(r: RandomNumberGenerator, weights: Array) -> int:
	var total: = 0.0
	for x in weights:
		total += maxf(0.0, float(x))
	if total <= 0.0:
		return 0
	var t: = r.randf() * total
	for i in weights.size():
		t -= maxf(0.0, float(weights[i]))
		if t < 0.0:
			return i
	return weights.size() - 1


static func pick(r: RandomNumberGenerator, arr: Array) -> Variant:
	if arr.is_empty():
		return null
	return arr[r.randi_range(0, arr.size() - 1)]
