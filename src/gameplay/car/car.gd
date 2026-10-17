extends VehicleBody3D
class_name Car

@export var player: Player
@export var door_interactable: InteractableComponent
@export var in_car_point: Node3D
@export var fuel_anim: AnimationPlayer
@export var door_sound: AudioStreamPlayer3D
@export var engine_sound_ext: AudioStreamPlayer3D
@export var engine_sound_int: AudioStreamPlayer3D
@export var drive_sound: AudioStreamPlayer3D
@export var crash_sound: AudioStreamPlayer3D

@export var stabilization_force: float = 50.0
@export var MAX_STEER: float = 0.1
@export var ENGINE_POWER: float = 100

var control: bool = true

@export var fuel: float = 1.0:
	set(value):
		if value <= 0:
			fuel = 0
			fuel_out = true
			Global.add_queue("You", "I ran out of gas.")
			Global.add_queue("You", "Hey look a gas can ahead!")
		else:
			fuel = value
			fuel_out = false

var fuel_out: bool = false

var last_velocity: Vector3 = Vector3.ZERO

func _ready() -> void:
	door_interactable.interacted.connect(_door_interacted)
	door_interactable.interacting.connect(func(_player: Player) -> void:
		_player.arms_anim.play("Collect_something")
		# await _player.arms_anim.animation_finished
		)
	door_interactable.interacting_stopped.connect(func(_player: Player) -> void:
		# _player.arms_anim.stop()
		_player.arms_anim.play_backwards("Collect_something")
		)
	body_entered.connect(_on_body_entered)

func _enter_tree() -> void:
	Global.car = self

func _physics_process(delta: float) -> void:
	last_velocity = linear_velocity
	fuel_anim.play("default")
	fuel_anim.seek(maxf(0.1, 0.9 - fuel))
	if !control:
		engine_force = ENGINE_POWER
		player.global_position = in_car_point.global_position
		return
	if player != null:
		if !fuel_out:
			brake = 0
			steering = move_toward(steering, Input.get_axis("right", "left") * MAX_STEER, delta * 10)
			var engine_input: float = Input.get_axis("backward", "forward")
			engine_force = engine_input * ENGINE_POWER
			if engine_input != 0:
				drive_sound.play()
				fuel -= 0.0125 * delta
			else:
				drive_sound.stop()
		else:
			drive_sound.stop()
			brake = 50
			engine_force = 0

		player.global_position = in_car_point.global_position
	else:
		drive_sound.stop()
		engine_force = 0
		brake = 50


	var car_up: Vector3 = global_transform.basis.y
	var world_up: Vector3 = Vector3.UP
	
	if car_up.dot(world_up) < 0.95:
		var correction_axis: Vector3 = car_up.cross(world_up).normalized()
		var tilt_angle: float = car_up.angle_to(world_up)
		apply_torque(correction_axis * tilt_angle * stabilization_force)


func _door_interacted(_player: Player) -> void:
	door_sound.play()
	if player == null:
		player = _player
		player.enabled = false
		door_interactable.label = "(E) Exit Car"
		player.global_rotation.y = in_car_point.global_rotation.y

		engine_sound_ext.stop()
		engine_sound_int.play()
		player.ambience.stream_paused = true

		# Stop Crouch
		if player.movement_comp.crouching:
			player.movement_comp.crouching = false
			player.crouch_anim.play("uncrouch")
			player.crouch_anim.seek(0.3)
	else:
		engine_sound_int.stop()
		engine_sound_ext.play()
		player.ambience.stream_paused = false
		player.enabled = true
		player = null
		door_interactable.label = "(E) Enter Car"

func _on_body_entered(_body: Node) -> void:
	var impact_strength: float = (last_velocity - linear_velocity).length()
	if impact_strength > 0.2:
		crash_sound.pitch_scale = clampf(impact_strength / 20.0, 0.8, 1.2)
		crash_sound.play()
