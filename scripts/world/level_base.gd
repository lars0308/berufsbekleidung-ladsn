extends Node3D
## Gemeinsame Bausteine für alle Level: Material, Plattformen, Natur-Modelle, Gegner, Checkpoints.
## Unterklassen überschreiben build() und mood_at().

const EnemyScript := preload("res://scripts/world/enemy.gd")
const CheckpointScript := preload("res://scripts/world/checkpoint.gd")
const InteractableScript := preload("res://scripts/world/interactable.gd")
const Atmosphere := preload("res://scripts/world/atmosphere.gd")

signal checkpoint_changed(pos: Vector3, hero: int)
signal dialog(lines: Array)
signal title(text: String)
signal finished

const TREES := ["TwistedTree_1", "TwistedTree_2", "TwistedTree_3", "CommonTree_1", "CommonTree_2", "CommonTree_4", "Pine_1", "Pine_3"]
const SMALL := ["Bush_Common", "Bush_Common_Flowers", "Fern_1", "Flower_3_Group", "Flower_4_Group", "Grass_Common_Tall", "Grass_Wispy_Tall", "Plant_1_Big", "Plant_7_Big", "Clover_1", "Rock_Medium_1", "Rock_Medium_2", "Rock_Medium_3"]

var level_name := ""
var spawn_points: Array[Vector3] = [Vector3(-1.5, 0.3, 6), Vector3(1.5, 0.3, 6)]
## Kamera-Blickrichtung (Yaw) beim Start: 0 = nach -Z, -PI/2 = nach +X, PI/2 = nach -X
var spawn_yaws: Array[float] = [0.0, 0.0]
var checkpoints: Array = []
var enemies: Array = []
var walk_rects: Array[Rect2] = []
var rng := RandomNumberGenerator.new()
var _grass: StandardMaterial3D
var _dirt: StandardMaterial3D
var _stone: StandardMaterial3D


func _ready() -> void:
	rng.seed = 7
	_grass = mat(Color("4ea84a"))
	_dirt = mat(Color("5a3d7a"))
	_stone = mat(Color("8a84a8"))
	build()


func build() -> void:
	pass


## 0 = sonnig, 1 = Schatten (bestimmt die Himmelsstimmung der jeweiligen Kamera)
func mood_at(_pos: Vector3) -> float:
	return 0.5


# ------------------------------------------------------------------ Bausteine

func mat(c: Color, alpha := 1.0, emit := 0.0) -> StandardMaterial3D:
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


func block(center: Vector3, size: Vector3, material: Material, layer := 1) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.collision_layer = layer
	body.collision_mask = 0
	body.position = center
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.material_override = material
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = size
	cs.shape = bs
	body.add_child(mi)
	body.add_child(cs)
	add_child(body)
	return body


func collider(center: Vector3, size: Vector3, layer := 1) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.collision_layer = layer
	body.collision_mask = 0
	body.position = center
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = size
	cs.shape = bs
	body.add_child(cs)
	add_child(body)
	return body


## Plattform x0..x1, z0..z1 mit Oberkante top (Erde unten, dünne Grasschicht oben).
func platform(x0: float, x1: float, z0: float, z1: float, top := 0.0) -> void:
	var w := x1 - x0
	var d := z1 - z0
	var cx := (x0 + x1) * 0.5
	var cz := (z0 + z1) * 0.5
	block(Vector3(cx, top - 0.3 - 1.35, cz), Vector3(w, 2.7, d), _dirt)
	block(Vector3(cx, top - 0.15, cz), Vector3(w, 0.3, d), _grass)
	walk_rects.append(Rect2(x0, z0, w, d))


func near_walkable(pos: Vector3, margin: float) -> bool:
	for r in walk_rects:
		if r.grow(margin).has_point(Vector2(pos.x, pos.z)):
			return true
	return false


func prop(model: String, pos: Vector3, scl := 1.0, yaw := 0.0, shadow := true) -> Node3D:
	var ps := load("res://assets/nature/%s.gltf" % model) as PackedScene
	if ps == null:
		return null
	var n := ps.instantiate() as Node3D
	n.position = pos
	n.rotation.y = yaw
	n.scale = Vector3.ONE * scl
	add_child(n)
	for g in n.find_children("*", "GeometryInstance3D", true, false):
		g.visibility_range_end = 95.0
		g.visibility_range_end_margin = 12.0
		g.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
		if not shadow:
			g.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return n


