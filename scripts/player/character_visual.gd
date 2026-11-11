extends Node3D
## Platzhalter-Optik aus einfachen Formen (wird später durch Modelle ersetzt).
## Das Gesicht zeigt zu +Z; der Spieler dreht diesen Knoten in Laufrichtung.

const LUMI_COLOR := Color("ffd36b")
const KIRI_COLOR := Color("5a3f9a")

var hero := 0                 # 0 = Lumi, 1 = Kiri
var speed := 0.0
var grounded := true
var vy := 0.0
var crouch := false
var cloud := false
var gliding := false
var blink := false

var _t := 0.0
var _land := 0.0
var _punch := 0.0
var _pivot: Node3D
var _fist: Node3D
var _wings: Node3D
var _cloud: Node3D


func _mat(c: Color, emit := 0.0, rim := false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = 0.55
	if emit > 0.0:
		m.emission_enabled = true
		m.emission = c
		m.emission_energy_multiplier = emit
	if rim:
		m.rim_enabled = true
		m.rim = 0.9
		m.rim_tint = 0.5
	return m


func _sphere(parent: Node3D, pos: Vector3, r: float, mat: Material, scl := Vector3.ONE) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var s := SphereMesh.new()
	s.radius = r
	s.height = r * 2.0
	s.radial_segments = 20
	s.rings = 10
	mi.mesh = s
	mi.material_override = mat
	mi.position = pos
	mi.scale = scl
	parent.add_child(mi)
	return mi


func build(kind: int) -> void:
	hero = kind
	var base: Color = LUMI_COLOR if kind == 0 else KIRI_COLOR
	var skin := _mat(base, 0.0, kind == 1)
	_pivot = Node3D.new()
	add_child(_pivot)
	# Körper, Kopf (chibi: großer Kopf), Füße
	var body := MeshInstance3D.new()
	var cap := CapsuleMesh.new()
	cap.radius = 0.32
	cap.height = 0.9
	body.mesh = cap
	body.material_override = skin
	body.position = Vector3(0, 0.55, 0)
	_pivot.add_child(body)
	_sphere(_pivot, Vector3(0, 1.22, 0), 0.43, _mat(base.lightened(0.12), 0.0, kind == 1), Vector3(1, 0.92, 1))
	for sx in [-0.17, 0.17]:
		_sphere(_pivot, Vector3(sx, 0.13, 0.04), 0.14, skin)
		# Augen
		var eye_col := Color.WHITE if kind == 0 else Color("7df9ff")
		_sphere(_pivot, Vector3(sx * 1.0, 1.26, 0.36), 0.115, _mat(eye_col, 0.0 if kind == 0 else 1.6))
		_sphere(_pivot, Vector3(sx * 1.0, 1.26, 0.45), 0.055, _mat(Color("15121f")))
	if kind == 0:
		# Lichtfühler
		var stalk := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.top_radius = 0.02
		cm.bottom_radius = 0.03
		cm.height = 0.34
		stalk.mesh = cm
		stalk.material_override = skin
		stalk.position = Vector3(0, 1.8, 0)
		_pivot.add_child(stalk)
		_sphere(_pivot, Vector3(0, 2.02, 0), 0.1, _mat(Color("fff2a8"), 2.5))
		# Licht-Flügel (nur beim Gleiten sichtbar)
		_wings = Node3D.new()
		_wings.visible = false
		_pivot.add_child(_wings)
		for sx in [-1.0, 1.0]:
			var w := MeshInstance3D.new()
			var q := QuadMesh.new()
			q.size = Vector2(0.9, 0.5)
			w.mesh = q
			var wm := _mat(Color("fff2a8"), 2.0)
			wm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			wm.albedo_color.a = 0.6
			wm.cull_mode = BaseMaterial3D.CULL_DISABLED
			w.material_override = wm
			w.position = Vector3(sx * 0.6, 0.9, -0.2)
			w.rotation = Vector3(0, sx * 0.5, sx * 0.3)
			_wings.add_child(w)
	else:
		# Spitze Schattenohren
		for sx in [-0.28, 0.28]:
			var ear := MeshInstance3D.new()
			var em := CylinderMesh.new()
			em.top_radius = 0.0
			em.bottom_radius = 0.13
			em.height = 0.42
			ear.mesh = em
			ear.material_override = skin
			ear.position = Vector3(sx, 1.68, 0)
			ear.rotation = Vector3(0, 0, -sx * 1.2)
			_pivot.add_child(ear)
		# Schattenwolke fürs Dash
		_cloud = Node3D.new()
		_cloud.visible = false
		add_child(_cloud)
		var cm2 := _mat(Color("2a1d4d"), 0.6)
		cm2.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		cm2.albedo_color.a = 0.85
		for p in [Vector3(0, 0.45, 0), Vector3(0.35, 0.35, 0.2), Vector3(-0.35, 0.35, 0.1), Vector3(0, 0.3, -0.35)]:
			_sphere(_cloud, p, 0.42, cm2)
	# Fäuste
	_fist = _sphere(_pivot, Vector3(0.42, 0.75, 0.1), 0.13, skin)
	_sphere(_pivot, Vector3(-0.42, 0.75, 0.1), 0.13, skin)
	# Namensschild (hilft im Splitscreen)
	var label := Label3D.new()
	label.text = "LUMI" if kind == 0 else "KIRI"
	label.font_size = 64
	label.pixel_size = 0.006
	label.outline_size = 14
	label.modulate = base.lightened(0.3)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.position = Vector3(0, 2.45, 0)
	add_child(label)


func punch() -> void:
	_punch = 0.2


func land(strength: float) -> void:
	_land = clampf(strength / 18.0, 0.0, 1.0)


func _process(delta: float) -> void:
	if _pivot == null:
		return
	_t += delta
	_land = move_toward(_land, 0.0, delta * 5.0)
	_punch = maxf(_punch - delta, 0.0)
	var moving := clampf(speed / 6.0, 0.0, 1.0)
	var bob := sin(_t * (6.0 + speed)) * 0.035 * moving + sin(_t * 2.2) * 0.015
	var stretch := clampf(vy / 40.0, -0.08, 0.18) if not grounded else 0.0
	var sy := 1.0 - _land * 0.35 + stretch + bob
	var sxz := 1.0 + _land * 0.2 - stretch * 0.5
	if crouch:
		sy = 0.62
		sxz = 1.15
	_pivot.scale = Vector3(sxz, sy, sxz)
	var lean := deg_to_rad(14.0) * clampf(speed / 9.0, 0.0, 1.0)
	if gliding:
		lean = deg_to_rad(62.0)
	elif crouch:
		lean = deg_to_rad(-22.0)
	_pivot.rotation.x = lerpf(_pivot.rotation.x, lean, 1.0 - exp(-12.0 * delta))
	_pivot.visible = not cloud and not (blink and int(_t * 20.0) % 2 == 0)
	if _wings != null:
		_wings.visible = gliding
	if _cloud != null:
		_cloud.visible = cloud
		_cloud.scale = Vector3.ONE * (1.0 + sin(_t * 30.0) * 0.06)
	if _fist != null:
		var k := _punch / 0.2
		_fist.position = Vector3(0.42, 0.75 + sin(k * PI) * 0.1, 0.1 + sin(k * PI) * 0.8)
