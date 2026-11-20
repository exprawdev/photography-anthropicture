
extends Node3D

@export var move_speed: float = 5.0
@export var mouse_sensitivity: float = 0.002
@export var touch_sensitivity: float = 0.004
@export var joystick_radius: float = 100.0

@onready var camera: Camera3D = $Camera3D

var camera_pitch: float = 0.0
var move_input: Vector2 = Vector2.ZERO

var left_touch_index: int = -1
var right_touch_index: int = -1

var joystick_origin: Vector2 = Vector2.ZERO
var joystick_position: Vector2 = Vector2.ZERO


func _ready() -> void:
    camera.current = true
    _setup_input_actions()

    if OS.get_name() != "Android" and OS.get_name() != "iOS":
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(delta: float) -> void:
    _update_movement(delta)


func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
            _rotate_camera(event.relative, mouse_sensitivity)

    elif event is InputEventMouseButton:
        if event.pressed and OS.get_name() != "Android":
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

    elif event is InputEventKey:
        if event.pressed and event.keycode == KEY_ESCAPE:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

    elif event is InputEventScreenTouch:
        _handle_screen_touch(event)

    elif event is InputEventScreenDrag:
        _handle_screen_drag(event)


func _update_movement(delta: float) -> void:
    var keyboard_input := Input.get_vector(
        "move_left",
        "move_right",
        "move_forward",
        "move_back"
    )

    var direction_input := keyboard_input

    if left_touch_index != -1:
        var touch_offset := joystick_position - joystick_origin
        var touch_input := touch_offset / joystick_radius
        touch_input = touch_input.limit_length(1.0)

        if touch_input.length() > 0.15:
            direction_input = touch_input

    var local_direction := Vector3(
        direction_input.x,
        0.0,
        direction_input.y
    )

    var world_direction := global_transform.basis * local_direction
    world_direction.y = 0.0
    world_direction = world_direction.normalized()

    global_position += world_direction * move_speed * delta


func _rotate_camera(relative_motion: Vector2, sensitivity: float) -> void:
    rotation.y -= relative_motion.x * sensitivity

    camera_pitch -= relative_motion.y * sensitivity
    camera_pitch = clamp(
        camera_pitch,
        deg_to_rad(-85.0),
        deg_to_rad(85.0)
    )

    camera.rotation.x = camera_pitch


func _handle_screen_touch(event: InputEventScreenTouch) -> void:
    if event.pressed:
        if event.position.x < get_viewport().get_visible_rect().size.x * 0.5:
            if left_touch_index == -1:
                left_touch_index = event.index
                joystick_origin = event.position
                joystick_position = event.position
        else:
            if right_touch_index == -1:
                right_touch_index = event.index
    else:
        if event.index == left_touch_index:
            left_touch_index = -1
            move_input = Vector2.ZERO

        if event.index == right_touch_index:
            right_touch_index = -1


func _handle_screen_drag(event: InputEventScreenDrag) -> void:
    if event.index == left_touch_index:
        joystick_position = event.position

    elif event.index == right_touch_index:
        _rotate_camera(event.relative, touch_sensitivity)


func _setup_input_actions() -> void:
    _add_key_action("move_forward", KEY_W)
    _add_key_action("move_back", KEY_S)
    _add_key_action("move_left", KEY_A)
    _add_key_action("move_right", KEY_D)


func _add_key_action(action_name: String, key_code: Key) -> void:
    if not InputMap.has_action(action_name):
        InputMap.add_action(action_name)

    var key_event := InputEventKey.new()
    key_event.physical_keycode = key_code

    var events := InputMap.action_get_events(action_name)

    for existing_event in events:
        if existing_event is InputEventKey:
            if existing_event.physical_keycode == key_code:
                return

    InputMap.action_add_event(action_name, key_event)
