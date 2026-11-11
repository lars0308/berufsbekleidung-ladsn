extends CharacterBody3D
## Eine der beiden Spielfiguren. Lumi = Licht (Luft-Dash + Gleiten), Kiri = Schatten (Boden-Dash).
##
## Kollisions-Ebenen (Bit-Werte): 1 Welt, 2 Spieler, 4 Gegner, 8 Schattentor.

const PlayerInputScript := preload("res://scripts/player/player_input.gd")
const VisualScript := preload("res://scripts/player/character_visual.gd")
const Fx := preload("res://scripts/core/fx.gd")

enum Hero { LUMI, KIRI }
enum State { NORMAL, SLIDE, DASH, GLIDE, HURT, DEAD }

const LAYER_WORLD := 1
const LAYER_PLAYER := 2
const LAYER_ENEMY := 4
const LAYER_SHADOW_GATE := 8

const MAX_HP := 5
const WALK_SPEED := 6.0
const SPRINT_SPEED := 9.5
const ACCEL := 45.0
const DECEL := 55.0
const AIR_ACCEL := 22.0
const JUMP_VELOCITY := 9.2
const GRAVITY := 28.0
const FALL_MULT := 1.35
const MAX_FALL := 30.0
const COYOTE_TIME := 0.12
const JUMP_BUFFER := 0.14

const SLIDE_SPEED := 11.0
const SLIDE_TIME := 0.6
const STAND_HEIGHT := 1.4
const SLIDE_HEIGHT := 0.8

const LUMI_DASH_SPEED := 15.0
const LUMI_DASH_TIME := 0.22
const LUMI_DASH_RISE := 4.0
const GLIDE_TIME := 1.8
const GLIDE_SPEED := 8.0
const GLIDE_FALL := 2.2

const KIRI_DASH_SPEED := 20.0
const KIRI_DASH_TIME := 0.28
const KIRI_COOLDOWN := 1.4
const KIRI_SLIDE_SPEED := 12.0

const ATTACK_TIME := [0.30, 0.30, 0.50]
const ATTACK_HIT_AT := [0.10, 0.10, 0.18]
const ATTACK_DAMAGE := [1, 1, 2]
const ATTACK_POWER := [1.0, 1.0, 2.2]
const COMBO_WINDOW := 0.45
const AIM_RANGE := 3.5

const HURT_TIME := 0.35
const INVULN_TIME := 1.2
const DEAD_TIME := 0.9

var hero: int = Hero.LUMI
var player_index := 0
var device := 0
var input: Node
var camera_rig: Node3D
var visual: Node3D
var spawn_position := Vector3.ZERO
var kill_y := -14.0
var hp := MAX_HP
var state: int = State.NORMAL
var face_dir := Vector3(0, 0, -1)

var coyote := 0.0
var jump_buffer := 0.0
var invuln := 0.0
var state_time := 0.0
var slide_dir := Vector3.ZERO
var slide_speed := 0.0
var dash_dir := Vector3.ZERO
var special_ready := true
var special_cd := 0.0
var glide_time := 0.0
var is_cloud := false
var attack_time := 0.0
var attack_step := 0
var combo_window := 0.0
var hit_timer := -1.0
var cur_attack := 0
var dead_time := 0.0
var respawns := 0

var _shape: CapsuleShape3D
var _col: CollisionShape3D
var _jumping := false
var _was_floor := true


func setup(kind: int, index: int, device_id: int) -> void:
	hero = kind
	player_index = index
	device = device_id


func _ready() -> void:
	collision_layer = LAYER_PLAYER
	collision_mask = LAYER_WORLD | LAYER_ENEMY | LAYER_SHADOW_GATE
	floor_snap_length = 0.35
	floor_max_angle = deg_to_rad(50.0)
	floor_stop_on_slope = true
	_shape = CapsuleShape3D.new()
	_shape.radius = 0.4
	_shape.height = STAND_HEIGHT
	_col = CollisionShape3D.new()
	_col.shape = _shape
	_col.position.y = STAND_HEIGHT * 0.5
	add_child(_col)
	input = PlayerInputScript.new()
	input.player_index = player_index
	input.device = device
	input.keyboard_scheme = player_index
	add_child(input)
	visual = VisualScript.new()
	add_child(visual)
	visual.build(hero)
	add_to_group("players")
	spawn_position = global_position


# ------------------------------------------------------------------ Abfragen

