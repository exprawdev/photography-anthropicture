
extends Control

@export var joystick_radius: float = 85.0
@export var joystick_deadzone: float = 0.12
@export var player_path: NodePath = NodePath("../../Player")
@export var camera_system_path: NodePath = NodePath("../../Player/CameraSystem")

var player: Node3D
var camera_system: Node3D

var left_touch_index: int = -1
var right_touch_index: int = -1

var joystick_position: Vector2 = Vector2.ZERO
var joystick_active: bool = false

var zoom_in_rect := Rect2()
var zoom_out_rect := Rect2()
var focus_rect := Rect2()
var shutter_rect := Rect2()


func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_IGNORE

    player = get_node_or_null(player_path) as Node3D
    camera_system = get_node_or_null(camera_system_path) as Node3D

    _update_button_positions()
    queue_redraw()


func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        _update_button_positions()
        queue_redraw()


func _update_button_positions() -> void:
    var screen_size := get_viewport_rect().size

    zoom_in_rect = Rect2(
        screen_size.x - 150,
        screen_size.y * 0.40,
        65,
        65
    )

    zoom_out_rect = Rect2(
        screen_size.x - 150,
        screen_size.y * 0.53,
        65,
        65
    )

    focus_rect = Rect2(
        screen_size.x - 150,
        screen_size.y * 0.67,
        65,
        65
    )

    shutter_rect = Rect2(
        screen_size.x - 115,
        screen_size.y * 0.82,
        90,
        90
    )


func _draw() -> void:
    var center := _get_joystick_center()
    var knob := center

    if joystick_active:
        knob = joystick_position

    draw_circle(center, joystick_radius, Color(0.1, 0.15, 0.18, 0.25))
    draw_arc(center, joystick_radius, 0.0, TAU, 48, Color(0.85, 0.9, 0.92, 0.65), 3.0)

    draw_circle(knob, joystick_radius * 0.42, Color(0.55, 0.72, 0.78, 0.55))
    draw_arc(knob, joystick_radius * 0.42, 0.0, TAU, 32, Color(0.9, 0.95, 1.0, 0.8), 2.0)

    _draw_button(zoom_in_rect, "+")
    _draw_button(zoom_out_rect, "−")
    _draw_button(focus_rect, "AF")

    draw_circle(
        shutter_rect.get_center(),
        shutter_rect.size.x * 0.5,
        Color(0.9, 0.9, 0.9, 0.25)
    )

    draw_arc(
        shutter_rect.get_center(),
        shutter_rect.size.x * 0.5,
        0.0,
        TAU,
        48,
        Color.WHITE,
        4.0
    )

    draw_circle(
        shutter_rect.get_center(),
        shutter_rect.size.x * 0.37,
        Color(1.0, 1.0, 1.0, 0.85)
    )


func _draw_button(rect: Rect2, label_text: String) -> void:
    draw_circle(
        rect.get_center(),
        rect.size.x * 0.5,
        Color(0.08, 0.13, 0.16, 0.65)
    )

    draw_arc(
        rect.get_center(),
        rect.size.x * 0.5,
        0.0,
        TAU,
        32,
        Color(0.85, 0.92, 0.95, 0.85),
        2.0
    )

    var font := ThemeDB.fallback_font
    var font_size := 25

    var text_size := font.get_string_size(
        label_text,
        HORIZONTAL_ALIGNMENT_CENTER,
        -1,
        font_size
    )

    draw_string(
        font,
        rect.get_center() + Vector2(-text_size.x * 0.5, text_size.y * 0.35),
        label_text,
        HORIZONTAL_ALIGNMENT_LEFT,
        -1,
        font_size,
        Color.WHITE
    )


func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        _handle_touch(event)

    elif event is InputEventScreenDrag:
        _handle_drag(event)


func _handle_touch(event: InputEventScreenTouch) -> void:
    if event.pressed:
        if zoom_in_rect.has_point(event.position):
            if is_instance_valid(camera_system):
                camera_system.call("zoom_in")
            queue_redraw()
            return

        if zoom_out_rect.has_point(event.position):
            if is_instance_valid(camera_system):
                camera_system.call("zoom_out")
            queue_redraw()
            return

        if focus_rect.has_point(event.position):
            if is_instance_valid(camera_system):
                camera_system.call("focus_forward")
            queue_redraw()
            return

        if shutter_rect.has_point(event.position):
            _take_photo()
            return

        if event.position.x < get_viewport_rect().size.x * 0.5:
            if left_touch_index == -1:
                left_touch_index = event.index
                joystick_active = true
                joystick_position = _get_joystick_center()
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
        var offset := event.position - _get_joystick_center()
        offset = offset.limit_length(joystick_radius)

        joystick_position = _get_joystick_center() + offset
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

    var offset := joystick_position - _get_joystick_center()
    var movement := offset / joystick_radius

    movement = movement.limit_length(1.0)

    if movement.length() < joystick_deadzone:
        movement = Vector2.ZERO

    player.call("set_mobile_move_input", movement)


func _take_photo() -> void:
    print("Shutter pressed - photo capture will be implemented next.")
