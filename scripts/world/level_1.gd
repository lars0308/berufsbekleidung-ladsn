extends "res://scripts/world/level_base.gd"
## LEVEL 1 – "Getrennt unter zwei Sonnen"
##
## Lumi startet im Westen (sonnig), Kiri im Osten (Schatten). Beide laufen getrennte Routen zur
## Lichtung in der Mitte, treffen die Fee Zirp und lösen gemeinsam das Wurzeltor-Rätsel:
##   1. Lumi weckt den Lichtkristall -> Dornenwand vor der Schatten-Höhle verschwindet
##   2. Kiri aktiviert in der Höhle die Schattenplatte -> Schattenbrücke wächst über die Schlucht
##   3. Lumi läuft über die Brücke und weckt den zweiten Kristall -> das Wurzeltor öffnet sich
##   4. Beide erreichen den Aussichtspunkt -> Level geschafft
## Koordinaten: Lumi-Bahn x -62..-14, Lichtung x -14..14 / z -4..16, Kiri-Bahn x 14..62,
## Schlucht z -4..-28, Insel z -28..-46, Aussicht z -62..-82.

const GATE_COLOR := Color("9b6bff")
const LIGHT_COLOR := Color("fff2a8")
const FAIRY := "Zirp"

var meeting_done := false
var puzzle_barrier_open := false
var bridge_up := false
var gate_open := false
var is_finished := false
var barrier: StaticBody3D
var bridge: StaticBody3D
var root_gate: StaticBody3D
var lumi_door: StaticBody3D
var fairy: Node3D
var crystal_door: Node3D
var crystal_c1: Node3D
var crystal_c2: Node3D
var shadow_pad: Node3D
var _t := 0.0


func mood_at(pos: Vector3) -> float:
	var m := clampf(inverse_lerp(-14.0, 14.0, pos.x), 0.0, 1.0)
	m = smoothstep(0.0, 1.0, m)
	# Hinter der Lichtung (Richtung Aussicht): warmes Abendlicht
	var north := clampf(inverse_lerp(-4.0, -14.0, pos.z), 0.0, 1.0)
	m = lerpf(m, 0.28, north)
	# Schatten-Höhle im Süden der Lichtung
	var cave := clampf(inverse_lerp(15.0, 20.0, pos.z), 0.0, 1.0) * clampf(1.0 - absf(pos.x) / 12.0, 0.0, 1.0)
	return maxf(m, cave)


func build() -> void:
	level_name = "Getrennt unter zwei Sonnen"
	spawn_points = [Vector3(-60, 0.3, 6), Vector3(60, 0.3, 6)]
	spawn_yaws = [-PI / 2.0, PI / 2.0]
	add_child(Atmosphere.make_sun())
	_lumi_route()
	_kiri_route()
	_clearing()
	_puzzle()
	_ending()
	_scenery()
	_shade()
	_decorate()


# ------------------------------------------------------------------ Lumis Route (Westen)

func _lumi_route() -> void:
	platform(-62, -50, 0, 12)
	hint("A  Springen", Vector3(-57, 2.4, 6))
	platform(-48, -45, 2, 10, 0.9)
	platform(-43, -40, 2, 10, 1.8)
	platform(-38, -33, 2, 10, 2.4)
	hint("Y  Licht-Dash, dann gleiten", Vector3(-35.5, 5.2, 6))
	# 10 m breite Lücke (-33 .. -23): nur mit Licht-Dash und Gleiten
	platform(-23, -14, 0, 12)
	checkpoint(Vector3(-20, 0, 6), 0)
	spawn_enemy(Vector3(-18, 0.1, 4), Color("ffd36b"))
	spawn_enemy(Vector3(-18, 0.1, 9), Color("b6ff6b"))
	# Lichtkristall + Pflanzentür
	lumi_door = block(Vector3(-14.5, 2.0, 6), Vector3(1.2, 4.0, 12), mat(Color("3fae4a"), 1.0, 0.15))
	for i in 6:
		prop("Bush_Common_Flowers", Vector3(-15.2, 0, 1.5 + i * 1.9), 1.6, rng.randf() * TAU, false)
	crystal_door = _crystal(Vector3(-21, 0, 10.2), 0)
	crystal_door.used.connect(_on_door_crystal)
	hint("LB  Kristall wecken", Vector3(-21, 4.2, 10.2))


