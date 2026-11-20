
extends WorldEnvironment

@export var fog_density: float = 0.003
@export var fog_color: Color = Color(0.68, 0.76, 0.78, 1.0)
@export var ambient_energy: float = 0.8
@export var glow_intensity: float = 0.3


func _ready() -> void:
    _setup_atmosphere()


func _setup_atmosphere() -> void:
    if environment == null:
        environment = Environment.new()

    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color(0.38, 0.48, 0.52, 1.0)

    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color(0.72, 0.78, 0.82, 1.0)
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
