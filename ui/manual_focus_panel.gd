
extends CanvasLayer

@export var camera_path: NodePath = NodePath("../Player/Camera3D")

var camera: Camera3D
var focus_slider: HSlider
var focus_label: Label
var panel: PanelContainer


func _ready() -> void:
    camera = get_node_or_null(camera_path) as Camera3D
    _create_interface()


func _create_interface() -> void:
    var toggle_button := Button.new()
    toggle_button.text = "FOCUS"
    toggle_button.position = Vector2(20, 160)
    toggle_button.custom_minimum_size = Vector2(110, 55)
    toggle_button.pressed.connect(_toggle_panel)
    add_child(toggle_button)

    panel = PanelContainer.new()
    panel.position = Vector2(20, 225)
    panel.custom_minimum_size = Vector2(300, 150)
    panel.size = Vector2(300, 150)
    add_child(panel)

    var layout := VBoxContainer.new()
    panel.add_child(layout)

    var title := Label.new()
    title.text = "MANUAL FOCUS"
    layout.add_child(title)

    focus_label = Label.new()
    layout.add_child(focus_label)

    focus_slider = HSlider.new()
    focus_slider.min_value = 0.5
    focus_slider.max_value = 200.0
    focus_slider.step = 0.5
    focus_slider.value = 20.0
    focus_slider.value_changed.connect(_on_focus_changed)
    layout.add_child(focus_slider)

    var close_button := Button.new()
    close_button.text = "CLOSE"
    close_button.pressed.connect(_toggle_panel)
    layout.add_child(close_button)

    panel.hide()
    _update_focus_label()


func _toggle_panel() -> void:
    panel.visible = not panel.visible


func _on_focus_changed(value: float) -> void:
    if is_instance_valid(camera) and camera.has_method("set_focus_distance"):
        camera.set_focus_distance(value)

    _update_focus_label()


func _update_focus_label() -> void:
    focus_label.text = "Focus Distance: " + str(
        snappedf(focus_slider.value, 0.5)
    ) + " m"
