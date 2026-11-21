
extends Control

@export var joystick_radius: float = 85.0
@export var joystick_deadzone: float = 0.12
@export var player_path: NodePath = NodePath("../../Player")
@export var camera_system_path: NodePath = NodePath("../../Player/CameraSystem")
@export var photo_capture_path: NodePath = NodePath("../../PhotoCapture")

var player: Node3D
var camera_system: Node3D
var photo_capture: Node

var left_touch_index: int = -1
var right_touch_index: int = -1

var joystick_position: Vector2 = Vector2.ZERO
var joystick_active: bool = false

var current_joystick_radius: float = 85.0
var button_size: float = 65.0
var button_spacing: float = 9.0

var zoom_in_rect := Rect2()
var zoom_out_rect := Rect2()
var focus_rect := Rect2()
var shutter_rect := Rect2()

var is_capturing: bool = false


func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_IGNORE

    player = get_node_or_null(player_path) as Node3D
    camera_system = get_node_or_null(camera_system_path) as Node3D
    photo_capture = get_node_or_null(photo_capture_path)

    _update_button_positions()

    if is_instance_valid(photo_capture):
        photo_capture.photo_saved.connect(_on_photo_saved)
        photo_capture.photo_failed.connect(_on_photo_failed)

    queue_redraw()


func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        _update_button_positions()
        queue_redraw()


func _update_button_positions() -> void:
    var screen_size := get_viewport_rect().size
    var shortest_side := minf(screen_size.x, screen_size.y)

    current_joystick_radius = minf(
        joystick_radius,
        maxf(36.0, shortest_side * 0.12)
    )

    button_size = clampf(
        minf(shortest_side * 0.14, screen_size.y * 0.16),
        36.0,
        72.0
    )

    button_spacing = clampf(
        shortest_side * 0.025,
        5.0,
        9.0
    )

    var margin := clampf(shortest_side * 0.05, 10.0, 18.0)
    var right_x := screen_size.x - button_size - margin

    var shutter_size := button_size * 1.25

    var total_height := (
        button_size * 3.0
        + button_spacing * 3.0
        + shutter_size
    )

    var start_y := maxf(
        8.0,
        (screen_size.y - total_height) * 0.5
    )

    zoom_in_rect = Rect2(
        right_x,
        start_y,
        button_size,
        button_size
    )

    zoom_out_rect = Rect2(
        right_x,
        start_y + button_size + button_spacing,
        button_size,
        button_size
    )

    focus_rect = Rect2(
        right_x,
        start_y + (button_size + button_spacing) * 2.0,
        button_size,
        button_size
    )

    shutter_rect = Rect2(
        right_x - (shutter_size - button_size) * 0.5,
        start_y + (button_size + button_spacing) * 3.0,
        shutter_size,
        shutter_size
    )

    joystick_position = _get_joystick_center()


func _draw() -> void:
    var center := _get_joystick_center()
    var knob := center

    if joystick_active:
        knob = joystick_position

    draw_circle(
        center,
        current_joystick_radius,
        Color(0.1, 0.15, 0.18, 0.25)
    )

    draw_arc(
        center,
        current_joystick_radius,
        0.0,
        TAU,
        48,
        Color(0.85, 0.9, 0.92, 0.65),
        3.0
    )

    draw_circle(
        knob,
        current_joystick_radius * 0.42,
        Color(0.55, 0.72, 0.78, 0.55)
    )

    draw_arc(
        knob,
        current_joystick_radius * 0.42,
        0.0,
        TAU,
        32,
        Color(0.9, 0.95, 1.0, 0.8),
        2.0
    )

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
    var font_size := roundi(rect.size.x * 0.36)

    var text_size := font.get_string_size(
        label_text,
        HORIZONTAL_ALIGNMENT_CENTER,
        -1,
        font_size
    )

    draw_string(
        font,
        rect.get_center() + Vector2(
            -text_size.x * 0.5,
            text_size.y * 0.35
        ),
        label_text,
        HORIZONTAL_ALIGNMENT_LEFT,
        -1,
        font_size,
        Color.WHITE
    )


func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        _handle_touch(event)

    elif event is InputEventScreenDrag:
        _handle_drag(event)


func _handle_touch(event: InputEventScreenTouch) -> void:
    if event.pressed:
        if zoom_in_rect.has_point(event.position):
            if is_instance_valid(camera_system):
                camera_system.call("zoom_in")

            get_viewport().set_input_as_handled()
            queue_redraw()
            return

        if zoom_out_rect.has_point(event.position):
            if is_instance_valid(camera_system):
                camera_system.call("zoom_out")

            get_viewport().set_input_as_handled()
            queue_redraw()
            return

        if focus_rect.has_point(event.position):
            if is_instance_valid(camera_system):
                camera_system.call("focus_forward")

            get_viewport().set_input_as_handled()
            queue_redraw()
            return

        if shutter_rect.has_point(event.position):
            _take_photo()

            get_viewport().set_input_as_handled()
            return

        if event.position.x < get_viewport_rect().size.x * 0.5:
            if left_touch_index == -1:
                left_touch_index = event.index
                joystick_active = true
                joystick_position = _get_joystick_center()
                _update_player_movement()

                get_viewport().set_input_as_handled()
        else:
            if right_touch_index == -1:
                right_touch_index = event.index
                get_viewport().set_input_as_handled()

    else:
        if event.index == left_touch_index:
            left_touch_index = -1
            joystick_active = false
            joystick_position = _get_joystick_center()
            _update_player_movement()

            get_viewport().set_input_as_handled()

        if event.index == right_touch_index:
            right_touch_index = -1
            get_viewport().set_input_as_handled()

    queue_redraw()


func _handle_drag(event: InputEventScreenDrag) -> void:
    if event.index == left_touch_index:
        var offset := event.position - _get_joystick_center()
        offset = offset.limit_length(current_joystick_radius)

        joystick_position = _get_joystick_center() + offset
        _update_player_movement()

        get_viewport().set_input_as_handled()
        queue_redraw()

    elif event.index == right_touch_index:
        if is_instance_valid(player):
            player.call("rotate_from_touch", event.relative)

        get_viewport().set_input_as_handled()


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
    var movement := offset / current_joystick_radius

    movement = movement.limit_length(1.0)

    if movement.length() < joystick_deadzone:
        movement = Vector2.ZERO

    player.call("set_mobile_move_input", movement)


func _take_photo() -> void:
    if is_capturing:
        return

    if not is_instance_valid(photo_capture):
        push_warning("PhotoCapture node was not found.")
        return

    is_capturing = true
    photo_capture.call("capture_photo", self)


func _on_photo_saved(file_path: String) -> void:
    is_capturing = false
    print("Photography saved successfully: ", file_path)


func _on_photo_failed(error_code: int) -> void:
    is_capturing = false
    push_warning("Photography failed. Error: " + str(error_code))
