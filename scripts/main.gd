extends Control
## Hauptszene: permanenter vertikaler Splitscreen (links Lumi, rechts Kiri), eine gemeinsame 3D-Welt.

const PlayerScript := preload("res://scripts/player/player.gd")
const CameraRigScript := preload("res://scripts/player/camera_rig.gd")
const Level1Script := preload("res://scripts/world/level_1.gd")
const HudScript := preload("res://scripts/hud.gd")
const Atmosphere := preload("res://scripts/world/atmosphere.gd")

## Feste Controller-Zuordnung (XInput-Slot 0 und 1).
const DEVICES := [0, 1]
const HERO_COLORS := [Color("ffd36b"), Color("a98bff")]
const SPEAKER_COLORS := {"Lumi": Color("ffd36b"), "Kiri": Color("b79bff"), "Zirp": Color("b8fff0")}
const LINE_TIME := 4.2

var world := World3D.new()
var viewports: Array[SubViewport] = []
var rigs: Array = []
var players: Array = []
var envs: Array[Environment] = []
var moods: Array[float] = [0.0, 1.0]
var level: Node3D
var level_script: Script = Level1Script
var paused_for_pad := false
var finished := false
var _pause_label: Label
var _status: Label
var _status_timer := 0.0
var _speech: Label
var _speech_queue: Array = []
var _speech_time := 0.0
var _title: Label
var _title_time := 0.0
var _finish_label: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_views()
	_build_level()
	_build_players()
	_build_hud()
	_build_overlay()
	Input.joy_connection_changed.connect(_on_joy_changed)
	_refresh_status()
	_title.text = level.level_name
	_title_time = 3.5
	for i in 2:
		moods[i] = level.mood_at(players[i].global_position)
		Atmosphere.apply_mood(envs[i], moods[i])


func _build_views() -> void:
	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", 4)
	add_child(row)
	for i in 2:
		var c := SubViewportContainer.new()
		c.stretch = true
		c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		c.size_flags_vertical = Control.SIZE_EXPAND_FILL
		row.add_child(c)
		var vp := SubViewport.new()
		vp.world_3d = world
		vp.msaa_3d = Viewport.MSAA_2X
		vp.handle_input_locally = false
		c.add_child(vp)
		viewports.append(vp)


func _build_level() -> void:
	level = Node3D.new()
	level.set_script(level_script)
	level.process_mode = Node.PROCESS_MODE_PAUSABLE
	viewports[0].add_child(level)
	level.checkpoint_changed.connect(_on_checkpoint)
	level.dialog.connect(say)


func _build_players() -> void:
	for i in 2:
		var p := CharacterBody3D.new()
		p.set_script(PlayerScript)
		p.setup(i, i, DEVICES[i])
		p.position = level.spawn_points[i]
		var yaw: float = level.spawn_yaws[i]
		p.face_dir = Vector3(-sin(yaw), 0, -cos(yaw))
		level.add_child(p)
		players.append(p)
		var rig := Node3D.new()
		rig.set_script(CameraRigScript)
		rig.process_mode = Node.PROCESS_MODE_PAUSABLE
		rig.setup(p, p.input)
		rig.yaw = yaw
		viewports[i].add_child(rig)
		p.camera_rig = rig
		rigs.append(rig)
		p.spawn_position = p.position
		var env := Atmosphere.make_environment()
		rig.camera.environment = env
		envs.append(env)
	level.finished.connect(_on_finished)


func _on_checkpoint(pos: Vector3, hero: int) -> void:
	for i in 2:
		if hero < 0 or hero == i:
			players[i].spawn_position = pos + Vector3(-1.5 if i == 0 else 1.5, 0, 0)


func _build_hud() -> void:
	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", 4)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(row)
	var names := ["LUMI", "KIRI"]
	for i in 2:
		var h := Control.new()
		h.set_script(HudScript)
		h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.size_flags_vertical = Control.SIZE_EXPAND_FILL
		row.add_child(h)
		h.setup(players[i], names[i], HERO_COLORS[i])


