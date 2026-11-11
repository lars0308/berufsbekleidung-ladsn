extends RefCounted
## Licht- und Himmelsstimmung. Jede Kamera hat ihre eigene Environment-Kopie, die je nach
## Aufenthaltsort zwischen "sonnig" (0) und "Schatten" (1) überblendet wird.

const SUNNY := {
	"top": Color("4fa8ff"), "horizon": Color("ffe3a8"), "ground": Color("7bbf6a"),
	"ambient": 0.62, "ambient_color": Color("ffffff"), "fog": Color("ffe9c4"), "fog_density": 0.0022, "glow": 0.3,
}
const SHADOW := {
	"top": Color("1b1646"), "horizon": Color("7a46b5"), "ground": Color("150f30"),
	"ambient": 0.8, "ambient_color": Color("a98bff"), "fog": Color("5b3a98"), "fog_density": 0.009, "glow": 0.9,
}


static func make_environment() -> Environment:
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sun_angle_max = 25.0
	var sky := Sky.new()
	sky.sky_material = sky_mat
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = true
	env.glow_bloom = 0.1
	env.fog_enabled = true
	apply_mood(env, 0.5)
	return env


## t = 0 sonnig, 1 Schatten.
static func apply_mood(env: Environment, t: float) -> void:
	var m: ProceduralSkyMaterial = env.sky.sky_material
	m.sky_top_color = SUNNY["top"].lerp(SHADOW["top"], t)
	m.sky_horizon_color = SUNNY["horizon"].lerp(SHADOW["horizon"], t)
	m.ground_horizon_color = m.sky_horizon_color
	m.ground_bottom_color = SUNNY["ground"].lerp(SHADOW["ground"], t)
	env.ambient_light_energy = lerpf(SUNNY["ambient"], SHADOW["ambient"], t)
	env.ambient_light_color = SUNNY["ambient_color"].lerp(SHADOW["ambient_color"], t)
	env.fog_light_color = SUNNY["fog"].lerp(SHADOW["fog"], t)
	env.fog_density = lerpf(SUNNY["fog_density"], SHADOW["fog_density"], t)
	env.glow_intensity = lerpf(SUNNY["glow"], SHADOW["glow"], t)


static func make_sun() -> DirectionalLight3D:
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -35, 0)
	sun.light_color = Color("fff0d6")
	sun.light_energy = 0.85
	sun.shadow_enabled = true
	sun.shadow_bias = 0.05
	sun.shadow_normal_bias = 1.5
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	sun.directional_shadow_max_distance = 70.0
	return sun
