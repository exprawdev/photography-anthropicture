
extends Node3D

@export var move_speed: float = 5.0
@export var touch_sensitivity: float = 0.004

@onready var camera: Camera3D = $Camera3D

var camera_pitch: float = 0.0
var move_input: Vector2 = Vector2.ZERO


func _ready() -> void:
    camera.current = true


func _physics_process(delta: float) -> void:
    _update_movement(delta)


func set_mobile_move_input(input: Vector2) -> void:
    move_input = input.limit_length(1.0)


func rotate_from_touch(relative_motion: Vector2) -> void:
    rotation.y -= relative_motion.x * touch_sensitivity

    camera_pitch -= relative_motion.y * touch_sensitivity
    camera_pitch = clamp(
        camera_pitch,
        deg_to_rad(-85.0),
        deg_to_rad(85.0)
    )

    camera.rotation.x = camera_pitch


func _update_movement(delta: float) -> void:
    var local_direction := Vector3(
        move_input.x,
        0.0,
        move_input.y
    )

    var world_direction := global_transform.basis * local_direction

    world_direction.y = 0.0
    world_direction = world_direction.normalized()

    global_position += world_direction * move_speed * delta
