
extends Node3D

@export var camera_path: NodePath = NodePath("../Camera3D")

@export var minimum_fov: float = 20.0
@export var maximum_fov: float = 75.0
@export var zoom_step: float = 5.0

@export var focus_distance: float = 20.0
@export var minimum_focus_distance: float = 0.5
@export var maximum_focus_distance: float = 200.0

@onready var camera: Camera3D = get_node(camera_path)

var current_fov: float = 55.0
var is_camera_active: bool = true


func _ready() -> void:
    current_fov = clampf(current_fov, minimum_fov, maximum_fov)
    camera.fov = current_fov
    _apply_camera_focus()


func zoom_in() -> void:
    current_fov = clampf(
        current_fov - zoom_step,
        minimum_fov,
        maximum_fov
    )

    camera.fov = current_fov


func zoom_out() -> void:
    current_fov = clampf(
        current_fov + zoom_step,
        minimum_fov,
        maximum_fov
    )

    camera.fov = current_fov


func set_zoom(value: float) -> void:
    current_fov = clampf(value, minimum_fov, maximum_fov)
    camera.fov = current_fov


func get_current_zoom() -> float:
    return current_fov


func focus_forward() -> void:
    var viewport := get_viewport()
    var center := viewport.get_visible_rect().size * 0.5

    var ray_origin := camera.project_ray_origin(center)
    var ray_direction := camera.project_ray_normal(center)

    var ray_end := ray_origin + ray_direction * maximum_focus_distance

    var query := PhysicsRayQueryParameters3D.create(
        ray_origin,
        ray_end
    )

    query.collide_with_areas = true

    var result := get_world_3d().direct_space_state.intersect_ray(query)

    if not result.is_empty():
        focus_distance = ray_origin.distance_to(result.position)
    else:
        focus_distance = maximum_focus_distance

    set_focus_distance(focus_distance)


func set_focus_distance(value: float) -> void:
    focus_distance = clampf(
        value,
        minimum_focus_distance,
        maximum_focus_distance
    )

    _apply_camera_focus()


func get_focus_distance() -> float:
    return focus_distance


func _apply_camera_focus() -> void:
    if not is_instance_valid(camera):
        return

    if camera.has_method("set_focus_distance"):
        camera.call("set_focus_distance", focus_distance)
