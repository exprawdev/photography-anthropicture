
extends Node3D

@export var rock_count: int = 250
@export var area_size: float = 100.0
@export var minimum_scale: float = 0.3
@export var maximum_scale: float = 1.8
@export var random_seed: int = 98765

var random_generator := RandomNumberGenerator.new()


func _ready() -> void:
    generate_rocks()


func generate_rocks() -> void:
    random_generator.seed = random_seed

    var rock_mesh := SphereMesh.new()
    rock_mesh.radius = 1.0
    rock_mesh.height = 2.0
    rock_mesh.radial_segments = 8
    rock_mesh.rings = 6

    var rock_material := StandardMaterial3D.new()
    rock_material.albedo_color = Color(0.34, 0.35, 0.32)
    rock_material.roughness = 1.0
    rock_mesh.material = rock_material

    var rock_multimesh := MultiMesh.new()
    rock_multimesh.transform_format = MultiMesh.TRANSFORM_3D
    rock_multimesh.instance_count = rock_count
    rock_multimesh.mesh = rock_mesh

    for i in range(rock_count):
        var x := random_generator.randf_range(
            -area_size * 0.5,
            area_size * 0.5
        )

        var z := random_generator.randf_range(
            -area_size * 0.5,
            area_size * 0.5
        )

        var rock_scale := random_generator.randf_range(
            minimum_scale,
            maximum_scale
        )

        var scale_vector := Vector3(
            rock_scale * random_generator.randf_range(0.8, 1.3),
            rock_scale * random_generator.randf_range(0.5, 0.9),
            rock_scale * random_generator.randf_range(0.8, 1.3)
        )

        var rock_rotation := Vector3(
            random_generator.randf_range(-0.3, 0.3),
            random_generator.randf_range(0.0, TAU),
            random_generator.randf_range(-0.3, 0.3)
        )

        var rock_transform := Transform3D(
            Basis.from_euler(rock_rotation).scaled(scale_vector),
            Vector3(x, scale_vector.y, z)
        )

        rock_multimesh.set_instance_transform(
            i,
            rock_transform
        )

    var rock_instance := MultiMeshInstance3D.new()
    rock_instance.multimesh = rock_multimesh
    rock_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

    add_child(rock_instance)
