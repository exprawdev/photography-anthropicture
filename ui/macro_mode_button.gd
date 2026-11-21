
extends CanvasLayer

@export var camera_path: NodePath = NodePath("../Player/Camera3D")

var camera: Camera3D
var macro_enabled: bool = false
var macro_button: Button

var normal_fov: float = 55.0
var macro_fov: float = 35.0

var normal_focus_distance: float = 20.0
var macro_focus_distance: float = 1.5


func _ready() -> void:
    camera = get_node_or_null(camera_path) as Camera3D
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
    normal_fov = camera.fov
    normal_focus_distance = camera.focus_distance if "focus_distance" in camera else 20.0

    camera.fov = macro_fov

    if camera.has_method("set_focus_distance"):
        camera.set_focus_distance(macro_focus_distance)

    macro_button.text = "MACRO ON"


func _disable_macro() -> void:
    camera.fov = normal_fov

    if camera.has_method("set_focus_distance"):
        camera.set_focus_distance(normal_focus_distance)

    macro_button.text = "MACRO OFF"
