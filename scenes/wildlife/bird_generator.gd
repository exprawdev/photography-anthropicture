
extends Node3D

@export var bird_count: int = 12
@export var flight_radius: float = 25.0
@export var flight_height: float = 8.0
@export var flight_speed: float = 1.5
@export var wing_speed: float = 12.0
@export var wing_angle: float = 0.65

var random_generator := RandomNumberGenerator.new()

var birds: Array[Node3D] = []
var left_wings: Array[MeshInstance3D] = []
var right_wings: Array[MeshInstance3D] = []

var flight_angles: Array[float] = []
var flight_heights: Array[float] = []
var bird_phases: Array[float] = []


func _ready() -> void:
    random_generator.randomize()
    generate_birds()


func generate_birds() -> void:
    var body_mesh := SphereMesh.new()
    body_mesh.radius = 0.18
    body_mesh.height = 0.36
    body_mesh.radial_segments = 8
    body_mesh.rings = 5

    var body_material := StandardMaterial3D.new()
    body_material.albedo_color = Color(0.12, 0.13, 0.14)
    body_material.roughness = 0.9
    body_mesh.material = body_material

    var wing_mesh := BoxMesh.new()
    wing_mesh.size = Vector3(0.55, 0.035, 0.16)

    var wing_material := StandardMaterial3D.new()
    wing_material.albedo_color = Color(0.08, 0.09, 0.1)
    wing_material.roughness = 1.0
    wing_mesh.material = wing_material

    for i in range(bird_count):
        var bird := Node3D.new()
        bird.name = "Bird_" + str(i)
        add_child(bird)

        var body := MeshInstance3D.new()
        body.mesh = body_mesh
        bird.add_child(body)

        var left_wing := MeshInstance3D.new()
        left_wing.mesh = wing_mesh
        left_wing.position = Vector3(-0.22, 0.0, 0.0)
        bird.add_child(left_wing)

        var right_wing := MeshInstance3D.new()
        right_wing.mesh = wing_mesh
        right_wing.position = Vector3(0.22, 0.0, 0.0)
        bird.add_child(right_wing)

        birds.append(bird)
        left_wings.append(left_wing)
        right_wings.append(right_wing)

        flight_angles.append(
            random_generator.randf_range(0.0, TAU)
        )

        flight_heights.append(
            random_generator.randf_range(
                flight_height - 3.0,
                flight_height + 3.0
            )
        )

        bird_phases.append(
            random_generator.randf_range(0.0, TAU)
        )


func _process(delta: float) -> void:
    for i in range(birds.size()):
        flight_angles[i] += flight_speed * delta

        var angle := flight_angles[i]
        var bird := birds[i]

        bird.position = Vector3(
            cos(angle) * flight_radius,
            flight_heights[i] + sin(angle * 2.0) * 0.6,
            sin(angle) * flight_radius
        )

        bird.rotation.y = -angle + PI * 0.5

        var flap := sin(
            Time.get_ticks_msec() * 0.001 * wing_speed
            + bird_phases[i]
        ) * wing_angle

        left_wings[i].rotation.z = flap
        right_wings[i].rotation.z = -flap
