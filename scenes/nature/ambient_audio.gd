
extends Node3D

@export var ambient_volume: float = -12.0
@export var wind_volume: float = -18.0
@export var birds_volume: float = -16.0

var ambient_player: AudioStreamPlayer
var wind_player: AudioStreamPlayer
var birds_player: AudioStreamPlayer


func _ready() -> void:
    _create_audio_players()


func _create_audio_players() -> void:
    ambient_player = _create_player("AmbientAudio", ambient_volume)
    wind_player = _create_player("WindAudio", wind_volume)
    birds_player = _create_player("BirdsAudio", birds_volume)


func _create_player(player_name: String, volume: float) -> AudioStreamPlayer:
    var audio_player := AudioStreamPlayer.new()
    audio_player.name = player_name
    audio_player.volume_db = volume
    audio_player.bus = "Master"
    add_child(audio_player)
    return audio_player


func set_ambient_stream(stream: AudioStream) -> void:
    ambient_player.stream = stream
    _play_if_available(ambient_player)


func set_wind_stream(stream: AudioStream) -> void:
    wind_player.stream = stream
    _play_if_available(wind_player)


func set_birds_stream(stream: AudioStream) -> void:
    birds_player.stream = stream
    _play_if_available(birds_player)


func _play_if_available(player: AudioStreamPlayer) -> void:
    if player.stream != null:
        player.play()


func set_ambient_volume(value: float) -> void:
    ambient_volume = clampf(value, -40.0, 0.0)
    ambient_player.volume_db = ambient_volume


func set_wind_volume(value: float) -> void:
    wind_volume = clampf(value, -40.0, 0.0)
    wind_player.volume_db = wind_volume


func set_birds_volume(value: float) -> void:
    birds_volume = clampf(value, -40.0, 0.0)
    birds_player.volume_db = birds_volume


func stop_all_audio() -> void:
    ambient_player.stop()
    wind_player.stop()
    birds_player.stop()
