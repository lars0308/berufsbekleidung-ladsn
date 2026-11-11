extends Control
## Hauptszene: Splitscreen für zwei Spieler auf einem Bildschirm.
## Links der Fuchs (WASD / Controller 1), rechts der Bär (Pfeiltasten / Controller 2).

const Level := preload("res://scripts/level.gd")
const Levels := preload("res://scripts/levels.gd")

var level: Node2D
var viewports: Array[SubViewport] = []
var cameras: Array[Camera2D] = []
var hud: Label
var banner: Label
var level_index := 0


func _ready() -> void:
	_setup_inputs()
	_build_splitscreen()
	_build_labels()
	level = Level.new()
	level.solved.connect(_on_solved)
	viewports[0].add_child(level)
	_start_level(0)


func _setup_inputs() -> void:
	var keys := [
		{"up": KEY_W, "down": KEY_S, "left": KEY_A, "right": KEY_D},
		{"up": KEY_UP, "down": KEY_DOWN, "left": KEY_LEFT, "right": KEY_RIGHT},
	]
	var pad_buttons := {
		"up": JOY_BUTTON_DPAD_UP, "down": JOY_BUTTON_DPAD_DOWN,
		"left": JOY_BUTTON_DPAD_LEFT, "right": JOY_BUTTON_DPAD_RIGHT,
	}
	var pad_axes := {
		"up": [JOY_AXIS_LEFT_Y, -1.0], "down": [JOY_AXIS_LEFT_Y, 1.0],
		"left": [JOY_AXIS_LEFT_X, -1.0], "right": [JOY_AXIS_LEFT_X, 1.0],
	}
	for who in 2:
		for dir in keys[who]:
			var action := "p%d_%s" % [who, dir]
			if not InputMap.has_action(action):
				InputMap.add_action(action, 0.5)
			var key := InputEventKey.new()
			key.physical_keycode = keys[who][dir]
			InputMap.action_add_event(action, key)
			var button := InputEventJoypadButton.new()
			button.device = who
			button.button_index = pad_buttons[dir]
			InputMap.action_add_event(action, button)
			var motion := InputEventJoypadMotion.new()
			motion.device = who
			motion.axis = pad_axes[dir][0]
			motion.axis_value = pad_axes[dir][1]
			InputMap.action_add_event(action, motion)
	if not InputMap.has_action("restart"):
		InputMap.add_action("restart")
	var r := InputEventKey.new()
	r.physical_keycode = KEY_R
	InputMap.action_add_event("restart", r)
	var y_button := InputEventJoypadButton.new()
	y_button.button_index = JOY_BUTTON_Y
	InputMap.action_add_event("restart", y_button)


func _build_splitscreen() -> void:
	var box := HBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.add_theme_constant_override("separation", 4)
	add_child(box)
	for who in 2:
		var container := SubViewportContainer.new()
		container.stretch = true
		container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		container.size_flags_vertical = Control.SIZE_EXPAND_FILL
		box.add_child(container)
		var vp := SubViewport.new()
		container.add_child(vp)
		viewports.append(vp)
		var cam := Camera2D.new()
		cam.zoom = Vector2(1.25, 1.25)
		vp.add_child(cam)
		cam.make_current()
		cameras.append(cam)
	# Beide Ansichten zeigen dieselbe Welt.
	viewports[1].world_2d = viewports[0].world_2d


func _build_labels() -> void:
	hud = _make_label(20)
	hud.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	hud.offset_top = 8
	banner = _make_label(40)
	banner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	banner.visible = false


func _make_label(font_size: int) -> Label:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	label.add_theme_constant_override("outline_size", 8)
	add_child(label)
	return label


func _start_level(index: int) -> void:
	level_index = index % Levels.LEVELS.size()
	level.load_level(Levels.LEVELS[level_index]["map"])
	banner.visible = false
	_follow_players()


func _follow_players() -> void:
	for who in 2:
		cameras[who].position = level.visual[who] + Vector2(Level.CELL, Level.CELL) / 2.0


func _update_hud() -> void:
	var data: Dictionary = Levels.LEVELS[level_index]
	hud.text = "Level %d/%d – %s   |   Züge: %d\n%s\nFuchs: WASD · Bär: Pfeiltasten · R: Neustart" % [
		level_index + 1, Levels.LEVELS.size(), data["name"], level.moves, data["hint"]]


func _on_solved() -> void:
	var last := level_index == Levels.LEVELS.size() - 1
	banner.text = "Geschafft in %d Zügen!\n%s" % [
		level.moves,
		"Ihr habt alle Level gelöst!\nEnter: von vorn beginnen" if last else "Enter: nächstes Level",
	]
	banner.visible = true


func _process(_delta: float) -> void:
	_follow_players()
	_update_hud()
	if Input.is_action_just_pressed("restart"):
		_start_level(level_index)
	elif level.done and Input.is_action_just_pressed("ui_accept"):
		_start_level(level_index + 1)