## Bäume (abseits der Wege) in einem Rechteck verteilen.
func scatter_trees(area: Rect2, count: int, min_dist := 3.5) -> void:
	var placed := 0
	var tries := 0
	while placed < count and tries < count * 12:
		tries += 1
		var pos := Vector3(rng.randf_range(area.position.x, area.end.x), 0, rng.randf_range(area.position.y, area.end.y))
		if near_walkable(pos, min_dist):
			continue
		prop(TREES[rng.randi() % TREES.size()], pos - Vector3(0, 0.0, 0), rng.randf_range(0.9, 1.6), rng.randf() * TAU)
		placed += 1


## Gras, Blumen, Büsche und Steine am Rand der begehbaren Flächen.
func scatter_edges(count: int, exclude: Array = []) -> void:
	var placed := 0
	var tries := 0
	while placed < count and tries < count * 20 and not walk_rects.is_empty():
		tries += 1
		var r: Rect2 = walk_rects[rng.randi() % walk_rects.size()]
		var pos := Vector3(rng.randf_range(r.position.x + 0.3, r.end.x - 0.3), 0, rng.randf_range(r.position.y + 0.3, r.end.y - 0.3))
		var edge := minf(minf(pos.x - r.position.x, r.end.x - pos.x), minf(pos.z - r.position.y, r.end.y - pos.z))
		if edge > 1.1:
			continue
		var skip := false
		for ex in exclude:
			if (ex as Rect2).has_point(Vector2(pos.x, pos.z)):
				skip = true
		if skip:
			continue
		var model: String = SMALL[rng.randi() % SMALL.size()]
		var is_rock := model.begins_with("Rock")
		var sc := rng.randf_range(0.35, 0.55) if is_rock else rng.randf_range(0.7, 1.1)
		prop(model, Vector3(pos.x, top_at(pos), pos.z), sc, rng.randf() * TAU, is_rock)
		placed += 1


## Höhe der Oberkante an dieser Stelle (nur Platzhalter: Plattformen speichern sie nicht, daher 0).
func top_at(_pos: Vector3) -> float:
	return 0.0


func mushroom(pos: Vector3, glow: Color, s := 1.0) -> void:
	var m := Node3D.new()
	m.position = pos
	var stem := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.08 * s
	cm.bottom_radius = 0.12 * s
	cm.height = 0.5 * s
	stem.mesh = cm
	stem.position.y = 0.25 * s
	stem.material_override = mat(Color("f3ecff"))
	m.add_child(stem)
	var cap := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.32 * s
	sm.height = 0.5 * s
	cap.mesh = sm
	cap.position.y = 0.55 * s
	cap.material_override = mat(glow, 1.0, 1.6)
	cap.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	m.add_child(cap)
	add_child(m)


## Leuchtende Schwebepartikel (Glühwürmchen / Sporen).
func motes(center: Vector3, size: Vector3, color: Color, amount := 40) -> void:
	var p := CPUParticles3D.new()
	p.position = center
	p.amount = amount
	p.lifetime = 6.0
	p.preprocess = 6.0
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	p.emission_box_extents = size * 0.5
	p.direction = Vector3.UP
	p.spread = 180.0
	p.gravity = Vector3.ZERO
	p.initial_velocity_min = 0.2
	p.initial_velocity_max = 0.6
	p.visibility_aabb = AABB(-size, size * 2.0)
	var q := QuadMesh.new()
	q.size = Vector2(0.14, 0.14)
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	m.albedo_color = color
	m.emission_enabled = true
	m.emission = color
	m.emission_energy_multiplier = 2.0
	q.material = m
	p.mesh = q
	add_child(p)


func hint(text: String, pos: Vector3) -> void:
	var l := Label3D.new()
	l.text = text
	l.font_size = 56
	l.pixel_size = 0.007
	l.outline_size = 14
	l.modulate = Color("fff2a8")
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.position = pos
	l.visibility_range_end = 22.0
	add_child(l)


func spawn_enemy(pos: Vector3, col: Color) -> Node3D:
	var e := CharacterBody3D.new()
	e.set_script(EnemyScript)
	e.color = col
	e.position = pos
	add_child(e)
	enemies.append(e)
	return e


func checkpoint(pos: Vector3, hero := -1) -> Area3D:
	var cp := Area3D.new()
	cp.set_script(CheckpointScript)
	cp.hero = hero
	cp.position = pos
	add_child(cp)
	cp.activated.connect(func(c): checkpoint_changed.emit(c.global_position + Vector3(0, 0.3, 1.5), c.hero))
	checkpoints.append(cp)
	return cp


func interactable(pos: Vector3, hero: int, text := "LB") -> Node3D:
	var it := Node3D.new()
	it.set_script(InteractableScript)
	it.position = pos
	it.hero_required = hero
	it.prompt = text
	add_child(it)
	return it
