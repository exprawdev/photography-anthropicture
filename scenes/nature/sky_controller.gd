
extends WorldEnvironment

@export var sky_top_color: Color = Color(0.12, 0.32, 0.55)
@export var sky_horizon_color: Color = Color(0.65, 0.78, 0.82)

@export var sky_energy: float = 0.8
@export var ambient_energy: float = 0.8

@export var fog_density: float = 0.003
@export var fog_color: Color = Color(0.68, 0.76, 0.78, 1.0)

@export var glow_intensity: float = 0.3


func _ready() -> void:
    setup_sky()


func setup_sky() -> void:
    if environment == null:
        environment = Environment.new()

    var sky_material := ProceduralSkyMaterial.new()
    sky_material.sky_top_color = sky_top_color
    sky_material.sky_horizon_color = sky_horizon_color
    sky_material.ground_bottom_color = Color(0.12, 0.16, 0.12)
    sky_material.ground_horizon_color = sky_horizon_color
    sky_material.sun_angle_max = 30.0
    sky_material.use_debanding = true

    var sky_resource := Sky.new()
    sky_resource.sky_material = sky_material
    sky_resource.radiance_size = Sky.RADIANCE_SIZE_256

    environment.background_mode = Environment.BG_SKY
    environment.sky = sky_resource
    environment.background_energy_multiplier = sky_energy

    environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
    environment.ambient_light_energy = ambient_energy

    environment.fog_enabled = true
    environment.fog_light_color = fog_color
    environment.fog_density = fog_density
    environment.fog_sky_affect = 0.3

    environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC

    environment.glow_enabled = true
    environment.glow_intensity = glow_intensity
    environment.glow_bloom = 0.08
    environment.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT


func set_sky_colors(top_color: Color, horizon_color: Color) -> void:
    sky_top_color = top_color
    sky_horizon_color = horizon_color
    setup_sky()


func set_fog_density(value: float) -> void:
    fog_density = maxf(value, 0.0)

    if environment != null:
        environment.fog_density = fog_density