## 0..1 für die HUD-Anzeige der Spezialfähigkeit.
func special_ratio() -> float:
	if hero == Hero.LUMI:
		if state == State.GLIDE:
			return glide_time / GLIDE_TIME
		return 1.0 if special_ready else 0.0
	return 1.0 - clampf(special_cd / KIRI_COOLDOWN, 0.0, 1.0)


func _wish() -> Vector3:
	var m: Vector2 = input.move
	var yaw: float = camera_rig.yaw if camera_rig != null else 0.0
	var fwd := Vector3(-sin(yaw), 0.0, -cos(yaw))
	var right := Vector3(cos(yaw), 0.0, -sin(yaw))
	return (right * m.x + fwd * -m.y).limit_length(1.0)


# ------------------------------------------------------------------ Schleife

func _physics_process(delta: float) -> void:
	_tick(delta)
	if state == State.DEAD:
		dead_time -= delta
		if dead_time <= 0.0:
			respawn()
		_sync_visual()
		return
	var on_floor := is_on_floor()
	if on_floor:
		coyote = COYOTE_TIME
		special_ready = true
		if state == State.GLIDE:
			_end_glide()
	if input.consume("jump"):
		jump_buffer = JUMP_BUFFER
	match state:
		State.NORMAL:
			_state_normal(delta, on_floor)
		State.SLIDE:
			_state_slide(delta, on_floor)
		State.DASH:
			_state_dash(delta)
		State.GLIDE:
			_state_glide(delta)
		State.HURT:
			_state_hurt(delta)
	move_and_slide()
	_post_move()
	if global_position.y < kill_y:
		fall_respawn()
	_sync_visual()


func _tick(delta: float) -> void:
	coyote = maxf(coyote - delta, 0.0)
	jump_buffer = maxf(jump_buffer - delta, 0.0)
	invuln = maxf(invuln - delta, 0.0)
	special_cd = maxf(special_cd - delta, 0.0)
	if attack_time > 0.0:
		attack_time -= delta
		if attack_time <= 0.0:
			combo_window = COMBO_WINDOW
	elif combo_window > 0.0:
		combo_window -= delta
		if combo_window <= 0.0:
			attack_step = 0
	if hit_timer >= 0.0:
		hit_timer -= delta
		if hit_timer < 0.0:
			hit_timer = -1.0
			_do_hit()


func _gravity(delta: float) -> void:
	var g := GRAVITY * (FALL_MULT if velocity.y < 0.0 else 1.0)
	velocity.y = maxf(velocity.y - g * delta, -MAX_FALL)


func _horizontal() -> Vector3:
	return Vector3(velocity.x, 0.0, velocity.z)


func _set_horizontal(h: Vector3) -> void:
	velocity.x = h.x
	velocity.z = h.z


# ------------------------------------------------------------------ Zustände

func _state_normal(delta: float, on_floor: bool) -> void:
	var wish := _wish()
	var has_wish := wish.length() > 0.1
	var top := SPRINT_SPEED if input.sprint else WALK_SPEED
	if attack_time > 0.0:
		top *= 0.25
	var h := _horizontal()
	if has_wish:
		h = h.move_toward(wish * top, (ACCEL if on_floor else AIR_ACCEL) * delta)
		if attack_time <= 0.0:
			face_dir = wish.normalized()
	else:
		h = h.move_toward(Vector3.ZERO, (DECEL if on_floor else 4.0) * delta)
	_set_horizontal(h)
	_gravity(delta)
	# Springen mit Coyote-Time und Eingabe-Puffer, variable Sprunghöhe
	if jump_buffer > 0.0 and coyote > 0.0:
		velocity.y = JUMP_VELOCITY
		jump_buffer = 0.0
		coyote = 0.0
		_jumping = true
		attack_time = 0.0
	elif _jumping and velocity.y > 0.0 and not input.jump_held:
		velocity.y *= 0.55
		_jumping = false
	if velocity.y <= 0.0:
		_jumping = false
	# Aktionen
	if input.consume("special"):
		_try_special(on_floor)
	elif input.consume("slide") and on_floor:
		var dir := wish.normalized() if has_wish else face_dir
		_start_slide(dir, SLIDE_SPEED)
	elif input.consume("attack"):
		_try_attack()
	input.consume("interact")


func _start_slide(dir: Vector3, spd: float) -> void:
	state = State.SLIDE
	state_time = SLIDE_TIME
	slide_dir = dir
	slide_speed = spd
	face_dir = dir
	attack_time = 0.0
	_set_crouch(true)


