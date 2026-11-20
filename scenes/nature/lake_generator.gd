
extends Node3D

@export var lake_width: float = 36.0
@export var lake_length: float = 24.0
@export var water_color: Color = Color(0.08, 0.32, 0.38, 1.0)
@export var wave_speed: float = 0.8
@export var wave_strength: float = 0.035

@export var lake_position: Vector3 = Vector3(0.0, 0.015, -25.0)

var water_material: ShaderMaterial


func _ready() -> void:
    generate_lake()


func generate_lake() -> void:
    var water_mesh := PlaneMesh.new()
    water_mesh.size = Vector2(lake_width, lake_length)
    water_mesh.subdivide_width = 100
    water_mesh.subdivide_depth = 100

    var water_shader := Shader.new()
    water_shader.code = """
shader_type spatial;

uniform vec4 water_color : source_color = vec4(0.08, 0.32, 0.38, 1.0);
uniform float wave_speed = 0.8;
uniform float wave_strength = 0.035;

void vertex() {
    float wave_a = sin(VERTEX.x * 1.8 + TIME * wave_speed);
    float wave_b = cos(VERTEX.z * 1.4 + TIME * wave_speed * 0.7);

    VERTEX.y += (wave_a + wave_b) * wave_strength;
}

void fragment() {
    float depth_pattern = sin(UV.x * 18.0 + TIME * 0.25) * 0.025;
    ALBEDO = water_color.rgb + depth_pattern;
    METALLIC = 0.2;
    ROUGHNESS = 0.18;
}
"""

    water_material = ShaderMaterial.new()
    water_material.shader = water_shader
    water_material.set_shader_parameter("water_color", water_color)
    water_material.set_shader_parameter("wave_speed", wave_speed)
    water_material.set_shader_parameter("wave_strength", wave_strength)

    water_mesh.material = water_material

    var water_surface := MeshInstance3D.new()
    water_surface.name = "LakeWater"
    water_surface.mesh = water_mesh
    water_surface.position = lake_position
    water_surface.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

    add_child(water_surface)


func set_water_color(color: Color) -> void:
    water_color = color

    if water_material != null:
        water_material.set_shader_parameter("water_color", color)


func set_wave_speed(value: float) -> void:
    wave_speed = maxf(value, 0.0)

    if water_material != null:
        water_material.set_shader_parameter("wave_speed", wave_speed)


func set_wave_strength(value: float) -> void:
    wave_strength = maxf(value, 0.0)

    if water_material != null:
        water_material.set_shader_parameter("wave_strength", wave_strength)
