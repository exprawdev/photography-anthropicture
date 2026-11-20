
extends Node3D

signal weather_changed(weather_name: String)

enum WeatherType {
    CLEAR,
    CLOUDY,
    FOGGY,
    RAINY
}

@export var current_weather: WeatherType = WeatherType.CLEAR
@export var transition_speed: float = 0.5

var world_environment: WorldEnvironment
var directional_light: DirectionalLight3D

var target_fog_density: float = 0.003
var target_light_energy: float = 1.2
var target_ambient_energy: float = 0.7

var weather_names: Array[String] = [
    "Clear",
    "Cloudy",
    "Foggy",
    "Rainy"
]


func _ready() -> void:
    world_environment = get_parent().get_node_or_null(
        "WorldEnvironment"
    ) as WorldEnvironment

    directional_light = get_parent().get_node_or_null(
        "DirectionalLight3D"
    ) as DirectionalLight3D

    apply_weather(current_weather)


func _process(delta: float) -> void:
    if world_environment != null and world_environment.environment != null:
        var environment := world_environment.environment

        environment.fog_density = lerpf(
            environment.fog_density,
            target_fog_density,
            transition_speed * delta
        )

        environment.ambient_light_energy = lerpf(
            environment.ambient_light_energy,
            target_ambient_energy,
            transition_speed * delta
        )

    if directional_light != null:
        directional_light.light_energy = lerpf(
            directional_light.light_energy,
            target_light_energy,
            transition_speed * delta
        )


func apply_weather(weather: WeatherType) -> void:
    current_weather = weather

    match weather:
        WeatherType.CLEAR:
            target_fog_density = 0.002
            target_light_energy = 1.2
            target_ambient_energy = 0.8

        WeatherType.CLOUDY:
            target_fog_density = 0.006
            target_light_energy = 0.65
            target_ambient_energy = 0.65

        WeatherType.FOGGY:
            target_fog_density = 0.035
            target_light_energy = 0.8
            target_ambient_energy = 0.55

        WeatherType.RAINY:
            target_fog_density = 0.012
            target_light_energy = 0.45
            target_ambient_energy = 0.5

    weather_changed.emit(weather_names[weather])


func set_weather(weather: WeatherType) -> void:
    apply_weather(weather)


func get_weather_name() -> String:
    return weather_names[current_weather]
