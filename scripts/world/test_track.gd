extends "res://scripts/world/level_base.gd"
## P0-Teststrecke (Blick nach -Z): Startplatz mit Stufen, linke Bahn mit 9-m-Lücke (Lumi),
## rechte Bahn mit Schattentor (Kiri), Zielplatz mit Checkpoint und zwei Gegnern.

func build() -> void:
	level_name = "Teststrecke"
	spawn_points = [Vector3(-1.5, 0.3, 6), Vector3(1.5, 0.3, 6)]
	add_child(Atmosphere.make_sun())
	var orange := mat(Color("ffb86b"))
	platform(-12, 12, -10, 12)
	block(Vector3(0, 0.5, -3), Vector3(3, 1.0, 2), orange)
	block(Vector3(0, 1.0, -7), Vector3(3, 2.0, 2), orange)
	platform(-12, -6, -24, -10)
	platform(-12, -6, -47, -33)
	platform(6, 12, -47, -10)
	block(Vector3(9, 0.5, -18), Vector3(2, 1, 2), orange)
	block(Vector3(9, 0.5, -23), Vector3(2, 1, 2), orange)
	block(Vector3(9, 2.0, -30), Vector3(6.2, 4.0, 0.6), mat(Color("9b6bff"), 0.55, 1.2), 8)
	platform(-12, 12, -60, -47)
	for sx in [-3.0, 3.0]:
		block(Vector3(sx, 3.0, -58), Vector3(0.8, 6.0, 0.8), mat(Color("fff2a8"), 1.0, 1.4))
	block(Vector3(0, 6.2, -58), Vector3(7.2, 0.6, 0.8), mat(Color("fff2a8"), 1.0, 1.4))
	scatter_trees(Rect2(-26, -66, 52, 84), 30, 4.0)
	scatter_edges(70, [Rect2(-4.5, -10, 9, 12)])
	for i in 14:
		var pos := Vector3(rng.randf_range(-11, 11), 0, rng.randf_range(-59, 11))
		if near_walkable(pos, -0.5) and not (absf(pos.x) < 4.5 and pos.z > -10 and pos.z < 2) and not (pos.z < -10 and pos.z > -47 and absf(pos.x) < 6):
			mushroom(pos, [Color("ff7ad9"), Color("7df9ff"), Color("b6ff6b")][i % 3])
	spawn_enemy(Vector3(10, 0.1, 4), Color("ff7aa8"))
	spawn_enemy(Vector3(-4, 0.1, -55), Color("7ab8ff"))
	spawn_enemy(Vector3(4, 0.1, -55), Color("ffd36b"))
	checkpoint(Vector3(0, 0, -51), -1)