func _on_door_crystal(_p: Node3D) -> void:
	_light_crystal(crystal_door)
	_beam(crystal_door.global_position + Vector3(0, 1.2, 0), lumi_door.global_position + Vector3(0, 1.5, 0), LIGHT_COLOR)
	lumi_door.collision_layer = 0
	var tw := create_tween()
	tw.tween_property(lumi_door, "scale:y", 0.02, 1.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(lumi_door, "position:y", 0.0, 1.4)


# ------------------------------------------------------------------ Kiris Route (Osten)

func _kiri_route() -> void:
	platform(26, 62, 0, 12)
	hint("B  Rutschen", Vector3(46, 2.4, 6))
	hint("Y  Schatten-Dash durchs Tor", Vector3(35, 5.2, 6))
	spawn_enemy(Vector3(51, 0.1, 4), Color("6a4cc4"))
	spawn_enemy(Vector3(51, 0.1, 9), Color("9a5cc4"))
	# Wurzeltunnel (nur rutschend passierbar): Dach liegt 0,95 m über dem Boden
	var root_mat := mat(Color("4a2f66"))
	block(Vector3(40, 1.5, 1.0), Vector3(8, 3.0, 2.0), root_mat)
	block(Vector3(40, 1.5, 11.0), Vector3(8, 3.0, 2.0), root_mat)
	block(Vector3(40, 1.975, 6.0), Vector3(8, 2.05, 8.0), root_mat)
	for i in 4:
		mushroom(Vector3(37 + i * 2.0, 0.0, 2.4 + (i % 2) * 5.2), [Color("ff7ad9"), Color("7df9ff")][i % 2], 0.9)
	# Schattentor (Kollisionsebene 8): nur der Schatten-Dash kommt durch
	block(Vector3(32, 2.0, 6), Vector3(0.6, 4.0, 12.0), mat(GATE_COLOR, 0.55, 1.2), 8)
	checkpoint(Vector3(28.5, 0, 6), 1)
	# Pilzplattformen über die Schlucht zur Lichtung
	platform(20.5, 24, 2, 10, 0.5)
	platform(15, 18, 2, 10, 0.5)
	for p in [Vector3(22.3, 0.5, 2.3), Vector3(16.5, 0.5, 9.7), Vector3(22.3, 0.5, 9.7)]:
		mushroom(p, Color("7df9ff"), 1.1)


# ------------------------------------------------------------------ Lichtung und Rätsel

func _clearing() -> void:
	platform(-14, 14, -4, 16)
	checkpoint(Vector3(0, 0, 10), -1)
	fairy = Node3D.new()
	fairy.position = Vector3(0, 3.2, 4)
	var orb := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.28
	sm.height = 0.56
	orb.mesh = sm
	orb.material_override = mat(Color("b8fff0"), 1.0, 3.0)
	fairy.add_child(orb)
	for sx in [-1.0, 1.0]:
		var w := MeshInstance3D.new()
		var q := QuadMesh.new()
		q.size = Vector2(0.5, 0.3)
		w.mesh = q
		var wm := mat(Color("e8fffa"), 0.6, 1.5)
		wm.cull_mode = BaseMaterial3D.CULL_DISABLED
		w.material_override = wm
		w.position = Vector3(sx * 0.35, 0.1, 0)
		w.rotation.z = sx * 0.5
		fairy.add_child(w)
	var l := OmniLight3D.new()
	l.light_color = Color("b8fff0")
	l.omni_range = 9.0
	l.light_energy = 1.2
	fairy.add_child(l)
	add_child(fairy)
	motes(Vector3(0, 2.5, 6), Vector3(26, 4, 18), Color("b8fff0"), 50)


func _puzzle() -> void:
	# Schatten-Höhle mit Dornenwand
	platform(-5, 5, 16, 27)
	var thorn_mat := mat(Color("c43a6e"), 1.0, 0.3)
	barrier = block(Vector3(0, 1.5, 16.5), Vector3(7, 3.0, 1.0), thorn_mat)
	for i in 14:
		var thorn := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.top_radius = 0.0
		cm.bottom_radius = 0.22
		cm.height = 1.0
		thorn.mesh = cm
		thorn.material_override = thorn_mat
		thorn.position = Vector3(-3.0 + (i % 7) * 1.0, 0.5 + 1.5 * float(i / 7), 0.6)
		thorn.rotation_degrees.x = 90
		barrier.add_child(thorn)
	crystal_c1 = _crystal(Vector3(-9, 0, 12.5), 0)
	crystal_c1.used.connect(_on_c1)
	hint("Lumi: Kristall wecken", Vector3(-9, 4.2, 12.5))
	shadow_pad = _shadow_pad(Vector3(0, 0, 24))
	shadow_pad.used.connect(_on_pad)
	for i in 5:
		mushroom(Vector3(-4 + i * 2.0, 0, 25.5), Color("ff7ad9"), 1.2)
	# Schlucht (z -4 .. -28, 24 m) und Schattenbrücke (zunächst tief unter dem Abgrund)
	bridge = block(Vector3(0, -30, -16), Vector3(6, 2.0, 25), mat(Color("3a2a66"), 0.9, 0.9), 1)
	var edge := mat(GATE_COLOR, 1.0, 2.0)
	for sx in [-3.0, 3.0]:
		var rail := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(0.2, 0.2, 25)
		rail.mesh = bm
		rail.material_override = edge
		rail.position = Vector3(sx, 1.0, 0)
		bridge.add_child(rail)
	# Insel mit zweitem Kristall und dem Wurzeltor
	platform(-14, 14, -46, -28)
	checkpoint(Vector3(0, 0, -31), -1)
	crystal_c2 = _crystal(Vector3(9, 0, -34), 0)
	crystal_c2.used.connect(_on_c2)
	hint("Lumi: Kristall wecken", Vector3(9, 4.2, -34))
	var root_mat := mat(Color("5b3f7a"))
	block(Vector3(-9, 3, -46.6), Vector3(10, 6, 1.2), root_mat)
	block(Vector3(9, 3, -46.6), Vector3(10, 6, 1.2), root_mat)
	root_gate = block(Vector3(0, 3, -46.6), Vector3(8, 6, 1.2), mat(Color("3fae4a"), 1.0, 0.2))
	for i in 8:
		prop("TwistedTree_%d" % (1 + i % 3), Vector3(-3.5 + i, 0, -45.6), 0.35, rng.randf() * TAU, false)


func _on_c1(_p: Node3D) -> void:
	_light_crystal(crystal_c1)
	_beam(crystal_c1.global_position + Vector3(0, 1.2, 0), barrier.global_position + Vector3(0, 1.0, 0), LIGHT_COLOR)
	barrier.collision_layer = 0
	var tw := create_tween()
	tw.tween_property(barrier, "scale", Vector3(1, 0.02, 1), 1.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(barrier, "position:y", 0.0, 1.2)
	puzzle_barrier_open = true
	dialog.emit([[FAIRY, "Die Dornen weichen! Kiri, da hinten liegt eine Schattenplatte."]])


func _on_pad(_p: Node3D) -> void:
	_glow_pad(shadow_pad)
	bridge_up = true
	var tw := create_tween()
	tw.tween_property(bridge, "position:y", -1.0, 3.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	dialog.emit([[FAIRY, "Eine Schattenbrücke! Lumi, jetzt du: Kristall auf der Insel!"]])


func _on_c2(_p: Node3D) -> void:
	_light_crystal(crystal_c2)
	_beam(crystal_c2.global_position + Vector3(0, 1.2, 0), root_gate.global_position, LIGHT_COLOR)
	root_gate.collision_layer = 0
	gate_open = true
	var tw := create_tween()
	tw.tween_property(root_gate, "scale:y", 0.02, 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(root_gate, "position:y", 0.0, 2.0)
	dialog.emit([[FAIRY, "Das Wurzeltor öffnet sich! Folgt mir zum Aussichtspunkt."]])


# ------------------------------------------------------------------ Ende und Aussicht

func _ending() -> void:
	platform(-4, 4, -62, -46)
	platform(-16, 16, -82, -62)
	for sx in [-4.0, 4.0]:
		block(Vector3(sx, 2.5, -80), Vector3(0.6, 5.0, 0.6), mat(Color("fff2a8"), 1.0, 1.4))
	block(Vector3(0, 5.2, -80), Vector3(8.6, 0.5, 0.6), mat(Color("fff2a8"), 1.0, 1.4))
	motes(Vector3(0, 3, -72), Vector3(30, 5, 18), Color("ffd0f0"), 40)


func _scenery() -> void:
	# Fernes Tal mit dem Wrack des Raumschiffs
	var floor_mesh := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(700, 500)
	floor_mesh.mesh = pm
	floor_mesh.material_override = mat(Color("3b2a7a"), 1.0, 0.1)
	floor_mesh.position = Vector3(0, -55, -250)
	floor_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(floor_mesh)
	var ship := Node3D.new()
	ship.position = Vector3(-35, -42, -190)
	ship.rotation_degrees = Vector3(-18, 25, 12)
	var hull := MeshInstance3D.new()
	var cap := CapsuleMesh.new()
	cap.radius = 6.0
	cap.height = 26.0
	hull.mesh = cap
	hull.rotation_degrees.x = 90
	hull.material_override = mat(Color("d9d3ef"), 1.0, 0.1)
	ship.add_child(hull)
	for sx in [-1.0, 1.0]:
		var fin := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(10, 0.8, 7)
		fin.mesh = bm
		fin.position = Vector3(sx * 8.0, 0, 7)
		fin.rotation_degrees.z = sx * 20
		fin.material_override = mat(Color("ff7aa8"), 1.0, 0.2)
		ship.add_child(fin)
	var window := MeshInstance3D.new()
	var ws := SphereMesh.new()
	ws.radius = 2.5
	ws.height = 5.0
	window.mesh = ws
	window.position = Vector3(0, 4.5, -4)
	window.material_override = mat(Color("7df9ff"), 1.0, 2.5)
	ship.add_child(window)
	add_child(ship)
	motes(Vector3(-35, -30, -190), Vector3(30, 30, 30), Color("c8b0ff"), 40)
	# ferne Berge
	for i in 9:
		var mt := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.top_radius = 0.0
		cm.bottom_radius = rng.randf_range(35, 70)
		cm.height = rng.randf_range(60, 130)
		mt.mesh = cm
		mt.position = Vector3(-220 + i * 55.0, -55 + cm.height * 0.5, -330 - rng.randf() * 60)
		mt.material_override = mat(Color("2c2060").lerp(Color("7a46b5"), rng.randf()), 1.0, 0.1)
		mt.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(mt)


func _shade() -> void:
	# Schatten-Dach: wirft nur Schatten, nimmt der Sonne die Kraft über Kiris Bahn und der Höhle
	for d in [[Vector3(46, 10, 6), Vector3(70, 0.4, 44)], [Vector3(0, 8, 22), Vector3(26, 0.4, 24)]]:
		var m := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = d[1]
		m.mesh = bm
		m.position = d[0]
		m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
		add_child(m)


func _decorate() -> void:
	scatter_trees(Rect2(-90, -30, 70, 70), 28, 5.0)
	scatter_trees(Rect2(20, -30, 70, 70), 34, 5.0)
	scatter_trees(Rect2(-30, 17, 60, 40), 14, 6.0)
	scatter_trees(Rect2(-40, -100, 80, 50), 24, 6.0)
	scatter_trees(Rect2(-25, -45, 50, 45), 14, 6.0)
	var keep_clear := [Rect2(-6, -4, 12, 20), Rect2(-16, 0, 4, 12)]
	scatter_edges(150, keep_clear)
	for i in 40:
		var pos := Vector3(rng.randf_range(20, 61), 0, rng.randf_range(0.5, 11.5))
		if near_walkable(pos, -0.4) and not (pos.x > 29 and pos.x < 46):
			mushroom(pos, [Color("ff7ad9"), Color("7df9ff"), Color("b6ff6b")][i % 3], rng.randf_range(0.8, 1.4))
	motes(Vector3(-38, 3, 6), Vector3(50, 4, 10), Color("fff2a8"), 40)
	motes(Vector3(40, 2, 6), Vector3(44, 4, 10), Color("a98bff"), 45)


# ------------------------------------------------------------------ Bauteile für Rätsel

func _crystal(pos: Vector3, hero: int) -> Node3D:
	var it := interactable(pos, hero, "LB")
	var mat_off := mat(Color("5d6a96"), 0.9)
	var mat_on := mat(LIGHT_COLOR, 1.0, 3.0)
	# Kristall: sechseckiger Schaft mit Spitze (pos, Radius unten, Radius oben, Höhe)
	for part in [[Vector3(0, 0.95, 0), 0.38, 0.38, 1.2], [Vector3(0, 2.1, 0), 0.38, 0.0, 1.1]]:
		var mi := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.radial_segments = 6
		cm.rings = 1
		cm.bottom_radius = part[1]
		cm.top_radius = part[2]
		cm.height = part[3]
		mi.mesh = cm
		mi.position = part[0]
		mi.material_override = mat_off
		it.add_child(mi)
	var base := MeshInstance3D.new()
	var bm := CylinderMesh.new()
	bm.top_radius = 0.7
	bm.bottom_radius = 0.9
	bm.height = 0.35
	base.mesh = bm
	base.position.y = 0.17
	base.material_override = mat(Color("6b6a88"))
	it.add_child(base)
	it.set_meta("off", mat_off)
	it.set_meta("on", mat_on)
	return it


func _light_crystal(it: Node3D) -> void:
	for c in it.get_children():
		if c is MeshInstance3D and c.material_override == it.get_meta("off"):
			c.material_override = it.get_meta("on")
	var l := OmniLight3D.new()
	l.light_color = LIGHT_COLOR
	l.omni_range = 12.0
	l.light_energy = 2.0
	l.position.y = 1.6
	it.add_child(l)


func _shadow_pad(pos: Vector3) -> Node3D:
	var it := interactable(pos, 1, "LB")
	var disc := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 1.2
	cm.bottom_radius = 1.2
	cm.height = 0.12
	disc.mesh = cm
	disc.position.y = 0.06
	var off := mat(Color("231a3f"), 1.0, 0.4)
	disc.material_override = off
	it.add_child(disc)
	it.set_meta("disc", disc)
	return it


func _glow_pad(it: Node3D) -> void:
	var disc: MeshInstance3D = it.get_meta("disc")
	disc.material_override = mat(GATE_COLOR, 1.0, 3.0)
	var l := OmniLight3D.new()
	l.light_color = GATE_COLOR
	l.omni_range = 10.0
	l.light_energy = 1.8
	l.position.y = 1.0
	it.add_child(l)


## Kurzer Lichtstrahl von a nach b (verschwindet nach 1,5 s).
func _beam(a: Vector3, b: Vector3, color: Color) -> void:
	var mi := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.07
	cm.bottom_radius = 0.07
	cm.height = a.distance_to(b)
	cm.radial_segments = 8
	mi.mesh = cm
	mi.material_override = mat(color, 0.85, 4.0)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	mi.global_position = (a + b) * 0.5
	var dir := (b - a).normalized()
	var axis := Vector3.UP.cross(dir)
	if axis.length() > 0.001:
		mi.global_transform.basis = Basis(axis.normalized(), Vector3.UP.angle_to(dir))
	get_tree().create_timer(1.5, false).timeout.connect(mi.queue_free)


# ------------------------------------------------------------------ Ablauf

func _process(delta: float) -> void:
	_t += delta
	if fairy != null:
		fairy.position.y += sin(_t * 2.0) * 0.004
		fairy.rotation.y += delta
	var ps := get_tree().get_nodes_in_group("players")
	if ps.size() < 2:
		return
	if not meeting_done:
		var both := true
		for p in ps:
			if not (absf(p.global_position.x) < 11.0 and p.global_position.z > -2.0 and p.global_position.z < 15.0 and p.global_position.y > -2.0):
				both = false
		if both:
			meeting_done = true
			dialog.emit([
				["Lumi", "Kiri!! Da bist du ja!"],
				["Kiri", "Lumi! Ich dachte, ich sehe dich nie wieder."],
				[FAIRY, "Huch, zwei Gestrandete! Euer Schiff ist hinter dem Wurzeltal gelandet."],
				[FAIRY, "Die Schlucht ist zu breit. Licht und Schatten, ihr zwei: Kristall, Höhle, Brücke!"],
			])
	if gate_open and not is_finished:
		var both2 := true
		for p in ps:
			if p.global_position.z > -70.0:
				both2 = false
		if both2:
			is_finished = true
			dialog.emit([[FAIRY, "Seht ihr? Da unten liegt euer Schiff! Auf geht's!"]])
			finished.emit()
