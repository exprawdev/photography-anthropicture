
extends Node3D

@export var lake_width: float = 36.0
@export var lake_length: float = 24.0
@export var water_color: Color = Color(0.08, 0.32, 0.38, 1.0)

@export var lake_position: Vector3 = Vector3(0.0, 0.015, -25.0)


func _ready() -> void:
    generate_lake()


func generate_lake() -> void:
    var water_mesh := PlaneMesh.new()
    water_mesh.size = Vector2(lake_width, lake_length)

    var water_material := StandardMaterial3D.new()
    water_material.albedo_color = water_color
    water_material.metallic = 0.25
    water_material.roughness = 0.16
    water_material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
    water_material.cull_mode = BaseMaterial3D.CULL_DISABLED

    water_mesh.material = water_material

    var water_surface := MeshInstance3D.new()
    water_surface.name = "LakeWater"
    water_surface.mesh = water_mesh
    water_surface.position = lake_position
    water_surface.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

    add_child(water_surface)


func set_water_color(color: Color) -> void:
    water_color = color

    var water_surface := get_node_or_null("LakeWater") as MeshInstance3D

    if water_surface != null:
        var material := water_surface.mesh.surface_get_material(0) as StandardMaterial3D

        if material != null:
            material.albedo_color = color
