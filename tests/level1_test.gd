extends SceneTree
## Automatischer Level-1-Test: ein simulierter Spieler (Bot) läuft beide Routen und das Koop-Rätsel.
## Start: godot --headless --path . --fixed-fps 120 --script res://tests/level1_test.gd

var main: Control
var level: Node3D
var lumi: CharacterBody3D
var kiri: CharacterBody3D
var failures := 0
var checks := 0
var finished_signal := false


func _initialize() -> void:
	call_deferred("_run")


func check(cond: bool, label: String, detail := "") -> void:
	checks += 1
	if cond:
		print("  PASS  ", label)
	else:
		failures += 1
		print("  FAIL  ", label, "  ", detail)


func frames(n: int) -> void:
	for i in n:
		await physics_frame


func secs(s: float) -> void:
	await frames(int(s * 120.0))


func place(p: CharacterBody3D, pos: Vector3, yaw: float) -> void:
	p.global_position = pos
	p.velocity = Vector3.ZERO
	p.input.clear()
	main.rigs[p.player_index].yaw = yaw
	p.face_dir = Vector3(-sin(yaw), 0, -cos(yaw))


## Bot: läuft in Blickrichtung der Kamera, springt an Kanten/Stufen, Lumi nutzt Licht-Dash in der Luft.
## hooks: Callable(p) wird jedes Frame aufgerufen (für Rutschen/Dash an festen Stellen).
func bot_run(p: CharacterBody3D, done: Callable, max_secs: float, hook := Callable()) -> bool:
	var space := p.get_world_3d().direct_space_state
	var air_time := 0.0
	for i in int(max_secs * 120.0):
		await physics_frame
		if done.call(p):
			p.input.clear()
			return true
		p.input.move = Vector2(0, -1)
		p.input.sprint = true
		var fwd: Vector3 = p.face_dir
		if p.is_on_floor():
			air_time = 0.0
			var from: Vector3 = p.global_position + fwd * 1.1 + Vector3.UP * 0.6
			var ground := space.intersect_ray(PhysicsRayQueryParameters3D.create(from, from + Vector3.DOWN * 4.0, 1))
			var wf: Vector3 = p.global_position + Vector3.UP * 0.4
			var wall := space.intersect_ray(PhysicsRayQueryParameters3D.create(wf, wf + fwd * 0.9, 1))
			var step_up: bool = not ground.is_empty() and ground.position.y > p.global_position.y + 0.25
			if (p.state == p.State.NORMAL or p.state == p.State.SLIDE) and (ground.is_empty() or step_up or (not wall.is_empty() and wall.normal.y < 0.5)):
				p.input.press("jump")
				p.input.jump_held = true
		else:
			air_time += 1.0 / 120.0
			p.input.jump_held = air_time < 0.3
			if p.hero == 0 and p.special_ready and air_time > 0.08 and p.state == p.State.NORMAL:
				var any_ground := false
				for d in [3.0, 5.0, 7.0, 9.0]:
					var ahead: Vector3 = p.global_position + fwd * d + Vector3.UP * 5.0
					if not space.intersect_ray(PhysicsRayQueryParameters3D.create(ahead, ahead + Vector3.DOWN * 14.0, 1)).is_empty():
						any_ground = true
				if not any_ground:
					p.input.press("special")
		if hook.is_valid():
			hook.call(p)
	p.input.clear()
	return false


