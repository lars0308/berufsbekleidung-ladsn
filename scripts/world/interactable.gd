extends Node3D
## Etwas, das ein Spieler per Interaktionstaste (LB / E) benutzt. Zeigt einen Hinweis in der Nähe.

signal used(player)

const PLAYER_NAMES := ["Lumi", "Kiri"]

var hero_required := -1       # -1 = beide, 0 = nur Lumi, 1 = nur Kiri
var prompt := "LB"
var radius := 2.8
var one_shot := true
var enabled := true
var done := false
var _label: Label3D


func _ready() -> void:
	add_to_group("interactables")
	_label = Label3D.new()
	_label.font_size = 48
	_label.pixel_size = 0.006
	_label.outline_size = 12
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label.no_depth_test = true
	_label.position = Vector3(0, 2.4, 0)
	_label.visible = false
	add_child(_label)


func can_use(p: Node3D) -> bool:
	return enabled and not done and (hero_required < 0 or p.hero == hero_required) \
		and p.state != p.State.DEAD and p.global_position.distance_to(global_position) < radius


func use(p: Node3D) -> void:
	if one_shot:
		done = true
	used.emit(p)


func _process(_delta: float) -> void:
	if done or not enabled:
		_label.visible = false
		return
	var ok := false
	var near := -1
	for p in get_tree().get_nodes_in_group("players"):
		if p.global_position.distance_to(global_position) < radius + 1.0:
			near = p.hero
			if hero_required < 0 or p.hero == hero_required:
				ok = true
	if ok:
		_label.text = prompt
		_label.modulate = Color("fff2a8")
	elif near >= 0:
		_label.text = "Nur %s" % PLAYER_NAMES[hero_required]
		_label.modulate = Color(1, 1, 1, 0.5)
	_label.visible = ok or near >= 0
