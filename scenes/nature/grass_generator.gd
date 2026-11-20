
extends Node3D

@export var grass_count: int = 1800
@export var grass_area: float = 100.0
@export var minimum_height: float = 0.25
@export var maximum_height: float = 0.75
@export var random_seed: int = 54321

var random_generator := RandomNumberGenerator.new()


func _ready() -> void:
    generate_grass()


func generate_grass() -> void:
    random_generator.seed = random_seed

    var grass_mesh := CylinderMesh.new()
    grass_mesh.top_radius = 0.005
    grass_mesh.bottom_radius = 0.025
    grass_mesh.height = 1.0
    grass_mesh.radial_segments = 4
    grass_mesh.rings = 1

    var grass_material := StandardMaterial3D.new()
    grass_material.vertex_color_use_as_albedo = true
    grass_material.roughness = 1.0

    grass_mesh.material = grass_material

    var grass_multimesh := MultiMesh.new()
    grass_multimesh.transform_format = MultiMesh.TRANSFORM_3D
    grass_multimesh.use_colors = true
    grass_multimesh.mesh = grass_mesh
    grass_multimesh.instance_count = grass_count

    for i in range(grass_count):
        var x := random_generator.randf_range(
            -grass_area * 0.5,
            grass_area * 0.5
        )

        var z := random_generator.randf_range(
            -grass_area * 0.5,
            grass_area * 0.5
        )

        var height := random_generator.randf_range(
            minimum_height,
            maximum_height
        )

        var width := random_generator.randf_range(
            0.7,
            1.3
        )

        var rotation := random_generator.randf_range(
            0.0,
            TAU
        )

        var transform := Transform3D(
            Basis.from_scale(
                Vector3(width, height, width)
            ).rotated(Vector3.UP, rotation),
            Vector3(x, height * 0.5, z)
        )

        grass_multimesh.set_instance_transform(i, transform)

        var green_value := random_generator.randf_range(
            0.65,
            1.0
        )

        var grass_color := Color(
            0.12 * green_value,
            0.38 * green_value,
            0.08 * green_value,
            1.0
        )

        grass_multimesh.set_instance_color(i, grass_color)

    var grass_instance := MultiMeshInstance3D.new()
    grass_instance.multimesh = grass_multimesh
    grass_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

    add_child(grass_instance)
