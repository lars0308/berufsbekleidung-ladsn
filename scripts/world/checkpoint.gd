extends Area3D
## Checkpoint-Fahne. hero = -1: gilt für beide; 0/1: nur für diesen Spieler (getrennte Routen).

signal activated(cp)

var active := false
var hero := -1
var _flag_mat: StandardMaterial3D


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	var cs := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = Vector3(5, 4, 5)
	cs.shape = sh
	cs.position.y = 2.0
	add_child(cs)
	var pole := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.06
	cm.bottom_radius = 0.08
	cm.height = 3.0
	pole.mesh = cm
	pole.position.y = 1.5
	var pm := StandardMaterial3D.new()
	pm.albedo_color = Color("e8e0ff")
	pole.material_override = pm
	add_child(pole)
	var flag := MeshInstance3D.new()
	var qm := QuadMesh.new()
	qm.size = Vector2(1.1, 0.7)
	flag.mesh = qm
	flag.position = Vector3(0.55, 2.6, 0)
	_flag_mat = StandardMaterial3D.new()
	_flag_mat.albedo_color = Color("6b6b8a")
	_flag_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	flag.material_override = _flag_mat
	add_child(flag)
	body_entered.connect(_on_body)


func _on_body(body: Node3D) -> void:
	if active or not body.is_in_group("players"):
		return
	if hero >= 0 and body.hero != hero:
		return
	active = true
	_flag_mat.albedo_color = Color("7dffb0")
	_flag_mat.emission_enabled = true
	_flag_mat.emission = Color("7dffb0")
	_flag_mat.emission_energy_multiplier = 1.5
	activated.emit(self)
