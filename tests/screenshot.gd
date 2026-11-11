extends SceneTree
## Erzeugt einen Screenshot des Splitscreens (braucht ein echtes, ggf. virtuelles Display).
## Start: xvfb-run -a godot --path . --rendering-method gl_compatibility --script res://tests/screenshot.gd -- <ausgabe.png>

func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var out := "/tmp/shot.png"
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		out = args[0]
	var main: Control = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	for i in 20:
		await process_frame
	for p in main.players:
		p.input.scripted = true
	main.players[0].global_position = Vector3(-9, 0.2, -14)
	main.players[1].global_position = Vector3(9, 0.2, -16)
	main.players[0].input.move = Vector2(0, -0.01)
	main.rigs[0].yaw = 0.35
	main.rigs[0].snap_to_target()
	main.rigs[1].snap_to_target()
	for i in 25:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png(out)
	print("gespeichert: ", out)
	quit()
