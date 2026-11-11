extends Node
## Liest einen Xbox-Controller (feste Geräte-ID) oder ersatzweise die Tastatur
## und liefert daraus "Absichten" (Intents) für genau eine Spielfigur.
##
## Xbox-Belegung (siehe auch CONTROLS.md):
##   Linker Stick = Bewegung   Rechter Stick = Kamera
##   A = Springen   X = Schlag   Y = Spezialfähigkeit   B = Rutschen
##   RT oder Stick-Klick links = Sprinten (halten)   LB = Interagieren   Start = Pause
## Tastatur-Ersatz nur, wenn für dieses Gerät kein Controller angeschlossen ist.

const DEADZONE := 0.22
const CAM_DEADZONE := 0.15
const BUTTONS := ["jump", "attack", "special", "slide", "interact"]

var player_index := 0
var device := 0
var keyboard_scheme := -1
## Tests setzen die Werte selbst und umgehen damit die Hardware.
var scripted := false

var move := Vector2.ZERO
var cam := Vector2.ZERO
var sprint := false
var jump_held := false

var _latch := {}
var _prev := {}


func _init() -> void:
	for b in BUTTONS:
		_latch[b] = false
		_prev[b] = false


func has_pad() -> bool:
	return Input.get_connected_joypads().has(device)


## True, wenn die Taste seit dem letzten Abfragen gedrückt wurde (wird verbraucht).
func consume(button: String) -> bool:
	var v: bool = _latch[button]
	_latch[button] = false
	return v


func press(button: String) -> void:
	_latch[button] = true


func clear() -> void:
	for b in BUTTONS:
		_latch[b] = false
	move = Vector2.ZERO
	cam = Vector2.ZERO
	sprint = false
	jump_held = false


func _process(_delta: float) -> void:
	if scripted:
		return
	var now := {}
	if has_pad():
		_read_pad(now)
	elif keyboard_scheme >= 0:
		_read_keyboard(now)
	else:
		clear()
		return
	jump_held = now["jump"]
	for b in BUTTONS:
		if now[b] and not _prev[b]:
			_latch[b] = true
		_prev[b] = now[b]


func _stick(ax: int, ay: int, dz: float) -> Vector2:
	var v := Vector2(Input.get_joy_axis(device, ax), Input.get_joy_axis(device, ay))
	var mag := v.length()
	if mag < dz:
		return Vector2.ZERO
	return v.normalized() * clampf((mag - dz) / (1.0 - dz), 0.0, 1.0)


func _read_pad(now: Dictionary) -> void:
	move = _stick(JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y, DEADZONE)
	if move == Vector2.ZERO:
		move = Vector2(
			float(Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_RIGHT)) - float(Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_LEFT)),
			float(Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_DOWN)) - float(Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_UP)))
	cam = _stick(JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y, CAM_DEADZONE)
	sprint = Input.get_joy_axis(device, JOY_AXIS_TRIGGER_RIGHT) > 0.5 or Input.is_joy_button_pressed(device, JOY_BUTTON_LEFT_STICK)
	now["jump"] = Input.is_joy_button_pressed(device, JOY_BUTTON_A)
	now["attack"] = Input.is_joy_button_pressed(device, JOY_BUTTON_X)
	now["special"] = Input.is_joy_button_pressed(device, JOY_BUTTON_Y)
	now["slide"] = Input.is_joy_button_pressed(device, JOY_BUTTON_B)
	now["interact"] = Input.is_joy_button_pressed(device, JOY_BUTTON_LEFT_SHOULDER)


func _k(key: Key) -> bool:
	return Input.is_physical_key_pressed(key)


func _read_keyboard(now: Dictionary) -> void:
	if keyboard_scheme == 0:
		move = Vector2(float(_k(KEY_D)) - float(_k(KEY_A)), float(_k(KEY_S)) - float(_k(KEY_W)))
		cam = Vector2(float(_k(KEY_R)) - float(_k(KEY_Q)), 0.0)
		sprint = _k(KEY_SHIFT)
		now["jump"] = _k(KEY_SPACE)
		now["attack"] = _k(KEY_J)
		now["special"] = _k(KEY_K)
		now["slide"] = _k(KEY_L)
		now["interact"] = _k(KEY_E)
	else:
		move = Vector2(float(_k(KEY_RIGHT)) - float(_k(KEY_LEFT)), float(_k(KEY_DOWN)) - float(_k(KEY_UP)))
		cam = Vector2(float(_k(KEY_PAGEDOWN)) - float(_k(KEY_PAGEUP)), 0.0)
		sprint = _k(KEY_CTRL)
		now["jump"] = _k(KEY_ENTER)
		now["attack"] = _k(KEY_PERIOD)
		now["special"] = _k(KEY_SLASH)
		now["slide"] = _k(KEY_COMMA)
		now["interact"] = _k(KEY_BACKSLASH)
	if move.length() > 1.0:
		move = move.normalized()
