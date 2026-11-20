
extends Node

signal camera_settings_changed(
    iso: int,
    shutter_speed: float,
    aperture: float
)

@export var iso: int = 100
@export var shutter_speed: float = 0.01
@export var aperture: float = 2.8

const MIN_ISO: int = 100
const MAX_ISO: int = 6400

const MIN_SHUTTER: float = 0.00025
const MAX_SHUTTER: float = 2.0

const MIN_APERTURE: float = 1.4
const MAX_APERTURE: float = 22.0

var exposure_multiplier: float = 1.0


func _ready() -> void:
    _clamp_settings()
    _update_exposure()
    _emit_settings()


func set_iso(value: int) -> void:
    iso = clampi(value, MIN_ISO, MAX_ISO)
    _update_exposure()
    _emit_settings()


func set_shutter_speed(value: float) -> void:
    shutter_speed = clampf(
        value,
        MIN_SHUTTER,
        MAX_SHUTTER
    )
    _update_exposure()
    _emit_settings()


func set_aperture(value: float) -> void:
    aperture = clampf(
        value,
        MIN_APERTURE,
        MAX_APERTURE
    )
    _update_exposure()
    _emit_settings()


func get_iso() -> int:
    return iso


func get_shutter_speed() -> float:
    return shutter_speed


func get_aperture() -> float:
    return aperture


func get_exposure_value() -> float:
    return log(
        (aperture * aperture) / shutter_speed
    ) / log(2.0) - log(
        float(iso) / 100.0
    ) / log(2.0)


func get_exposure_multiplier() -> float:
    return exposure_multiplier


func _update_exposure() -> void:
    var exposure_value := get_exposure_value()

    exposure_multiplier = pow(
        2.0,
        -exposure_value
    )

    exposure_multiplier = clampf(
        exposure_multiplier,
        0.001,
        16.0
    )


func _clamp_settings() -> void:
    iso = clampi(iso, MIN_ISO, MAX_ISO)

    shutter_speed = clampf(
        shutter_speed,
        MIN_SHUTTER,
        MAX_SHUTTER
    )

    aperture = clampf(
        aperture,
        MIN_APERTURE,
        MAX_APERTURE
    )


func _emit_settings() -> void:
    camera_settings_changed.emit(
        iso,
        shutter_speed,
        aperture
    )
