
extends CanvasLayer

@export var camera_path: NodePath = NodePath("../Player/Camera3D")

var camera: Camera3D

var root_control: Control
var toggle_button: Button
var panel: PanelContainer

var blur_slider: HSlider
var blur_label: Label


func _ready() -> void:
    camera = get_node_or_null(camera_path) as Camera3D

    _create_interface()

    get_viewport().size_changed.connect(_update_layout)
    _update_layout()


func _create_interface() -> void:
    root_control = Control.new()
    root_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(root_control)

    toggle_button = Button.new()
    toggle_button.text = "DOF"
    toggle_button.position = Vector2(20, 295)
    toggle_button.custom_minimum_size = Vector2(110, 55)
    toggle_button.mouse_filter = Control.MOUSE_FILTER_STOP
    toggle_button.pressed.connect(_toggle_panel)
    root_control.add_child(toggle_button)

    panel = PanelContainer.new()
    panel.mouse_filter = Control.MOUSE_FILTER_STOP
    root_control.add_child(panel)

    var layout := VBoxContainer.new()
    layout.add_theme_constant_override("separation", 12)
    panel.add_child(layout)

    var title := Label.new()
    title.text = "DEPTH OF FIELD"
    layout.add_child(title)

    blur_label = Label.new()
    layout.add_child(blur_label)

    blur_slider = HSlider.new()
    blur_slider.min_value = 0.0
    blur_slider.max_value = 1.0
    blur_slider.step = 0.05
    blur_slider.value = 0.15
    blur_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    blur_slider.custom_minimum_size.y = 45
    blur_slider.value_changed.connect(_on_blur_changed)
    layout.add_child(blur_slider)

    var close_button := Button.new()
    close_button.text = "CLOSE"
    close_button.custom_minimum_size.y = 45
    close_button.pressed.connect(_toggle_panel)
    layout.add_child(close_button)

    _load_current_settings()

    panel.hide()
    _update_label()


func _update_layout() -> void:
    if not is_instance_valid(root_control):
        return

    var screen_size := get_viewport().get_visible_rect().size

    toggle_button.position = Vector2(20, 295)

    var panel_width: float = minf(screen_size.x - 30.0, 380.0)
    var panel_height: float = minf(screen_size.y - 40.0, 190.0)

    panel_width = maxf(panel_width, 200.0)
    panel_height = maxf(panel_height, 160.0)

    panel.size = Vector2(panel_width, panel_height)
    panel.position = (screen_size - panel.size) * 0.5


func _load_current_settings() -> void:
    if not is_instance_valid(camera):
        return

    var current_blur: Variant = camera.get("blur_amount")

    if current_blur != null:
        blur_slider.set_value_no_signal(float(current_blur))


func _toggle_panel() -> void:
    panel.visible = not panel.visible


func _on_blur_changed(value: float) -> void:
    if is_instance_valid(camera) and camera.has_method("set_blur_amount"):
        camera.set_blur_amount(value)

    _update_label()


func _update_label() -> void:
    blur_label.text = "Blur Strength: " + str(
        snappedf(blur_slider.value, 0.05)
    )
