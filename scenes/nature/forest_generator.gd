
extends Node3D

@export var tree_count: int = 180
@export var forest_size: float = 100.0
@export var minimum_tree_height: float = 5.0
@export var maximum_tree_height: float = 10.0
@export var random_seed: int = 12345

var random_generator := RandomNumberGenerator.new()


func _ready() -> void:
    generate_forest()


func generate_forest() -> void:
    random_generator.seed = random_seed

    var trunk_mesh := CylinderMesh.new()
    trunk_mesh.top_radius = 0.16
    trunk_mesh.bottom_radius = 0.28
    trunk_mesh.height = 2.0
    trunk_mesh.radial_segments = 8

    var leaf_mesh := SphereMesh.new()
    leaf_mesh.radius = 1.0
    leaf_mesh.height = 2.0
    leaf_mesh.radial_segments = 8
    leaf_mesh.rings = 4

    var trunk_material := StandardMaterial3D.new()
    trunk_material.albedo_color = Color(0.24, 0.13, 0.07)
    trunk_material.roughness = 1.0

    var leaf_material := StandardMaterial3D.new()
    leaf_material.albedo_color = Color(0.12, 0.28, 0.10)
    leaf_material.roughness = 1.0

    trunk_mesh.material = trunk_material
    leaf_mesh.material = leaf_material

    var trunks := MultiMesh.new()
    trunks.transform_format = MultiMesh.TRANSFORM_3D
    trunks.mesh = trunk_mesh
    trunks.instance_count = tree_count

    var leaves := MultiMesh.new()
    leaves.transform_format = MultiMesh.TRANSFORM_3D
    leaves.mesh = leaf_mesh
    leaves.instance_count = tree_count

    for i in range(tree_count):
        var x := random_generator.randf_range(
            -forest_size * 0.5,
            forest_size * 0.5
        )

        var z := random_generator.randf_range(
            -forest_size * 0.5,
            forest_size * 0.5
        )

        var tree_height := random_generator.randf_range(
            minimum_tree_height,
            maximum_tree_height
        )

        var tree_width := tree_height * random_generator.randf_range(
            0.18,
            0.28
        )

        var trunk_transform := Transform3D(
            Basis.from_scale(
                Vector3(1.0, tree_height * 0.5, 1.0)
            ),
            Vector3(x, tree_height * 0.5, z)
        )

        trunks.set_instance_transform(i, trunk_transform)

        var leaf_transform := Transform3D(
            Basis.from_scale(
                Vector3(tree_width, tree_height * 0.22, tree_width)
            ),
            Vector3(x, tree_height * 0.85, z)
        )

        leaves.set_instance_transform(i, leaf_transform)

    var trunk_instance := MultiMeshInstance3D.new()
    trunk_instance.multimesh = trunks
    add_child(trunk_instance)

    var leaf_instance := MultiMeshInstance3D.new()
    leaf_instance.multimesh = leaves
    add_child(leaf_instance)
