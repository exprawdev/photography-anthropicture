
@tool
extends EditorPlugin

var export_plugin: AndroidShareExportPlugin


func _enter_tree() -> void:
    export_plugin = AndroidShareExportPlugin.new()
    add_export_plugin(export_plugin)


func _exit_tree() -> void:
    if export_plugin != null:
        remove_export_plugin(export_plugin)
        export_plugin = null


class AndroidShareExportPlugin extends EditorExportPlugin:

    var plugin_name: String = "AndroidShare"

    func _supports_platform(platform: EditorExportPlatform) -> bool:
        return platform is EditorExportPlatformAndroid

    func _get_android_libraries(
        platform: EditorExportPlatform,
        debug: bool
    ) -> PackedStringArray:
        return PackedStringArray([
            "AndroidShare/bin/AndroidShare.aar"
        ])

    func _get_name() -> String:
        return plugin_name
