
extends Node

signal photo_saved(file_path: String)
signal photo_failed(error_code: int)

@export var photo_directory: String = "user://photos"
@export var dslr_settings_path: NodePath = NodePath("../DSLRSettings")

var dslr_settings: Node


func _ready() -> void:
    dslr_settings = get_node_or_null(dslr_settings_path)

    var error := DirAccess.make_dir_recursive_absolute(
        ProjectSettings.globalize_path(photo_directory)
    )

    if error != OK:
        push_error("Unable to create photo directory: " + str(error))


func capture_photo(hud: CanvasItem = null) -> void:
    if not is_inside_tree():
        return

    if hud != null:
        hud.hide()

    await RenderingServer.frame_post_draw

    var viewport := get_viewport()
    var image := viewport.get_texture().get_image()

    if hud != null:
        hud.show()

    if image == null or image.is_empty():
        photo_failed.emit(ERR_CANT_CREATE)
        return

    _apply_camera_exposure(image)

    var file_name := "photo_%s.png" % str(Time.get_ticks_msec())
    var file_path := photo_directory.path_join(file_name)

    var error := image.save_png(file_path)

    if error != OK:
        push_error("Photo could not be saved: " + str(error))
        photo_failed.emit(error)
        return

    print("Photo saved: ", file_path)
    photo_saved.emit(file_path)


func _apply_camera_exposure(image: Image) -> void:
    if not is_instance_valid(dslr_settings):
        return

    var exposure_stops: float = dslr_settings.get_exposure_value()

    var brightness := clampf(
        exposure_stops * 0.12,
        -0.6,
        0.6
    )

    image.adjust_bcs(
        brightness,
        1.0,
        1.0
    )


func get_photo_directory() -> String:
    return photo_directory
