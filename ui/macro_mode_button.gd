
extends CanvasLayer

@export var camera_path: NodePath = NodePath("../Player/Camera3D")
@export var camera_system_path: NodePath = NodePath("../Player/CameraSystem")

var camera: Camera3D
var camera_system: Node
var macro_enabled: bool = false
var macro_button: Button

var normal_fov: float = 55.0
var macro_fov: float = 35.0

var normal_focus_distance: float = 20.0
var macro_focus_distance: float = 1.5


func _ready() -> void:
    camera = get_node_or_null(camera_path) as Camera3D
    camera_system = get_node_or_null(camera_system_path)

    _create_button()


func _create_button() -> void:
    macro_button = Button.new()
    macro_button.text = "MACRO OFF"
    macro_button.position = Vector2(20, 430)
    macro_button.custom_minimum_size = Vector2(140, 55)
    macro_button.pressed.connect(_toggle_macro)
    add_child(macro_button)


func _toggle_macro() -> void:
    if not is_instance_valid(camera):
        return

    macro_enabled = not macro_enabled

    if macro_enabled:
        _enable_macro()
    else:
        _disable_macro()


func _enable_macro() -> void:
    if is_instance_valid(camera_system):
        normal_fov = camera_system.get_current_zoom()
        normal_focus_distance = camera_system.get_focus_distance()
    else:
        normal_fov = camera.fov

        if camera.has_method("get_focus_distance"):
            normal_focus_distance = camera.get_focus_distance()

    _set_zoom(macro_fov)
    _set_focus(macro_focus_distance)

    macro_button.text = "MACRO ON"


func _disable_macro() -> void:
    _set_zoom(normal_fov)
    _set_focus(normal_focus_distance)

    macro_button.text = "MACRO OFF"


func _set_zoom(value: float) -> void:
    if is_instance_valid(camera_system):
        camera_system.set_zoom(value)
    else:
        camera.fov = value


func _set_focus(value: float) -> void:
    if is_instance_valid(camera_system):
        camera_system.set_focus_distance(value)
    elif camera.has_method("set_focus_distance"):
        camera.set_focus_distance(value)
