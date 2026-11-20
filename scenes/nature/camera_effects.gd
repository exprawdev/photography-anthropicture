
extends Camera3D

@export var focus_distance: float = 20.0
@export var focus_transition_speed: float = 3.0
@export var blur_amount: float = 0.15

var camera_attributes: CameraAttributesPractical


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


func set_focus_distance(value: float) -> void:
    focus_distance = clampf(value, 0.5, 200.0)


func set_blur_amount(value: float) -> void:
    blur_amount = clampf(value, 0.0, 1.0)

    if camera_attributes != null:
        camera_attributes.dof_blur_amount = blur_amount


func set_depth_of_field(enabled: bool) -> void:
    if camera_attributes != null:
        camera_attributes.dof_blur_far_enabled = enabled
