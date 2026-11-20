
extends Node3D

@export var deer_count: int = 5
@export var movement_radius: float = 18.0
@export var movement_speed: float = 1.2
@export var leg_animation_speed: float = 7.0
@export var leg_animation_strength: float = 0.3
@export var random_seed: int = 24680

var random_generator := RandomNumberGenerator.new()

var deer_list: Array[Node3D] = []
var deer_legs: Array[Array] = []
var target_positions: Array[Vector3] = []
var movement_timers: Array[float] = []
var animation_phases: Array[float] = []


func _ready() -> void:
    random_generator.seed = random_seed
    generate_deer()


func generate_deer() -> void:
    var body_material := StandardMaterial3D.new()
    body_material.albedo_color = Color(0.42, 0.23, 0.12)
    body_material.roughness = 1.0

    var body_mesh := SphereMesh.new()
    body_mesh.radius = 0.55
    body_mesh.height = 1.1
    body_mesh.material = body_material

    var head_mesh := SphereMesh.new()
    head_mesh.radius = 0.23
    head_mesh.height = 0.5
    head_mesh.material = body_material

    var leg_mesh := CylinderMesh.new()
    leg_mesh.top_radius = 0.055
    leg_mesh.bottom_radius = 0.075
    leg_mesh.height = 0.65
    leg_mesh.material = body_material

    for i in range(deer_count):
        var deer := Node3D.new()
        deer.name = "Deer_" + str(i)
        add_child(deer)

        var body := MeshInstance3D.new()
        body.mesh = body_mesh
        body.position = Vector3(0.0, 1.0, 0.0)
        body.scale = Vector3(1.0, 0.85, 1.7)
        deer.add_child(body)

        var head := MeshInstance3D.new()
        head.mesh = head_mesh
        head.position = Vector3(0.0, 1.35, -0.85)
        deer.add_child(head)

        var legs: Array[MeshInstance3D] = []

        for leg_index in range(4):
            var leg := MeshInstance3D.new()
            leg.mesh = leg_mesh

            var side := -1.0 if leg_index % 2 == 0 else 1.0
            var front := -0.55 if leg_index < 2 else 0.55

            leg.position = Vector3(
                side * 0.28,
                0.4,
                front
            )

            deer.add_child(leg)
            legs.append(leg)

        deer.position = Vector3(
            random_generator.randf_range(-movement_radius, movement_radius),
            0.0,
            random_generator.randf_range(-movement_radius, movement_radius)
        )

        deer_list.append(deer)
        deer_legs.append(legs)
        target_positions.append(_get_random_target())
        movement_timers.append(random_generator.randf_range(2.0, 5.0))
        animation_phases.append(random_generator.randf_range(0.0, TAU))


func _process(delta: float) -> void:
    for i in range(deer_list.size()):
        var deer := deer_list[i]

        movement_timers[i] -= delta

        if movement_timers[i] <= 0.0:
            target_positions[i] = _get_random_target()
            movement_timers[i] = random_generator.randf_range(3.0, 7.0)

        var direction := target_positions[i] - deer.position
        direction.y = 0.0

        var is_moving := direction.length() > 0.3

        if is_moving:
            deer.position += direction.normalized() * movement_speed * delta
            deer.rotation.y = atan2(-direction.x, -direction.z)

        var animation_time := (
            Time.get_ticks_msec() * 0.001 * leg_animation_speed
            + animation_phases[i]
        )

        for leg_index in range(deer_legs[i].size()):
            var leg := deer_legs[i][leg_index]

            if is_moving:
                var phase_offset := PI if leg_index % 2 == 0 else 0.0
                leg.rotation.x = sin(animation_time + phase_offset) * leg_animation_strength
            else:
                leg.rotation.x = move_toward(
                    leg.rotation.x,
                    0.0,
                    delta * 2.0
                )


func _get_random_target() -> Vector3:
    return Vector3(
        random_generator.randf_range(-movement_radius, movement_radius),
        0.0,
        random_generator.randf_range(-movement_radius, movement_radius)
    )
