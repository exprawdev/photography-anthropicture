
extends CanvasLayer

@export var settings_path: NodePath = NodePath("../DSLRSettings")

var dslr_settings: Node

var root_control: Control
var toggle_button: Button
var settings_panel: PanelContainer

var iso_slider: HSlider
var shutter_slider: HSlider
var aperture_slider: HSlider

var iso_label: Label
var shutter_label: Label
var aperture_label: Label


func _ready() -> void:
    dslr_settings = get_node_or_null(settings_path)

    _create_interface()

    get_viewport().size_changed.connect(_update_layout)
    _update_layout()


func _create_interface() -> void:
    root_control = Control.new()
    root_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(root_control)

    toggle_button = Button.new()
    toggle_button.text = "DSLR"
    toggle_button.custom_minimum_size = Vector2(110, 55)
    toggle_button.mouse_filter = Control.MOUSE_FILTER_STOP
    toggle_button.pressed.connect(_toggle_panel)
    root_control.add_child(toggle_button)

    settings_panel = PanelContainer.new()
    settings_panel.mouse_filter = Control.MOUSE_FILTER_STOP
    root_control.add_child(settings_panel)

    var layout := VBoxContainer.new()
    layout.add_theme_constant_override("separation", 10)
    settings_panel.add_child(layout)

    var title := Label.new()
    title.text = "CAMERA SETTINGS"
    layout.add_child(title)

    iso_label = Label.new()
    layout.add_child(iso_label)

    iso_slider = HSlider.new()
    iso_slider.min_value = 100
    iso_slider.max_value = 6400
    iso_slider.step = 100
    iso_slider.value = 100
    iso_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    iso_slider.custom_minimum_size.y = 35
    iso_slider.value_changed.connect(_on_iso_changed)
    layout.add_child(iso_slider)

    shutter_label = Label.new()
    layout.add_child(shutter_label)

    shutter_slider = HSlider.new()
    shutter_slider.min_value = 0.00025
    shutter_slider.max_value = 2.0
    shutter_slider.step = 0.00025
    shutter_slider.value = 0.01
    shutter_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    shutter_slider.custom_minimum_size.y = 35
    shutter_slider.value_changed.connect(_on_shutter_changed)
    layout.add_child(shutter_slider)

    aperture_label = Label.new()
    layout.add_child(aperture_label)

    aperture_slider = HSlider.new()
    aperture_slider.min_value = 1.4
    aperture_slider.max_value = 22.0
    aperture_slider.step = 0.1
    aperture_slider.value = 2.8
    aperture_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    aperture_slider.custom_minimum_size.y = 35
    aperture_slider.value_changed.connect(_on_aperture_changed)
    layout.add_child(aperture_slider)

    var close_button := Button.new()
    close_button.text = "CLOSE"
    close_button.custom_minimum_size.y = 45
    close_button.pressed.connect(_toggle_panel)
    layout.add_child(close_button)

    _load_current_settings()
    settings_panel.hide()


func _update_layout() -> void:
    if not is_instance_valid(root_control):
        return

    var screen_size := get_viewport().get_visible_rect().size

    toggle_button.position = Vector2(20, 90)

    var panel_width: float = minf(screen_size.x - 30.0, 380.0)
    var panel_height: float = minf(screen_size.y - 40.0, 390.0)

    panel_width = maxf(panel_width, 200.0)
    panel_height = maxf(panel_height, 250.0)

    settings_panel.size = Vector2(panel_width, panel_height)
    settings_panel.position = (
        screen_size - settings_panel.size
    ) * 0.5


func _load_current_settings() -> void:
    if not is_instance_valid(dslr_settings):
        return

    iso_slider.set_value_no_signal(dslr_settings.get_iso())
    shutter_slider.set_value_no_signal(
        dslr_settings.get_shutter_speed()
    )
    aperture_slider.set_value_no_signal(
        dslr_settings.get_aperture()
    )

    _update_labels()


func _toggle_panel() -> void:
    settings_panel.visible = not settings_panel.visible


func _on_iso_changed(value: float) -> void:
    if is_instance_valid(dslr_settings):
        dslr_settings.set_iso(roundi(value))

    _update_labels()


func _on_shutter_changed(value: float) -> void:
    if is_instance_valid(dslr_settings):
        dslr_settings.set_shutter_speed(value)

    _update_labels()


func _on_aperture_changed(value: float) -> void:
    if is_instance_valid(dslr_settings):
        dslr_settings.set_aperture(value)

    _update_labels()


func _update_labels() -> void:
    iso_label.text = "ISO: " + str(roundi(iso_slider.value))

    shutter_label.text = "Shutter: 1/" + str(
        roundi(1.0 / shutter_slider.value)
    ) + " sec" if shutter_slider.value < 1.0 else (
        "Shutter: " + str(snappedf(shutter_slider.value, 0.01)) + " sec"
    )

    aperture_label.text = "Aperture: f/" + str(
        snappedf(aperture_slider.value, 0.1)
    )
