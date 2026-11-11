extends Node3D
## P0-Teststrecke (Code-gebaut). Ziel: Bewegung, Kamera, Fähigkeiten und Kampf ausprobieren.
##
## Aufbau (Blick nach -Z):
##   Startplatz mit Stufen und Übungsgegner
##   Linke Bahn  (Lumi): 9 m breite Lücke, nur mit Licht-Dash + Gleiten zu überwinden
##   Rechte Bahn (Kiri): Schattentor, nur mit Schatten-Dash zu durchqueren
##   Zielplatz mit Checkpoint und zwei Gegnern

const EnemyScript := preload("res://scripts/world/enemy.gd")
const CheckpointScript := preload("res://scripts/world/checkpoint.gd")
const Atmosphere := preload("res://scripts/world/atmosphere.gd")

signal checkpoint_changed(pos: Vector3)

var spawn_point := Vector3(0, 0.3, 6)
var checkpoints: Array = []
var enemies: Array = []
var _grass: StandardMaterial3D
var _dirt: StandardMaterial3D


func _ready() -> void:
	_grass = _mat(Color("6fcf4a"))
	_dirt = _mat(Color("5a3d7a"))
	add_child(Atmosphere.make_sun())
	_build_ground()
	_build_decor()
	_build_enemies()
	_build_checkpoints()


