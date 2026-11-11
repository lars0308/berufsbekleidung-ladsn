extends SceneTree
## Automatischer P0-Test (ohne Hardware, Eingaben werden simuliert).
## Start: godot --headless --path . --fixed-fps 120 --script res://tests/p0_test.gd

var main: Control
var lumi: CharacterBody3D
var kiri: CharacterBody3D
var failures := 0
var checks := 0


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


func reset(p: CharacterBody3D, pos: Vector3) -> void:
	p.global_position = pos
	p.velocity = Vector3.ZERO
	p.state = p.State.NORMAL
	p.hp = p.MAX_HP
	p.input.clear()
	p.special_ready = true
	p.special_cd = 0.0
	p.face_dir = Vector3(0, 0, -1)


func _run() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await frames(30)
	lumi = main.players[0]
	kiri = main.players[1]
	for p in main.players:
		p.input.scripted = true
	for e in main.level.enemies:
		e.active = false

	print("== 1. Aufbau")
	check(main.viewports.size() == 2, "zwei Viewports")
	check(main.viewports[0].find_world_3d() == main.viewports[1].find_world_3d(), "gemeinsame 3D-Welt")
	check(main.rigs[0].camera.current and main.rigs[1].camera.current, "beide Kameras aktiv")
	check(main.rigs[0].camera.get_viewport() != main.rigs[1].camera.get_viewport(), "Kameras in getrennten Viewports")
	check(lumi.is_on_floor() and kiri.is_on_floor(), "beide Figuren stehen auf dem Boden")

	print("== 2. Unabhängige Steuerung")
	var k0 := kiri.global_position
	lumi.input.move = Vector2(0, -1)
	lumi.input.sprint = true
	await secs(1.0)
	check(lumi.global_position.z < 6 - 5.0, "Lumi läuft nach vorn", str(lumi.global_position))
	check(kiri.global_position.distance_to(k0) < 0.2, "Kiri bleibt stehen", str(kiri.global_position))
	lumi.input.clear()
	kiri.input.move = Vector2(1, 0)
	var l0 := lumi.global_position
	await secs(0.5)
	check(kiri.global_position.x > k0.x + 1.5, "Kiri läuft nach rechts")
	check(lumi.global_position.distance_to(l0) < 1.0, "Lumi bleibt (nur Auslaufen)")
	kiri.input.clear()
	await secs(0.5)

	print("== 3. Springen, Sprunghöhe")
	reset(lumi, Vector3(-3, 0.1, 8))
	await secs(0.3)
	var peak := 0.0
	lumi.input.press("jump")
	lumi.input.jump_held = true
	for i in 120:
		await physics_frame
		peak = maxf(peak, lumi.global_position.y)
	check(peak > 1.0 and peak < 2.2, "Sprung erreicht ~1.5 m", "peak=%.2f" % peak)
	check(lumi.is_on_floor(), "Landung auf dem Boden")
	# Kurz getippter Sprung ist niedriger
	lumi.input.jump_held = false
	lumi.input.press("jump")
	var peak2 := 0.0
	for i in 120:
		await physics_frame
		peak2 = maxf(peak2, lumi.global_position.y)
	check(peak2 < peak - 0.2, "Tipp-Sprung niedriger (variable Höhe)", "%.2f < %.2f" % [peak2, peak])

	print("== 4. Rutschen")
	reset(kiri, Vector3(3, 0.1, 8))
	await secs(0.3)
	kiri.input.move = Vector2(0, -1)
	kiri.input.press("slide")
	await secs(0.1)
	check(kiri.state == kiri.State.SLIDE, "Rutschen startet")
	check(kiri._shape.height < 1.0, "Kollisionsform geduckt")
	await secs(1.0)
	check(kiri.state != kiri.State.SLIDE and kiri._shape.height > 1.3, "Rutschen endet, Figur steht wieder")
	kiri.input.clear()

	print("== 5. Lumi: Licht-Dash + Gleiten über 9-m-Lücke")
	reset(lumi, Vector3(-9, 0.1, -20))
	await secs(0.3)
	lumi.input.move = Vector2(0, -1)
	lumi.input.sprint = true
	var guard := 0
	while lumi.global_position.z > -23.3 and guard < 600:
		await physics_frame
		guard += 1
	lumi.input.press("jump")
	lumi.input.jump_held = true
	await secs(0.12)
	lumi.input.press("special")
	var saw_glide := false
	var min_y := 99.0
	for i in 720:
		await physics_frame
		if lumi.state == lumi.State.GLIDE:
			saw_glide = true
		min_y = minf(min_y, lumi.global_position.y)
		if lumi.is_on_floor() and lumi.global_position.z < -30.0:
			break
	check(saw_glide, "Gleitphase wurde aktiv")
	check(lumi.global_position.z < -33.0 and lumi.global_position.y > -1.0, "Lumi landet jenseits der Lücke", str(lumi.global_position))
	check(lumi.respawns == 0, "kein Absturz")
	lumi.input.clear()

	print("== 6. Kiri: Schatten-Dash durch Tor, Lumi wird blockiert")
	reset(kiri, Vector3(9, 0.1, -25))
	await secs(0.3)
	kiri.input.move = Vector2(0, -1)
	await secs(0.35)
	kiri.input.press("special")
	await secs(0.12)
	check(kiri.is_cloud, "Kiri ist Schattenwolke")
	await secs(1.2)
	check(kiri.global_position.z < -31.0, "Kiri ist durch das Schattentor", str(kiri.global_position))
	check(not kiri.is_cloud and kiri.collision_mask & 8 != 0, "Tor-Kollision danach wieder aktiv")
	kiri.input.clear()
	reset(lumi, Vector3(9, 0.1, -26))
	await secs(0.3)
	lumi.input.move = Vector2(0, -1)
	lumi.input.sprint = true
	await secs(1.5)
	check(lumi.global_position.z > -29.8, "Lumi läuft gegen das Schattentor", str(lumi.global_position))
	lumi.input.clear()

	print("== 7. Kampf: 3er-Kombo mit Finisher")
	var enemy: CharacterBody3D = main.level.enemies[1]
	enemy.global_position = Vector3(0, 0.1, -50)
	enemy.hp = 4
	enemy.velocity = Vector3.ZERO
	reset(lumi, Vector3(0, 0.1, -48))
	await secs(0.5)
	var hits: Array[int] = []
	for step in 3:
		lumi.input.press("attack")
		await secs(0.5)
		hits.append(enemy.hp if is_instance_valid(enemy) else 0)
	print("     Gegner-HP nach Schlägen: ", hits)
	check(hits[0] == 3, "Schlag 1 trifft (1 Schaden)")
	check(hits[1] <= 2, "Schlag 2 trifft")
	check(hits[2] <= 0, "Finisher beendet den Gegner")
	await secs(0.5)
	check(not is_instance_valid(enemy) or enemy._dying, "Gegner besiegt")

	print("== 8. Schaden, Tod und Checkpoint-Respawn")
	var cp: Area3D = main.level.checkpoints[0]
	reset(kiri, Vector3(0, 0.1, -51))
	await secs(0.3)
	check(cp.active, "Checkpoint aktiviert")
	check(lumi.spawn_position.z < -48, "Respawn-Punkt wurde verschoben", str(lumi.spawn_position))
	kiri.take_damage(1, Vector3(0, 0, -45))
	check(kiri.hp == 4 and kiri.state == kiri.State.HURT, "Treffer kostet 1 HP")
	kiri.take_damage(1, Vector3(0, 0, -45))
	check(kiri.hp == 4, "Unverwundbarkeit nach Treffer")
	kiri.invuln = 0.0
	kiri.take_damage(10, Vector3(0, 0, -45))
	check(kiri.state == kiri.State.DEAD, "Kiri stirbt bei 0 HP")
	check(lumi.state != lumi.State.DEAD, "Lumi ist davon unberührt")
	await secs(1.3)
	check(kiri.state == kiri.State.NORMAL and kiri.hp == kiri.MAX_HP, "Kiri respawnt mit vollen HP")
	check(kiri.global_position.z < -48, "Respawn am Checkpoint", str(kiri.global_position))
	var r: int = lumi.respawns
	lumi.global_position = Vector3(0, -30, 0)
	await secs(0.5)
	check(lumi.respawns == r + 1 and lumi.global_position.y > -1.0, "Sturz ins Leere -> Respawn", str(lumi.global_position))
	check(lumi.hp == lumi.MAX_HP, "Sturz kostet keine HP")

	print("== 9. Pause")
	main.set_paused(true)
	var z0 := lumi.global_position
	lumi.input.move = Vector2(0, -1)
	await secs(0.5)
	check(lumi.global_position.distance_to(z0) < 0.05, "Figuren stehen in der Pause")
	main.set_paused(false)
	await secs(0.5)
	check(lumi.global_position.distance_to(z0) > 0.5, "Weiterspielen nach Pause")
	lumi.input.clear()

	print("")
	print("ERGEBNIS: %d/%d Prüfungen bestanden" % [checks - failures, checks])
	quit(1 if failures > 0 else 0)