func _label(size: int, outline := 10) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.92))
	l.add_theme_constant_override("outline_size", outline)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l


func _build_overlay() -> void:
	_status = _label(16, 8)
	_status.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_status.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_status.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_status.offset_bottom = -8
	_speech = _label(30, 12)
	_speech.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_speech.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_speech.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_speech.offset_bottom = -64
	_speech.visible = false
	_title = _label(54, 16)
	_title.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title.offset_bottom = -260
	_title.visible = false
	_finish_label = _label(46, 14)
	_finish_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_finish_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_finish_label.visible = false
	_pause_label = _label(42, 14)
	_pause_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_pause_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_pause_label.visible = false


## Kurze Dialogzeilen [[Sprecher, Text], ...] nacheinander einblenden (A überspringt nicht, kein Zwang).
func say(lines: Array) -> void:
	_speech_queue.append_array(lines)
	if not _speech.visible:
		_next_line()


func _next_line() -> void:
	if _speech_queue.is_empty():
		_speech.visible = false
		return
	var line: Array = _speech_queue.pop_front()
	_speech.text = "%s: %s" % [line[0], line[1]]
	_speech.add_theme_color_override("font_color", SPEAKER_COLORS.get(line[0], Color.WHITE))
	_speech.visible = true
	_speech_time = LINE_TIME


func _on_finished() -> void:
	finished = true
	_finish_label.text = "Level geschafft!\n\nDas Schiff ist in Sicht.\nLevel 2 folgt – A: nochmal spielen"
	_finish_label.visible = true


func restart_level() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _refresh_status() -> void:
	var parts: PackedStringArray = []
	for i in 2:
		var pad: bool = players[i].input.has_pad()
		parts.append("%s: %s" % [["Lumi", "Kiri"][i], "Controller %d" % (DEVICES[i] + 1) if pad else "Tastatur"])
	_status.text = "   |   ".join(parts) + "   |   Start = Pause   F11 = Vollbild"


func _process(delta: float) -> void:
	_status_timer -= delta
	if _status_timer <= 0.0:
		_status_timer = 1.0
		_refresh_status()
	if not get_tree().paused:
		for i in 2:
			var target: float = level.mood_at(players[i].global_position)
			moods[i] = lerpf(moods[i], target, 1.0 - exp(-2.5 * delta))
			Atmosphere.apply_mood(envs[i], moods[i])
		if _speech.visible:
			_speech_time -= delta
			if _speech_time <= 0.0:
				_next_line()
		if _title_time > 0.0:
			_title_time -= delta
			_title.visible = true
			_title.modulate.a = clampf(_title_time / 1.0, 0.0, 1.0)
			if _title_time <= 0.0:
				_title.visible = false
		if finished:
			for p in players:
				if p.input.consume("jump"):
					restart_level()
					return


func set_paused(on: bool, message := "") -> void:
	get_tree().paused = on
	_pause_label.visible = on
	if on:
		_pause_label.text = message if message != "" else "PAUSE\nStart: weiter"


func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_START:
		if paused_for_pad and not _all_pads_ok():
			return
		paused_for_pad = false
		set_paused(not get_tree().paused)
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_P:
			set_paused(not get_tree().paused)
		elif event.keycode == KEY_F11:
			var full := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if full else DisplayServer.WINDOW_MODE_FULLSCREEN)


func _all_pads_ok() -> bool:
	for i in 2:
		if not Input.get_connected_joypads().has(DEVICES[i]):
			return false
	return true


func _on_joy_changed(device: int, connected: bool) -> void:
	_refresh_status()
	if not connected and DEVICES.has(device):
		paused_for_pad = true
		set_paused(true, "Controller %d getrennt\nBitte wieder anschließen, dann Start" % (device + 1))
