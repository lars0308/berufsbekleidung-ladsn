extends Node3D
## Third-Person-Kamera für genau einen Spieler (rechter Stick dreht, Kollision per SpringArm).

const SENS := 2.8
const ARM_LENGTH := 6.5
const HEIGHT := 1.5
const PITCH_MIN := -1.2
const PITCH_MAX := 0.4

var target: Node3D
var player_input: Node
var yaw := 0.0
var pitch := -0.32
var arm: SpringArm3D
var camera: Camera3D
var _snap := true


func setup(t: Node3D, inp: Node) -> void:
	target = t
	player_input = inp


func _ready() -> void:
	top_level = true
	arm = SpringArm3D.new()
	arm.spring_length = ARM_LENGTH
	arm.collision_mask = 1
	arm.margin = 0.25
	var s := SphereShape3D.new()
	s.radius = 0.3
	arm.shape = s
	add_child(arm)
	camera = Camera3D.new()
	camera.fov = 72.0
	camera.near = 0.1
	camera.far = 300.0
	arm.add_child(camera)
	camera.current = true


func _process(delta: float) -> void:
	if target == null:
		return
	var look: Vector2 = player_input.cam
	yaw -= look.x * SENS * delta
	pitch = clampf(pitch - look.y * SENS * delta, PITCH_MIN, PITCH_MAX)
	rotation = Vector3(pitch, yaw, 0.0)
	var goal := target.global_position + Vector3.UP * HEIGHT
	if _snap:
		global_position = goal
		_snap = false
		return
	var p := global_position
	var k_xz := 1.0 - exp(-14.0 * delta)
	var k_y := 1.0 - exp(-6.0 * delta)
	p.x = lerpf(p.x, goal.x, k_xz)
	p.z = lerpf(p.z, goal.z, k_xz)
	p.y = lerpf(p.y, goal.y, k_y)
	global_position = p


func snap_to_target() -> void:
	_snap = true
