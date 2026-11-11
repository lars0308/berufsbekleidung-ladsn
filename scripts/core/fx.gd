extends RefCounted
## Kleine Partikel-Effekte (Treffer, Landung).


static func burst(parent: Node, pos: Vector3, color: Color, amount := 10, speed := 3.0) -> void:
	var p := CPUParticles3D.new()
	p.emitting = false
	p.one_shot = true
	p.amount = amount
	p.lifetime = 0.45
	p.explosiveness = 1.0
	p.direction = Vector3.UP
	p.spread = 75.0
	p.initial_velocity_min = speed * 0.6
	p.initial_velocity_max = speed
	p.gravity = Vector3(0, -6, 0)
	p.scale_amount_min = 0.6
	p.scale_amount_max = 1.0
	var m := SphereMesh.new()
	m.radius = 0.07
	m.height = 0.14
	m.radial_segments = 6
	m.rings = 3
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.material = mat
	p.mesh = m
	parent.add_child(p)
	p.global_position = pos
	p.emitting = true
	parent.get_tree().create_timer(1.0, false).timeout.connect(p.queue_free)
