extends RefCounted
## Gemeinsame Licht- und Himmelsstimmung (violett-türkiser Dschungelabend).


static func make_environment() -> Environment:
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("3a2d7a")
	sky_mat.sky_horizon_color = Color("ff9ec4")
	sky_mat.ground_horizon_color = Color("ff9ec4")
	sky_mat.ground_bottom_color = Color("2a1f55")
	sky_mat.sun_angle_max = 25.0
	var sky := Sky.new()
	sky.sky_material = sky_mat
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.55
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = true
	env.glow_intensity = 0.7
	env.glow_bloom = 0.1
	env.fog_enabled = true
	env.fog_light_color = Color("b79bff")
	env.fog_density = 0.004
	return env


static func make_sun() -> DirectionalLight3D:
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -35, 0)
	sun.light_color = Color("fff0d6")
	sun.light_energy = 1.0
	sun.shadow_enabled = true
	sun.shadow_bias = 0.05
	sun.shadow_normal_bias = 1.5
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	sun.directional_shadow_max_distance = 70.0
	return sun
