
extends Control

@export var photo_directory: String = "user://photos"

var gallery_panel: Panel
var photo_list: VBoxContainer
var preview: TextureRect
var gallery_button: Button
var close_button: Button


func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    _create_gallery_interface()
    _refresh_gallery()

    gallery_panel.hide()


func _create_gallery_interface() -> void:
    gallery_button = Button.new()
    gallery_button.text = "GALLERY"
    gallery_button.position = Vector2(20, 20)
    gallery_button.size = Vector2(130, 55)
    gallery_button.pressed.connect(_open_gallery)
    add_child(gallery_button)

    gallery_panel = Panel.new()
    gallery_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    gallery_panel.offset_left = 40
    gallery_panel.offset_top = 40
    gallery_panel.offset_right = -40
    gallery_panel.offset_bottom = -40
    add_child(gallery_panel)

    var layout := HBoxContainer.new()
    layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    layout.add_theme_constant_override("separation", 15)
    gallery_panel.add_child(layout)

    var list_panel := ScrollContainer.new()
    list_panel.custom_minimum_size.x = 250
    list_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    layout.add_child(list_panel)

    photo_list = VBoxContainer.new()
    photo_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    list_panel.add_child(photo_list)

    preview = TextureRect.new()
    preview.custom_minimum_size = Vector2(300, 250)
    preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
    preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    layout.add_child(preview)

    close_button = Button.new()
    close_button.text = "CLOSE"
    close_button.position = Vector2(10, 10)
    close_button.size = Vector2(100, 45)
    close_button.pressed.connect(_close_gallery)
    gallery_panel.add_child(close_button)


func _open_gallery() -> void:
    _refresh_gallery()
    gallery_panel.show()


func _close_gallery() -> void:
    gallery_panel.hide()


func _refresh_gallery() -> void:
    if not is_instance_valid(photo_list):
        return

    for child in photo_list.get_children():
        child.queue_free()

    var directory := DirAccess.open(photo_directory)

    if directory == null:
        var empty_label := Label.new()
        empty_label.text = "No photos found."
        photo_list.add_child(empty_label)
        return

    directory.list_dir_begin()

    var file_name := directory.get_next()

    while file_name != "":
        if not directory.current_is_dir() and file_name.get_extension().to_lower() == "png":
            _add_photo_entry(file_name)

        file_name = directory.get_next()

    directory.list_dir_end()


func _add_photo_entry(file_name: String) -> void:
    var photo_path := photo_directory.path_join(file_name)

    var button := Button.new()
    button.text = file_name
    button.custom_minimum_size.y = 55
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL

    button.pressed.connect(
        _show_photo.bind(photo_path)
    )

    photo_list.add_child(button)


func _show_photo(photo_path: String) -> void:
    var image := Image.load_from_file(photo_path)

    if image == null or image.is_empty():
        return

    var texture := ImageTexture.create_from_image(image)
    preview.texture = texture
