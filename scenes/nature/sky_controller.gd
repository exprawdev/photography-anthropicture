
extends WorldEnvironment

@export var sky_top_color: Color = Color(0.12, 0.32, 0.55)
@export var sky_horizon_color: Color = Color(0.65, 0.78, 0.82)
@export var sun_energy: float = 1.1
@export var sky_energy: float = 0.8


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
    environment.ambient_light_energy = 0.8

    environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC


func set_sky_colors(top_color: Color, horizon_color: Color) -> void:
    sky_top_color = top_color
    sky_horizon_color = horizon_color
    setup_sky()