func _mat(c: Color, alpha := 1.0, emit := 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = 0.8
	if alpha < 1.0:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.albedo_color.a = alpha
	if emit > 0.0:
		m.emission_enabled = true
		m.emission = c
		m.emission_energy_multiplier = emit
	return m


func _block(center: Vector3, size: Vector3, mat: Material, layer := 1) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.collision_layer = layer
	body.collision_mask = 0
	body.position = center
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.material_override = mat
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = size
	cs.shape = bs
	body.add_child(mi)
	body.add_child(cs)
	add_child(body)
	return body


func _collider(center: Vector3, size: Vector3) -> void:
	var body := StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	body.position = center
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = size
	cs.shape = bs
	body.add_child(cs)
	add_child(body)


## Plattform von x0..x1, z0..z1 mit Oberkante top.
func _platform(x0: float, x1: float, z0: float, z1: float, top := 0.0) -> void:
	# Erde unten, dünne Grasschicht oben (ohne überlappende Flächen)
	var w := x1 - x0
	var d := z1 - z0
	var cx := (x0 + x1) * 0.5
	var cz := (z0 + z1) * 0.5
	_block(Vector3(cx, top - 0.3 - 1.35, cz), Vector3(w, 2.7, d), _dirt)
	_block(Vector3(cx, top - 0.15, cz), Vector3(w, 0.3, d), _grass)


func _build_ground() -> void:
	# Startplatz
	_platform(-12, 12, -10, 12)
	_block(Vector3(0, 0.5, -3), Vector3(3, 1.0, 2), _mat(Color("ffb86b")))
	_block(Vector3(0, 1.0, -7), Vector3(3, 2.0, 2), _mat(Color("ffb86b")))
	# Linke Bahn (Lumi): Lücke 9 m
	_platform(-12, -6, -24, -10)
	_platform(-12, -6, -47, -33)
	# Rechte Bahn (Kiri) mit Kisten und Schattentor
	_platform(6, 12, -47, -10)
	_block(Vector3(9, 0.5, -18), Vector3(2, 1, 2), _mat(Color("ffb86b")))
	_block(Vector3(9, 0.5, -23), Vector3(2, 1, 2), _mat(Color("ffb86b")))
	_block(Vector3(9, 2.0, -30), Vector3(6.2, 4.0, 0.6), _mat(Color("9b6bff"), 0.55, 1.2), 8)
	# Zielplatz
	_platform(-12, 12, -60, -47)
	# Zielsäulen
	for sx in [-3.0, 3.0]:
		_block(Vector3(sx, 3.0, -58), Vector3(0.8, 6.0, 0.8), _mat(Color("fff2a8"), 1.0, 1.4))
	_block(Vector3(0, 6.2, -58), Vector3(7.2, 0.6, 0.8), _mat(Color("fff2a8"), 1.0, 1.4))


const TREES := ["TwistedTree_1", "TwistedTree_2", "TwistedTree_3", "CommonTree_1", "CommonTree_2", "CommonTree_4", "Pine_1", "Pine_3"]
const SMALL := ["Bush_Common", "Bush_Common_Flowers", "Fern_1", "Flower_3_Group", "Flower_4_Group", "Grass_Common_Tall", "Grass_Wispy_Tall", "Plant_1_Big", "Plant_7_Big", "Clover_1", "Rock_Medium_1", "Rock_Medium_2", "Rock_Medium_3"]


## Stellt ein Modell aus dem Stylized Nature MegaKit (CC0) in die Welt.
func _prop(model: String, pos: Vector3, scl := 1.0, yaw := 0.0) -> Node3D:
	var ps := load("res://assets/nature/%s.gltf" % model) as PackedScene
	if ps == null:
		return null
	var n := ps.instantiate() as Node3D
	n.position = pos
	n.rotation.y = yaw
	n.scale = Vector3.ONE * scl
	add_child(n)
	return n


func _build_decor() -> void:
	var cols := [Color("ff7ad9"), Color("7df9ff"), Color("b6ff6b")]
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	# Bäume rund um die Strecke
	for i in 34:
		var side := -1.0 if i % 2 == 0 else 1.0
		var pos := Vector3(side * rng.randf_range(13, 24), 0, rng.randf_range(-60, 12))
		var s := rng.randf_range(0.9, 1.5)
		_prop(TREES[i % TREES.size()], pos, s, rng.randf() * TAU)
		_collider(pos + Vector3(0, 2.0 * s, 0), Vector3(0.9 * s, 4.0 * s, 0.9 * s))
	# Gras, Blumen, Büsche, Steine auf den Plattformen
	var zones := [Rect2(-12, -10, 24, 22), Rect2(-12, -60, 24, 13), Rect2(-12, -47, 6, 14), Rect2(6, -47, 6, 37), Rect2(-12, -24, 6, 14)]
	for i in 140:
		var z: Rect2 = zones[i % zones.size()]
		var pos2 := Vector3(rng.randf_range(z.position.x + 0.3, z.end.x - 0.3), 0, rng.randf_range(z.position.y + 0.3, z.end.y - 0.3))
		# Nur direkt am Plattformrand, damit Wege und Sicht frei bleiben
		var edge := minf(minf(pos2.x - z.position.x, z.end.x - pos2.x), minf(pos2.z - z.position.y, z.end.y - pos2.z))
		if edge > 1.2:
			continue
		if pos2.x > 7.0 and pos2.x < 11.0 and pos2.z > -31.5 and pos2.z < -28.5:
			continue
		var model: String = SMALL[i % SMALL.size()]
		var sc := rng.randf_range(0.7, 1.1) if not model.begins_with("Rock") else rng.randf_range(0.35, 0.55)
		_prop(model, pos2, sc, rng.randf() * TAU)
	# Leuchtpilze als Alien-Akzent
	for i in 22:
		var pos3 := Vector3(rng.randf_range(-11, 11), 0, rng.randf_range(-59, 11))
		if absf(pos3.x) < 4.5 and pos3.z > -10 and pos3.z < 2:
			continue
		if pos3.z < -10 and pos3.z > -47 and absf(pos3.x) < 6:
			continue
		_mushroom(pos3, cols[i % 3])


func _mushroom(pos: Vector3, glow: Color) -> void:
	var m := Node3D.new()
	m.position = pos
	var stem := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.08
	cm.bottom_radius = 0.12
	cm.height = 0.5
	stem.mesh = cm
	stem.position.y = 0.25
	stem.material_override = _mat(Color("f3ecff"))
	m.add_child(stem)
	var cap := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.32
	sm.height = 0.5
	cap.mesh = sm
	cap.position.y = 0.55
	cap.material_override = _mat(glow, 1.0, 1.6)
	m.add_child(cap)
	add_child(m)


func _spawn_enemy(pos: Vector3, col: Color) -> Node3D:
	var e := CharacterBody3D.new()
	e.set_script(EnemyScript)
	e.color = col
	e.position = pos
	add_child(e)
	enemies.append(e)
	return e


func _build_enemies() -> void:
	_spawn_enemy(Vector3(10, 0.1, 4), Color("ff7aa8"))
	_spawn_enemy(Vector3(-4, 0.1, -55), Color("7ab8ff"))
	_spawn_enemy(Vector3(4, 0.1, -55), Color("ffd36b"))


func _build_checkpoints() -> void:
	var cp := Area3D.new()
	cp.set_script(CheckpointScript)
	cp.position = Vector3(0, 0, -51)
	add_child(cp)
	cp.activated.connect(func(c): checkpoint_changed.emit(c.global_position + Vector3(0, 0.3, 1.5)))
	checkpoints.append(cp)
