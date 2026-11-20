
extends Camera3D

@export var focus_distance: float = 20.0
@export var focus_transition_speed: float = 3.0
@export var blur_amount: float = 0.15
@export var minimum_focus_distance: float = 0.5
@export var maximum_focus_distance: float = 200.0

var camera_attributes: CameraAttributesPractical
var autofocus_enabled: bool = true
var focus_target: Vector3 = Vector3.ZERO


func _ready() -> void:
    _setup_camera_effects()


func _setup_camera_effects() -> void:
    camera_attributes = CameraAttributesPractical.new()

    camera_attributes.dof_blur_far_enabled = true
    camera_attributes.dof_blur_far_distance = focus_distance
    camera_attributes.dof_blur_far_transition = 10.0
    camera_attributes.dof_blur_near_enabled = false
    camera_attributes.dof_blur_amount = blur_amount

    attributes = camera_attributes


func _process(delta: float) -> void:
    if camera_attributes == null:
        return

    camera_attributes.dof_blur_far_distance = lerpf(
        camera_attributes.dof_blur_far_distance,
        focus_distance,
        focus_transition_speed * delta
    )


func autofocus() -> bool:
    if not autofocus_enabled:
        return false

    var viewport := get_viewport()
    var center := viewport.get_visible_rect().size * 0.5

    var ray_origin := project_ray_origin(center)
    var ray_direction := project_ray_normal(center)
    var ray_end := ray_origin + ray_direction * maximum_focus_distance

    var query := PhysicsRayQueryParameters3D.create(
        ray_origin,
        ray_end
    )

    query.collide_with_areas = true

    var result := get_world_3d().direct_space_state.intersect_ray(query)

    if result.is_empty():
        return false

    focus_target = result.position

    set_focus_distance(
        ray_origin.distance_to(focus_target)
    )

    return true


func set_focus_distance(value: float) -> void:
    focus_distance = clampf(
        value,
        minimum_focus_distance,
        maximum_focus_distance
    )


func get_focus_distance() -> float:
    return focus_distance


func set_blur_amount(value: float) -> void:
    blur_amount = clampf(value, 0.0, 1.0)

    if camera_attributes != null:
        camera_attributes.dof_blur_amount = blur_amount


func set_depth_of_field(enabled: bool) -> void:
    if camera_attributes != null:
        camera_attributes.dof_blur_far_enabled = enabled


func set_autofocus(enabled: bool) -> void:
    autofocus_enabled = enabled


func is_autofocus_enabled() -> bool:
    return autofocus_enabled
