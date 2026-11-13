extends Node






const DIR: = "res://assets/audio/music/"
const PLAYLISTS: = {
	"chu_de": ["m01_chu_de_a", "m01_chu_de_b"], 
	"dai_ha": ["m02_dai_ha_a"], 
	"bac_nguyen": ["m03_bac_nguyen_a", "m03_bac_nguyen_b"], 
	"nam_cam": ["m04_nam_cam_a"], 
	"tay_lang": ["m05_tay_lang_a"], 
	"dong_hai": ["m06_dong_hai_a", "m06_dong_hai_b"], 
	"binh_dao": ["m07_binh_dao_a", "m07_binh_dao_b", "m07_binh_dao_c"], 
	"trung_sinh": ["m08_trung_sinh_a"], 
}

const GAPS: = {"chu_de": [4.0, 8.0], "binh_dao": [3.0, 8.0], "trung_sinh": [20.0, 30.0]}
const GAP_DEFAULT: = [25.0, 50.0]

const GAP_SINGLE: = [1.0, 1.5]
const FADE: = 2.5
const WAR_FRESH_M: = 3

var context: = ""
var _players: Array[AudioStreamPlayer] = []
var _cur: = 0
var _next_idx: = {}
var _gen: = 0
var _enabled: = true
var _held: = false


func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS

	var args: = Array(OS.get_cmdline_user_args())
	_enabled = DisplayServer.get_name() != "headless" and not args.any( func(a: String) -> bool: return a.begins_with("--shot"))
	if AudioServer.get_bus_index("Music") < 0:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "Music")
		AudioServer.set_bus_send(AudioServer.bus_count - 1, "Master")
	apply_volume()
	for k in 2:
		var p: = AudioStreamPlayer.new()
		p.bus = "Music"
		p.volume_linear = 0.0
		p.finished.connect(_on_finished.bind(p))
		add_child(p)
		_players.append(p)



static func volume() -> int:
	return int(UIKit.pref("music_vol", 60))


static func set_volume(v: int) -> void :
	UIKit.set_pref("music_vol", clampi(v, 0, 100))


func apply_volume() -> void :
	var i: = AudioServer.get_bus_index("Music")
	var v: = volume() / 100.0
	AudioServer.set_bus_mute(i, v <= 0.0)
	AudioServer.set_bus_volume_linear(i, v * v)


func set_context(ctx: String) -> void :
	if ctx == context or not PLAYLISTS.has(ctx):
		return
	context = ctx
	if _enabled and not _held:
		_play_next(true)



func hold() -> void :
	_held = true
	_gen += 1
	for p in _players:
		if p.playing:
			var t: = create_tween()
			t.tween_property(p, "volume_linear", 0.0, 0.3)
			t.tween_callback(p.stop)



func release() -> void :
	if not _held:
		return
	_held = false
	if _enabled and context != "":
		_play_next(true)



func update_world(w: World) -> void :
	var cid: = PlayerOps.here(w)
	var nid: = w.city_nation(cid)
	for wr in War.wars_of(w, nid):
		if str(wr["front"]) == cid or w.m - int(wr["start"]) < WAR_FRESH_M:
			set_context("binh_dao")
			return
	set_context(nid)


func _play_next(crossfade: bool) -> void :
	_gen += 1
	var list: Array = PLAYLISTS[context]
	if not _next_idx.has(context):
		_next_idx[context] = randi() % list.size()
	var i: int = _next_idx[context]
	_next_idx[context] = (i + 1) % list.size()
	var stream: AudioStream = load(DIR + str(list[i]) + ".ogg")
	if stream == null:
		return
	var old: = _players[_cur]
	_cur = 1 - _cur
	var p: = _players[_cur]
	p.stream = stream
	p.volume_linear = 0.0 if crossfade else 1.0
	p.play()
	if crossfade:
		var t: = create_tween().set_parallel()
		t.tween_property(p, "volume_linear", 1.0, FADE)
		if old.playing:
			t.tween_property(old, "volume_linear", 0.0, FADE)
			t.chain().tween_callback(old.stop)
	else:
		old.stop()


func _on_finished(p: AudioStreamPlayer) -> void :
	if p != _players[_cur]:
		return
	var g: = _gen
	var gap: Array = GAP_SINGLE if (PLAYLISTS[context] as Array).size() == 1 else GAPS.get(context, GAP_DEFAULT)
	await get_tree().create_timer(randf_range(float(gap[0]), float(gap[1]))).timeout
	if g == _gen and _enabled and not _held:
		_play_next(false)



func volume_row() -> Control:
	var row: = UIKit.hbox(10)
	row.add_child(UIKit.label("Âm lượng nhạc", 15, UIKit.TEXT))
	var s: = HSlider.new()
	s.min_value = 0
	s.max_value = 100
	s.step = 5
	s.value = volume()
	s.custom_minimum_size.x = 260
	s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var val: = UIKit.label("%d" % volume() if volume() > 0 else "Tắt", 15, UIKit.DIM)
	val.custom_minimum_size.x = 40
	s.value_changed.connect( func(v: float) -> void :
		set_volume(int(v))
		apply_volume()
		val.text = "%d" % int(v) if v > 0 else "Tắt")
	row.add_child(s)
	row.add_child(val)
	return row
