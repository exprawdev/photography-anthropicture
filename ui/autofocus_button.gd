
extends CanvasLayer

@export var camera_path: NodePath = NodePath("../Player/Camera3D")

var camera: Camera3D
var autofocus_button: Button


func _ready() -> void:
    camera = get_node_or_null(camera_path) as Camera3D
    _create_button()


func _create_button() -> void:
    var container := Control.new()
    container.set_anchors_and_offsets_preset(
        Control.PRESET_FULL_RECT
    )
    container.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(container)

    autofocus_button = Button.new()
    autofocus_button.name = "AutofocusButton"
    autofocus_button.text = "AF"
    autofocus_button.custom_minimum_size = Vector2(110, 55)

    autofocus_button.anchor_left = 1.0
    autofocus_button.anchor_top = 0.0
    autofocus_button.anchor_right = 1.0
    autofocus_button.anchor_bottom = 0.0

    autofocus_button.offset_left = -130
    autofocus_button.offset_top = 20
    autofocus_button.offset_right = -20
    autofocus_button.offset_bottom = 75

    autofocus_button.pressed.connect(_on_autofocus_pressed)

    container.add_child(autofocus_button)


func _on_autofocus_pressed() -> void:
    if not is_instance_valid(camera):
        autofocus_button.text = "NO CAMERA"
        return

    if not camera.has_method("autofocus"):
        autofocus_button.text = "AF ERROR"
        return

    var success: bool = camera.autofocus()

    if success:
        autofocus_button.text = "FOCUSED"
    else:
        autofocus_button.text = "NO TARGET"
