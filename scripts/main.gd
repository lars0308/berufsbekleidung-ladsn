extends Control
## Hauptszene: permanenter vertikaler Splitscreen (links Lumi, rechts Kiri), eine gemeinsame 3D-Welt.

const PlayerScript := preload("res://scripts/player/player.gd")
const CameraRigScript := preload("res://scripts/player/camera_rig.gd")
const TrackScript := preload("res://scripts/world/test_track.gd")
const HudScript := preload("res://scripts/hud.gd")
const Atmosphere := preload("res://scripts/world/atmosphere.gd")

## Feste Controller-Zuordnung (XInput-Slot 0 und 1).
const DEVICES := [0, 1]
const HERO_COLORS := [Color("ffd36b"), Color("a98bff")]

var world := World3D.new()
var viewports: Array[SubViewport] = []
var rigs: Array = []
var players: Array = []
var level: Node3D
var paused_for_pad := false
var _pause_label: Label
var _status: Label
var _status_timer := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	world.environment = Atmosphere.make_environment()
	_build_views()
	_build_level()
	_build_players()
	_build_hud()
	_build_overlay()
	Input.joy_connection_changed.connect(_on_joy_changed)
	_refresh_status()


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
	level.set_script(TrackScript)
	level.process_mode = Node.PROCESS_MODE_PAUSABLE
	viewports[0].add_child(level)
	level.checkpoint_changed.connect(_on_checkpoint)


func _build_players() -> void:
	var offsets := [Vector3(-1.5, 0, 0), Vector3(1.5, 0, 0)]
	for i in 2:
		var p := CharacterBody3D.new()
		p.set_script(PlayerScript)
		p.setup(i, i, DEVICES[i])
		p.position = level.spawn_point + offsets[i]
		level.add_child(p)
		players.append(p)
		var rig := Node3D.new()
		rig.set_script(CameraRigScript)
		rig.process_mode = Node.PROCESS_MODE_PAUSABLE
		rig.setup(p, p.input)
		viewports[i].add_child(rig)
		p.camera_rig = rig
		rigs.append(rig)
		p.spawn_position = p.position


func _on_checkpoint(pos: Vector3) -> void:
	var offsets := [Vector3(-1.5, 0, 0), Vector3(1.5, 0, 0)]
	for i in 2:
		players[i].spawn_position = pos + offsets[i]


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


func _build_overlay() -> void:
	_status = Label.new()
	_status.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_status.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_status.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_status.offset_bottom = -12
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.add_theme_font_size_override("font_size", 18)
	_status.add_theme_color_override("font_outline_color", Color.BLACK)
	_status.add_theme_constant_override("outline_size", 8)
	_status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_status)
	_pause_label = Label.new()
	_pause_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pause_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pause_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_pause_label.add_theme_font_size_override("font_size", 42)
	_pause_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_pause_label.add_theme_constant_override("outline_size", 14)
	_pause_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pause_label.visible = false
	add_child(_pause_label)


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