func _state_slide(delta: float, on_floor: bool) -> void:
	state_time -= delta
	slide_speed = move_toward(slide_speed, 4.0, 11.0 * delta)
	var wish := _wish()
	if wish.length() > 0.1:
		slide_dir = slide_dir.slerp(wish.normalized(), clampf(2.5 * delta, 0.0, 1.0))
	face_dir = slide_dir
	_set_horizontal(slide_dir * slide_speed)
	_gravity(delta)
	if jump_buffer > 0.0 and on_floor and not _blocked_above():
		velocity.y = JUMP_VELOCITY
		jump_buffer = 0.0
		_jumping = true
		_set_horizontal(slide_dir * (slide_speed + 3.0))
		_end_slide()
		return
	if state_time <= 0.0 and not _blocked_above():
		_end_slide()
	input.consume("attack")
	input.consume("special")


func _end_slide() -> void:
	_set_crouch(false)
	state = State.NORMAL


func _set_crouch(on: bool) -> void:
	var h := SLIDE_HEIGHT if on else STAND_HEIGHT
	_shape.height = h
	_col.position.y = h * 0.5


## True, wenn über dem Spieler zu wenig Platz zum Aufstehen ist.
func _blocked_above() -> bool:
	if _shape.height >= STAND_HEIGHT:
		return false
	_shape.height = STAND_HEIGHT
	_col.position.y = STAND_HEIGHT * 0.5
	var blocked := test_move(global_transform, Vector3.UP * 0.05)
	_shape.height = SLIDE_HEIGHT
	_col.position.y = SLIDE_HEIGHT * 0.5
	return blocked


func _try_special(on_floor: bool) -> void:
	if hero == Hero.LUMI:
		if not special_ready:
			return
		special_ready = false
		var w := _wish()
		dash_dir = w.normalized() if w.length() > 0.1 else face_dir
		face_dir = dash_dir
		state = State.DASH
		state_time = LUMI_DASH_TIME
		attack_time = 0.0
		_jumping = false
		velocity = dash_dir * LUMI_DASH_SPEED + Vector3.UP * LUMI_DASH_RISE
	else:
		if special_cd > 0.0 or not on_floor:
			return
		var w2 := _wish()
		dash_dir = w2.normalized() if w2.length() > 0.1 else face_dir
		face_dir = dash_dir
		special_cd = KIRI_COOLDOWN
		state = State.DASH
		state_time = KIRI_DASH_TIME
		attack_time = 0.0
		_set_cloud(true)
		velocity = dash_dir * KIRI_DASH_SPEED


func _set_cloud(on: bool) -> void:
	is_cloud = on
	if on:
		collision_mask &= ~LAYER_SHADOW_GATE
	else:
		collision_mask |= LAYER_SHADOW_GATE


func _state_dash(delta: float) -> void:
	state_time -= delta
	input.consume("attack")
	input.consume("special")
	if hero == Hero.LUMI:
		velocity.x = dash_dir.x * LUMI_DASH_SPEED
		velocity.z = dash_dir.z * LUMI_DASH_SPEED
		velocity.y = LUMI_DASH_RISE
		if state_time <= 0.0:
			state = State.GLIDE
			glide_time = GLIDE_TIME
			velocity.y = 0.0
	else:
		velocity.x = dash_dir.x * KIRI_DASH_SPEED
		velocity.z = dash_dir.z * KIRI_DASH_SPEED
		velocity.y = -1.0
		if state_time <= 0.0:
			# Nicht in einem Tor wieder fest werden: erst aufhören, wenn frei.
			_set_cloud(false)
			if test_move(global_transform, Vector3.ZERO):
				_set_cloud(true)
				state_time = 0.05
				velocity = dash_dir * 6.0
			else:
				_start_slide(dash_dir, KIRI_SLIDE_SPEED)


func _state_glide(delta: float) -> void:
	glide_time -= delta
	var wish := _wish()
	var target := wish * GLIDE_SPEED if wish.length() > 0.1 else face_dir * GLIDE_SPEED * 0.8
	_set_horizontal(_horizontal().move_toward(target, 12.0 * delta))
	if wish.length() > 0.1:
		face_dir = wish.normalized()
	velocity.y = move_toward(velocity.y, -GLIDE_FALL, 18.0 * delta)
	if glide_time <= 0.0 or input.consume("jump") or input.consume("slide"):
		_end_glide()
	input.consume("attack")
	input.consume("special")


func _end_glide() -> void:
	if state == State.GLIDE:
		state = State.NORMAL