func _run() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await frames(30)
	level = main.level
	lumi = main.players[0]
	kiri = main.players[1]
	level.finished.connect(func(): finished_signal = true)
	for p in main.players:
		p.input.scripted = true
	for e in level.enemies:
		e.active = false

	print("== 1. Start und Stimmung")
	check(lumi.global_position.x < -55 and kiri.global_position.x > 55, "Lumi startet im Westen, Kiri im Osten")
	check(lumi.is_on_floor() and kiri.is_on_floor(), "beide stehen auf dem Boden")
	check(lumi.face_dir.x > 0.9 and kiri.face_dir.x < -0.9, "Startblickrichtung zur Lichtung")
	check(level.mood_at(lumi.global_position) < 0.1, "Lumis Gebiet ist sonnig")
	check(level.mood_at(kiri.global_position) > 0.9, "Kiris Gebiet liegt im Schatten")
	var mid: float = level.mood_at(Vector3(0, 0, 6))
	check(mid > 0.35 and mid < 0.65, "Lichtung liegt dazwischen", str(mid))
	check(main.envs[0] != main.envs[1] and main.rigs[0].camera.environment == main.envs[0], "jede Kamera hat ihr Environment")

	print("== 2. Lumis Route: Stufen, Lücke (Licht-Dash + Gleiten), Pflanzentür")
	var ok_l := await bot_run(lumi, func(p): return p.global_position.x > -22.0 and p.is_on_floor(), 40.0)
	check(ok_l, "Lumi erreicht per Bot die Landung hinter der Lücke", str(lumi.global_position))
	check(lumi.respawns == 0, "Lumi ist dabei nie abgestürzt")
	check(lumi.spawn_position.x > -25 and lumi.spawn_position.x < -16, "Checkpoint auf Lumis Route aktiv", str(lumi.spawn_position))
	check(kiri.spawn_position.x > 50, "Kiris Respawn wurde dadurch NICHT verschoben", str(kiri.spawn_position))
	var door: StaticBody3D = level.lumi_door
	var ok_door := await bot_run(lumi, func(p): return p.global_position.x > -16.0, 8.0)
	check(door.collision_layer == 1, "Pflanzentür blockt den Weg", str(lumi.global_position))
	place(lumi, Vector3(-21, 0.2, 8), -PI / 2)
	await secs(0.3)
	lumi.input.press("interact")
	await secs(2.0)
	check(door.collision_layer == 0, "Lichtkristall öffnet die Pflanzentür")
	var ok_l2 := await bot_run(lumi, func(p): return p.global_position.x > -8.0, 12.0)
	check(ok_l2, "Lumi kommt auf die Lichtung", str(lumi.global_position))

	print("== 3. Kiris Route: Rutschtunnel, Schattentor, Pilzplattformen")
	var hook_k := func(p):
		var x: float = p.global_position.x
		if p.state == p.State.NORMAL and x < 47.0 and x > 45.0 and p.is_on_floor():
			p.input.press("slide")
		if p.state == p.State.NORMAL and x < 35.5 and x > 34.0 and p.special_cd <= 0.0:
			p.input.press("special")
	var ok_k := await bot_run(kiri, func(p): return p.global_position.x < 14.0 and p.is_on_floor(), 40.0, hook_k)
	check(ok_k, "Kiri erreicht per Bot die Lichtung", str(kiri.global_position))
	check(kiri.respawns == 0, "Kiri ist dabei nie abgestürzt")
	check(kiri.spawn_position.x < 31.5 and kiri.spawn_position.x > 25, "Checkpoint hinter dem Schattentor aktiv", str(kiri.spawn_position))
	# Ohne Rutschen kommt man nicht durch den Tunnel
	place(kiri, Vector3(52, 0.2, 6), PI / 2)
	await secs(0.3)
	kiri.input.move = Vector2(0, -1)
	kiri.input.sprint = true
	await secs(2.0)
	check(kiri.global_position.x > 43.0, "Tunneleingang blockt ohne Rutschen", str(kiri.global_position))
	kiri.input.clear()

	print("== 4. Treffen auf der Lichtung")
	place(lumi, Vector3(-3, 0.2, 6), 0.0)
	place(kiri, Vector3(3, 0.2, 6), 0.0)
	await secs(0.5)
	check(level.meeting_done, "Treffen löst Dialog mit Zirp aus")

	print("== 5. Koop-Rätsel")
	# Schlucht ist ohne Brücke nicht überwindbar (Lumi, Licht-Dash + Gleiten)
	place(lumi, Vector3(0, 0.2, 3), 0.0)
	await secs(0.3)
	var r0: int = lumi.respawns
	await bot_run(lumi, func(p): return p.respawns > r0 or (p.global_position.z < -28.0 and p.is_on_floor()), 12.0)
	check(lumi.respawns > r0, "24-m-Schlucht ohne Brücke: Lumi schafft sie nicht", str(lumi.global_position))
	# Falsche Figur: Kiri am Lichtkristall
	place(kiri, Vector3(-9, 0.2, 11), 0.0)
	await secs(0.3)
	kiri.input.press("interact")
	await secs(0.3)
	check(not level.puzzle_barrier_open and level.barrier.collision_layer == 1, "Kiri kann den Lichtkristall nicht benutzen")
	# Schritt 1: Lumi weckt den Kristall
	place(kiri, Vector3(0, 0.2, 13), PI)
	place(lumi, Vector3(-9, 0.2, 11), 0.0)
	await secs(0.3)
	lumi.input.press("interact")
	await secs(2.0)
	check(level.puzzle_barrier_open and level.barrier.collision_layer == 0, "Schritt 1: Dornenwand verschwindet")
	# Schritt 2: Kiri läuft in die Höhle und aktiviert die Schattenplatte
	var ok_cave := await bot_run(kiri, func(p): return p.global_position.z > 22.5, 10.0)
	check(ok_cave, "Kiri kommt in die Höhle", str(kiri.global_position))
	check(not level.bridge_up, "Brücke noch nicht da")
	lumi.input.press("interact")  # Lumi ist nicht in Reichweite der Platte
	kiri.input.press("interact")
	await secs(4.0)
	check(level.bridge_up and absf(level.bridge.position.y + 1.0) < 0.2, "Schritt 2: Schattenbrücke ist ausgefahren", str(level.bridge.position))
	check(level.mood_at(kiri.global_position) > 0.6, "Höhle ist dunkel", str(level.mood_at(kiri.global_position)))
	# Schritt 3: Lumi über die Brücke zur Insel, Kristall wecken
	place(lumi, Vector3(0, 0.2, 2), 0.0)
	await secs(0.3)
	var r1: int = lumi.respawns
	var ok_b := await bot_run(lumi, func(p): return p.global_position.z < -30.0 and p.is_on_floor(), 15.0)
	check(ok_b and lumi.respawns == r1, "Lumi überquert die Brücke", str(lumi.global_position))
	check(absf(level.mood_at(lumi.global_position) - 0.28) < 0.12, "Aussichts-Stimmung warm", str(level.mood_at(lumi.global_position)))
	var gate: StaticBody3D = level.root_gate
	check(gate.collision_layer == 1, "Wurzeltor ist noch zu")
	place(lumi, Vector3(8, 0.2, -32), 0.0)
	await secs(0.3)
	lumi.input.press("interact")
	await secs(2.8)
	check(level.gate_open and gate.collision_layer == 0, "Schritt 3: Wurzeltor öffnet sich")
	# Kiri kommt ebenfalls über die Brücke
	place(kiri, Vector3(0, 0.2, 2), 0.0)
	await secs(0.3)
	var r2: int = kiri.respawns
	var ok_k2 := await bot_run(kiri, func(p): return p.global_position.z < -30.0 and p.is_on_floor(), 15.0)
	check(ok_k2 and kiri.respawns == r2, "Kiri überquert die Brücke ebenfalls", str(kiri.global_position))

	print("== 6. Zum Aussichtspunkt, Level-Ende")
	place(lumi, Vector3(-1.5, 0.2, -40), 0.0)
	place(kiri, Vector3(1.5, 0.2, -40), 0.0)
	await secs(0.3)
	var done_fn := func(p): return p.global_position.z < -71.0
	await bot_run(lumi, done_fn, 20.0)
	await bot_run(kiri, done_fn, 20.0)
	await secs(0.5)
	check(lumi.global_position.z < -70 and kiri.global_position.z < -70, "beide erreichen den Aussichtspunkt", "%s %s" % [lumi.global_position, kiri.global_position])
	check(finished_signal and main.finished, "Level-Ende wurde ausgelöst")

	print("")
	print("ERGEBNIS: %d/%d Prüfungen bestanden" % [checks - failures, checks])
	quit(1 if failures > 0 else 0)
