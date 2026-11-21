
extends Control

@export var photo_directory: String = "user://photos"

var gallery_panel: Panel
var gallery_layout: BoxContainer
var list_panel: ScrollContainer
var photo_list: VBoxContainer
var preview: TextureRect
var gallery_button: Button
var close_button: Button

var portrait_layout: bool = false


func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    _create_gallery_interface()
    _update_gallery_layout()
    _refresh_gallery()

    get_viewport().size_changed.connect(_update_gallery_layout)

    gallery_panel.hide()


func _create_gallery_interface() -> void:
    gallery_button = Button.new()
    gallery_button.text = "GALLERY"
    gallery_button.position = Vector2(20, 20)
    gallery_button.custom_minimum_size = Vector2(130, 55)
    gallery_button.pressed.connect(_open_gallery)
    add_child(gallery_button)

    gallery_panel = Panel.new()
    gallery_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    gallery_panel.offset_left = 15
    gallery_panel.offset_top = 15
    gallery_panel.offset_right = -15
    gallery_panel.offset_bottom = -15
    add_child(gallery_panel)

    list_panel = ScrollContainer.new()
    list_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    list_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL

    photo_list = VBoxContainer.new()
    photo_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    list_panel.add_child(photo_list)

    preview = TextureRect.new()
    preview.custom_minimum_size = Vector2(220, 220)
    preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
    preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

    close_button = Button.new()
    close_button.text = "CLOSE"
    close_button.position = Vector2(10, 10)
    close_button.custom_minimum_size = Vector2(100, 45)
    close_button.pressed.connect(_close_gallery)
    gallery_panel.add_child(close_button)


func _update_gallery_layout() -> void:
    if not is_instance_valid(gallery_panel):
        return

    var screen_size := get_viewport_rect().size
    var use_portrait := screen_size.y > screen_size.x

    if gallery_layout != null and portrait_layout == use_portrait:
        return

    portrait_layout = use_portrait

    if gallery_layout != null:
        gallery_layout.remove_child(list_panel)
        gallery_layout.remove_child(preview)
        gallery_layout.queue_free()

    if portrait_layout:
        gallery_layout = VBoxContainer.new()
        list_panel.custom_minimum_size = Vector2(0, 150)
        preview.custom_minimum_size = Vector2(220, 220)
    else:
        gallery_layout = HBoxContainer.new()
        list_panel.custom_minimum_size = Vector2(200, 0)
        preview.custom_minimum_size = Vector2(220, 220)

    gallery_layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    gallery_layout.offset_left = 10
    gallery_layout.offset_top = 60
    gallery_layout.offset_right = -10
    gallery_layout.offset_bottom = -10

    gallery_layout.add_theme_constant_override("separation", 12)

    gallery_panel.add_child(gallery_layout)
    gallery_layout.add_child(list_panel)
    gallery_layout.add_child(preview)


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