func _state_hurt(delta: float) -> void:
	state_time -= delta
	_gravity(delta)
	_set_horizontal(_horizontal().move_toward(Vector3.ZERO, 6.0 * delta))
	for b in ["attack", "special", "slide"]:
		input.consume(b)
	if state_time <= 0.0:
		state = State.NORMAL


func _post_move() -> void:
	var f := is_on_floor()
	if f and not _was_floor:
		visual.land(-_last_vy)
		if _last_vy < -6.0:
			Fx.burst(get_parent(), global_position + Vector3.UP * 0.1, Color(1, 1, 1, 0.8), 8, 2.0)
	_was_floor = f
	_last_vy = velocity.y


var _last_vy := 0.0


func _sync_visual() -> void:
	var yaw := atan2(face_dir.x, face_dir.z)
	visual.rotation.y = lerp_angle(visual.rotation.y, yaw, 0.35)
	visual.speed = _horizontal().length()
	visual.grounded = is_on_floor()
	visual.vy = velocity.y
	visual.crouch = state == State.SLIDE
	visual.cloud = is_cloud
	visual.gliding = state == State.GLIDE
	visual.blink = invuln > 0.0 and state != State.DEAD
	visual.visible = state != State.DEAD


# ------------------------------------------------------------------ Kampf

func _try_attack() -> void:
	if attack_time > 0.0:
		return
	cur_attack = attack_step
	attack_time = ATTACK_TIME[cur_attack]
	hit_timer = ATTACK_HIT_AT[cur_attack]
	combo_window = 0.0
	_aim_assist()
	var lunge := 3.5 if cur_attack < 2 else 6.0
	velocity.x += face_dir.x * lunge
	velocity.z += face_dir.z * lunge
	attack_step = (attack_step + 1) % 3
	visual.punch()


func _aim_assist() -> void:
	var w := _wish()
	if w.length() > 0.1:
		face_dir = w.normalized()
	var best: Node3D = null
	var best_d := AIM_RANGE
	for e in get_tree().get_nodes_in_group("enemies"):
		var d := global_position.distance_to(e.global_position)
		if d < best_d:
			var to: Vector3 = (e.global_position - global_position)
			to.y = 0.0
			if to.length() > 0.01 and face_dir.dot(to.normalized()) > -0.2:
				best = e
				best_d = d
	if best != null:
		var to2: Vector3 = best.global_position - global_position
		to2.y = 0.0
		face_dir = to2.normalized()


func _do_hit() -> void:
	var space := get_world_3d().direct_space_state
	var q := PhysicsShapeQueryParameters3D.new()
	var s := SphereShape3D.new()
	s.radius = 1.4
	q.shape = s
	q.transform = Transform3D(Basis(), global_position + face_dir * 1.1 + Vector3.UP * 0.9)
	q.collision_mask = LAYER_ENEMY
	for r in space.intersect_shape(q, 8):
		var c: Object = r.collider
		if c != null and c.has_method("take_hit"):
			c.take_hit(global_position, ATTACK_DAMAGE[cur_attack], ATTACK_POWER[cur_attack])


func take_damage(amount: int, from_pos: Vector3) -> void:
	if invuln > 0.0 or state == State.DEAD:
		return
	hp -= amount
	invuln = INVULN_TIME
	_cancel_actions()
	var dir := global_position - from_pos
	dir.y = 0.0
	dir = dir.normalized() if dir.length() > 0.01 else -face_dir
	velocity = dir * 7.0 + Vector3.UP * 5.0
	if hp <= 0:
		state = State.DEAD
		dead_time = DEAD_TIME
		velocity = Vector3.ZERO
	else:
		state = State.HURT
		state_time = HURT_TIME


func _cancel_actions() -> void:
	if state == State.SLIDE:
		_set_crouch(false)
	_set_cloud(false)
	attack_time = 0.0
	hit_timer = -1.0
	state = State.NORMAL


# ------------------------------------------------------------------ Respawn

func _teleport_to_spawn() -> void:
	global_position = spawn_position
	velocity = Vector3.ZERO
	_cancel_actions()
	if camera_rig != null:
		camera_rig.snap_to_target()
	respawns += 1


func respawn() -> void:
	hp = MAX_HP
	_teleport_to_spawn()
	invuln = 1.5
	state = State.NORMAL


## Sturz ins Leere kostet keine Lebenspunkte, nur kurze Unverwundbarkeit.
func fall_respawn() -> void:
	_teleport_to_spawn()
	invuln = 1.0
