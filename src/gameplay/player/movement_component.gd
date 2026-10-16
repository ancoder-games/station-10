## Moves entities
class_name MovementComponent extends Node

## The characterbody to apply forces to.
@export var body: CharacterBody3D
## Should apply forces
@export var enabled: bool = true

@export_category("Settings")
@export var jump_power: float = 4.5
@export var speed: float = 5.0
@export var speed_sprinting: float = 9.0
@export var speed_crouching: float = 2.0

@export_group("Visual")
@export var headbob_frequency: float = 2.0
@export var headbob_amplitude: float = 0.04

@export var base_fov: float = 80

@export_category("References")
@export var footstep_player: AudioStreamPlayer3D
@export var surface_ray: RayCast3D
@export var camera: Camera3D

var _head_bob_time: float = 0
var _footstep_can_play: bool = false
var _surface: Surface
var _footstep_landed: bool = false

var sprinting: bool = false

var _direction: Vector2 = Vector2.ZERO

var crouching: bool = false

func tick(delta: float) -> void:
	if not _should_run(): return

	_apply_gravity(delta)
	_apply_directional_movement(delta)

	if surface_ray.is_colliding():
		var collider: Node3D = surface_ray.get_collider()
		if collider.has_meta("surface"):
			if collider.get_meta("surface") is Surface:
				_surface = collider.get_meta("surface")
	
	body.move_and_slide()

	if not _footstep_landed and body.is_on_floor():
		if _surface:
			play_stream(_surface.footstep_walk)
	elif _footstep_landed and not body.is_on_floor():
		if _surface:
			play_stream(_surface.footstep_walk)
	
	_footstep_landed = body.is_on_floor()

func jump() -> void:
	if not _should_run(): return
	if crouching: return
	if body.is_on_floor():
		body.velocity.y = jump_power
	
func set_direction(direction: Vector2) -> void:
	if not _should_run(): return
	_direction = direction

func _should_run() -> bool:
	return body and enabled

func _apply_gravity(delta: float) -> void:
	if not body.is_on_floor():
		body.velocity += body.get_gravity() * delta

func _apply_directional_movement(delta: float) -> void:
	var dir: Vector3 = (body.transform.basis * Vector3(_direction.x, 0, _direction.y)).normalized()
	
	_head_bob_time += delta * body.velocity.length() * float(body.is_on_floor())
	camera.transform.origin = _head_bob(_head_bob_time)

	var _speed: float = speed_sprinting if sprinting else speed
	_speed = _speed if not crouching else speed_crouching
	if dir:
		body.velocity.x = dir.x * _speed
		body.velocity.z = dir.z * _speed
	else:
		body.velocity.x = 0
		body.velocity.z = 0
	
func _head_bob(time: float) -> Vector3:
	var headbob_position: Vector3 = Vector3.ZERO
	headbob_position.y = sin(time * headbob_frequency) * headbob_amplitude
	headbob_position.x = sin(time * headbob_frequency / 2) * headbob_amplitude

	var footstep_threshold: float = - headbob_amplitude + 0.002
	if headbob_position.y > footstep_threshold:
		_footstep_can_play = true
	elif headbob_position.y < footstep_threshold and _footstep_can_play:
		_footstep_can_play = false
		if _surface:
			play_stream(_surface.footstep_walk)
	
	return headbob_position

func play_stream(stream: AudioStream) -> void:
	if not stream:
		return
	if crouching:
		footstep_player.volume_db = -25
	else:
		footstep_player.volume_db = -20

	if footstep_player.stream != stream:
		footstep_player.stream = stream
	if not footstep_player.playing:
		footstep_player.play()
