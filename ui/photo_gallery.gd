
extends Control

@export var photo_directory: String = "user://photos"

var gallery_panel: Panel
var gallery_layout: BoxContainer
var list_panel: ScrollContainer
var photo_list: VBoxContainer
var preview: TextureRect
var gallery_button: Button
var close_button: Button
var delete_dialog: ConfirmationDialog
var photo_count_label: Label
var resolution_label: Label
var file_size_label: Label

var portrait_layout: bool = false
var selected_delete_path: String = ""
var displayed_photo_path: String = ""
var total_photo_count: int = 0


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

    photo_count_label = Label.new()
    photo_count_label.text = "PHOTOS: 0"
    photo_count_label.position = Vector2(125, 18)
    photo_count_label.custom_minimum_size = Vector2(160, 40)
    gallery_panel.add_child(photo_count_label)

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

    resolution_label = Label.new()
    resolution_label.text = "RESOLUTION: --"
    resolution_label.position = Vector2(10, 55)
    resolution_label.custom_minimum_size = Vector2(250, 35)
    gallery_panel.add_child(resolution_label)

    file_size_label = Label.new()
    file_size_label.text = "FILE SIZE: --"
    file_size_label.position = Vector2(10, 80)
    file_size_label.custom_minimum_size = Vector2(250, 35)
    gallery_panel.add_child(file_size_label)

    close_button = Button.new()
    close_button.text = "CLOSE"
    close_button.position = Vector2(10, 10)
    close_button.custom_minimum_size = Vector2(100, 45)
    close_button.pressed.connect(_close_gallery)
    gallery_panel.add_child(close_button)

    delete_dialog = ConfirmationDialog.new()
    delete_dialog.title = "Delete Photo"
    delete_dialog.confirmed.connect(_delete_selected_photo)
    add_child(delete_dialog)


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
    gallery_layout.offset_top = 110
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

    total_photo_count = 0

    var directory := DirAccess.open(photo_directory)

    if directory == null:
        _update_photo_count()

        var empty_label := Label.new()
        empty_label.text = "No photos found."
        photo_list.add_child(empty_label)
        return

    var photo_files: Array[String] = []

    directory.list_dir_begin()

    var file_name := directory.get_next()

    while file_name != "":
        if not directory.current_is_dir() and file_name.get_extension().to_lower() == "png":
            photo_files.append(file_name)

        file_name = directory.get_next()

    directory.list_dir_end()

    photo_files.sort()
    photo_files.reverse()

    total_photo_count = photo_files.size()
    _update_photo_count()

    if photo_files.is_empty():
        var empty_label := Label.new()
        empty_label.text = "No photos found."
        photo_list.add_child(empty_label)
        return

    for photo_file in photo_files:
        _add_photo_entry(photo_file)


func _update_photo_count() -> void:
    if is_instance_valid(photo_count_label):
        photo_count_label.text = "PHOTOS: " + str(total_photo_count)


func _add_photo_entry(file_name: String) -> void:
    var photo_path := photo_directory.path_join(file_name)

    var entry_row := HBoxContainer.new()
    entry_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

    var select_button := Button.new()
    select_button.text = file_name
    select_button.custom_minimum_size.y = 55
    select_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    select_button.pressed.connect(_show_photo.bind(photo_path))

    var delete_button := Button.new()
    delete_button.text = "DELETE"
    delete_button.custom_minimum_size = Vector2(85, 55)
    delete_button.pressed.connect(_confirm_delete_photo.bind(photo_path))

    entry_row.add_child(select_button)
    entry_row.add_child(delete_button)

    photo_list.add_child(entry_row)


func _show_photo(photo_path: String) -> void:
    var image := Image.load_from_file(photo_path)

    if image == null or image.is_empty():
        return

    preview.texture = ImageTexture.create_from_image(image)
    displayed_photo_path = photo_path

    resolution_label.text = "RESOLUTION: %d x %d" % [
        image.get_width(),
        image.get_height()
    ]

    var file_size := FileAccess.get_file_as_bytes(photo_path).size()
    file_size_label.text = "FILE SIZE: " + _format_file_size(file_size)


func _format_file_size(size_bytes: int) -> String:
    if size_bytes >= 1048576:
        return "%.2f MB" % (float(size_bytes) / 1048576.0)

    if size_bytes >= 1024:
        return "%.2f KB" % (float(size_bytes) / 1024.0)

    return str(size_bytes) + " B"


func _confirm_delete_photo(photo_path: String) -> void:
    selected_delete_path = photo_path
    delete_dialog.dialog_text = "Are you sure you want to delete this photo?"
    delete_dialog.popup_centered()


func _delete_selected_photo() -> void:
    if selected_delete_path.is_empty():
        return

    var absolute_path := ProjectSettings.globalize_path(
        selected_delete_path
    )

    var error := DirAccess.remove_absolute(absolute_path)

    if error != OK:
        push_error("Unable to delete photo: " + str(error))
        return

    if displayed_photo_path == selected_delete_path:
        preview.texture = null
        displayed_photo_path = ""
        resolution_label.text = "RESOLUTION: --"
        file_size_label.text = "FILE SIZE: --"

    selected_delete_path = ""

    _refresh_gallery()

    print("Photo deleted successfully.")
