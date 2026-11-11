extends SceneTree
## Screenshot des Splitscreens (braucht ein echtes, ggf. virtuelles Display, z. B. xvfb).
## xvfb-run -a godot --path . --rendering-driver opengl3 --rendering-method gl_compatibility \
##   --resolution 1280x720 --script res://tests/screenshot.gd -- out.png "lx,ly,lz,lyaw" "kx,ky,kz,kyaw"
## (Yaw in Grad: 0 = Blick nach -Z, -90 = nach +X, 90 = nach -X)

func _initialize() -> void:
	call_deferred("_run")


func _parse(s: String) -> Array:
	var v := s.split(",")
	return [Vector3(float(v[0]), float(v[1]), float(v[2])), deg_to_rad(float(v[3]))]


func _run() -> void:
	var a := OS.get_cmdline_user_args()
	var out: String = a[0] if a.size() > 0 else "/tmp/shot.png"
	var main: Control = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	for i in 10:
		await process_frame
	for p in main.players:
		p.input.scripted = true
	for i in 2:
		if a.size() > 1 + i:
			var d := _parse(a[1 + i])
			main.players[i].global_position = d[0]
			main.players[i].velocity = Vector3.ZERO
			main.rigs[i].yaw = d[1]
			main.players[i].face_dir = Vector3(-sin(d[1]), 0, -cos(d[1]))
			main.rigs[i].snap_to_target()
			main.moods[i] = main.level.mood_at(d[0])
	for i in 14:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png(out)
	print("gespeichert: ", out)
	quit()
