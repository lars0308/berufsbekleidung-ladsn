extends CharacterBody3D
## Kleiner, niedlicher Hüpfer: wippt kurz (Ankündigung), springt dann auf den nächsten Spieler zu.

const Fx := preload("res://scripts/core/fx.gd")

signal defeated

const GRAVITY := 26.0
const AGGRO_RANGE := 9.0
const HOP_INTERVAL := 1.6
const TELEGRAPH := 0.4
const CONTACT_COOLDOWN := 0.9

var hp := 3
var color := Color("ff7aa8")
var active := true
var _hop_timer := 1.0
var _stun := 0.0
var _flash := 0.0
var _contact_cd := 0.0
var _body: Node3D
var _mat: StandardMaterial3D
var _contact: Area3D
var _dying := false


func _ready() -> void:
	collision_layer = 4
	collision_mask = 1 | 8
	add_to_group("enemies")
	var cs := CollisionShape3D.new()
	var sh := SphereShape3D.new()
	sh.radius = 0.6
	cs.shape = sh
	cs.position.y = 0.6
	add_child(cs)
	_body = Node3D.new()
	add_child(_body)
	_mat = StandardMaterial3D.new()
	_mat.albedo_color = color
	_mat.roughness = 0.5
	var mi := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.6
	sm.height = 1.2
	mi.mesh = sm
	mi.material_override = _mat
	mi.position.y = 0.6
	_body.add_child(mi)
	for sx in [-0.2, 0.2]:
		var eye := MeshInstance3D.new()
		var es := SphereMesh.new()
		es.radius = 0.13
		es.height = 0.26
		eye.mesh = es
		var em := StandardMaterial3D.new()
		em.albedo_color = Color.WHITE
		eye.material_override = em
		eye.position = Vector3(sx, 0.75, 0.48)
		_body.add_child(eye)
		var pupil := MeshInstance3D.new()
		var ps := SphereMesh.new()
		ps.radius = 0.07
		ps.height = 0.14
		pupil.mesh = ps
		var pm := StandardMaterial3D.new()
		pm.albedo_color = Color("15121f")
		pupil.material_override = pm
		pupil.position = Vector3(sx, 0.75, 0.58)
		_body.add_child(pupil)
	_contact = Area3D.new()
	_contact.collision_layer = 0
	_contact.collision_mask = 2
	var ccs := CollisionShape3D.new()
	var csh := SphereShape3D.new()
	csh.radius = 0.85
	ccs.shape = csh
	ccs.position.y = 0.6
	_contact.add_child(ccs)
	add_child(_contact)


func _nearest_player() -> Node3D:
	var best: Node3D = null
	var best_d := AGGRO_RANGE
	for p in get_tree().get_nodes_in_group("players"):
		if p.state == p.State.DEAD:
			continue
		var d := global_position.distance_to(p.global_position)
		if d < best_d:
			best_d = d
			best = p
	return best


func _physics_process(delta: float) -> void:
	if _dying:
		return
	_stun = maxf(_stun - delta, 0.0)
	_flash = maxf(_flash - delta, 0.0)
	_contact_cd = maxf(_contact_cd - delta, 0.0)
	_mat.albedo_color = color.lerp(Color.WHITE, clampf(_flash / 0.15, 0.0, 1.0))
	velocity.y -= GRAVITY * delta
	var squash := 0.0
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0.0, 20.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 20.0 * delta)
		if active and _stun <= 0.0:
			var target := _nearest_player()
			if target != null:
				_hop_timer -= delta
				if _hop_timer <= TELEGRAPH:
					squash = 1.0 - _hop_timer / TELEGRAPH
				if _hop_timer <= 0.0:
					var dir := target.global_position - global_position
					dir.y = 0.0
					dir = dir.normalized()
					velocity = dir * 4.0 + Vector3.UP * 6.5
					_body.rotation.y = atan2(dir.x, dir.z)
					_hop_timer = HOP_INTERVAL
			else:
				_hop_timer = HOP_INTERVAL * 0.5
	_body.scale = Vector3(1.0 + squash * 0.2, 1.0 - squash * 0.3, 1.0 + squash * 0.2)
	move_and_slide()
	if active and _contact_cd <= 0.0:
		for b in _contact.get_overlapping_bodies():
			if b.has_method("take_damage"):
				b.take_damage(1, global_position)
				_contact_cd = CONTACT_COOLDOWN
				break


func take_hit(from_pos: Vector3, damage: int, power: float) -> void:
	if _dying:
		return
	hp -= damage
	_flash = 0.15
	_stun = 0.5
	var dir := global_position - from_pos
	dir.y = 0.0
	dir = dir.normalized() if dir.length() > 0.01 else Vector3.BACK
	velocity = dir * (2.5 * power) + Vector3.UP * (2.0 * minf(power, 2.0))
	Fx.burst(get_parent(), global_position + Vector3.UP * 0.8, Color("fff2a8"), 10, 4.0)
	if hp <= 0:
		_die()


func _die() -> void:
	_dying = true
	remove_from_group("enemies")
	collision_layer = 0
	defeated.emit()
	Fx.burst(get_parent(), global_position + Vector3.UP * 0.6, color, 18, 5.0)
	var tw := create_tween()
	tw.tween_property(_body, "scale", Vector3.ZERO, 0.25)
	tw.tween_callback(queue_free)
