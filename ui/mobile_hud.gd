
extends Control

@export var joystick_radius: float = 85.0
@export var joystick_deadzone: float = 0.12

var player: Node3D

var left_touch_index: int = -1
var right_touch_index: int = -1

var joystick_origin: Vector2 = Vector2.ZERO
var joystick_position: Vector2 = Vector2.ZERO

var joystick_active: bool = false


func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    queue_redraw()


func _draw() -> void:
    var screen_size := get_viewport_rect().size

    var base_position := Vector2(
        screen_size.x * 0.17,
        screen_size.y * 0.78
    )

    var base_radius := joystick_radius

    draw_circle(
        base_position,
        base_radius,
        Color(0.1, 0.15, 0.18, 0.25)
    )

    draw_arc(
        base_position,
        base_radius,
        0.0,
        TAU,
        48,
        Color(0.85, 0.9, 0.92, 0.65),
        3.0
    )

    var knob_position := base_position

    if joystick_active:
        knob_position = joystick_position

    draw_circle(
        knob_position,
        base_radius * 0.42,
        Color(0.55, 0.72, 0.78, 0.55)
    )

    draw_arc(
        knob_position,
        base_radius * 0.42,
        0.0,
        TAU,
        32,
        Color(0.9, 0.95, 1.0, 0.8),
        2.0
    )


func set_player_reference(target: Node3D) -> void:
    player = target


func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        _handle_touch(event)

    elif event is InputEventScreenDrag:
        _handle_drag(event)


func _handle_touch(event: InputEventScreenTouch) -> void:
    var screen_width := get_viewport_rect().size.x

    if event.pressed:
        if event.position.x < screen_width * 0.5:
            if left_touch_index == -1:
                left_touch_index = event.index
                joystick_active = true
                joystick_origin = _get_joystick_center()
                joystick_position = joystick_origin
                _update_player_movement()
        else:
            if right_touch_index == -1:
                right_touch_index = event.index

    else:
        if event.index == left_touch_index:
            left_touch_index = -1
            joystick_active = false
            joystick_position = _get_joystick_center()
            _update_player_movement()

        if event.index == right_touch_index:
            right_touch_index = -1

    queue_redraw()


func _handle_drag(event: InputEventScreenDrag) -> void:
    if event.index == left_touch_index:
        var offset := event.position - joystick_origin
        offset = offset.limit_length(joystick_radius)

        joystick_position = joystick_origin + offset
        _update_player_movement()
        queue_redraw()

    elif event.index == right_touch_index:
        if is_instance_valid(player):
            player.call("rotate_from_touch", event.relative)


func _get_joystick_center() -> Vector2:
    var screen_size := get_viewport_rect().size

    return Vector2(
        screen_size.x * 0.17,
        screen_size.y * 0.78
    )


func _update_player_movement() -> void:
    if not is_instance_valid(player):
        return

    var offset := joystick_position - joystick_origin
    var movement := offset / joystick_radius

    movement = movement.limit_length(1.0)

    if movement.length() < joystick_deadzone:
        movement = Vector2.ZERO

    player.call("set_mobile_move_input", movement)
