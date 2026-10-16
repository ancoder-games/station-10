extends VehicleBody3D

@export var player: Player
@export var door_interactable: InteractableComponent
@export var in_car_point: Node3D
@export var fuel_anim: AnimationPlayer

@export var stabilization_force: float = 50.0
@export var MAX_STEER: float = 0.1
@export var ENGINE_POWER: float = 100

@export var fuel: float = 1.0:
	set(value):
		if value <= 0:
			fuel = 0
			fuel_out = true
			Global.player.subtitle("You", "I ran out of fuel!")
		else:
			fuel = value
			fuel_out = false

var fuel_out: bool = false

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

func _physics_process(delta: float) -> void:
	fuel_anim.play("default")
	fuel_anim.seek(maxf(0.1, 0.9 - fuel))
	if player != null:
		if !fuel_out:
			brake = 0
			steering = move_toward(steering, Input.get_axis("right", "left") * MAX_STEER, delta * 10)
			var engine_input: float = Input.get_axis("backward", "forward")
			engine_force = engine_input * ENGINE_POWER
			if engine_input != 0:
				fuel -= 0.025 * delta
		else:
			brake = 50
			engine_force = 0

		player.global_position = in_car_point.global_position
	else:
		engine_force = 0
		brake = 50


	var car_up: Vector3 = global_transform.basis.y
	var world_up: Vector3 = Vector3.UP
	
	if car_up.dot(world_up) < 0.95:
		var correction_axis: Vector3 = car_up.cross(world_up).normalized()
		var tilt_angle: float = car_up.angle_to(world_up)
		apply_torque(correction_axis * tilt_angle * stabilization_force)


func _door_interacted(_player: Player) -> void:
	if player == null:
		player = _player
		player.enabled = false
		door_interactable.label = "Exit Car"
		player.global_rotation.y = in_car_point.global_rotation.y

		# Stop Crouch
		if player.movement_comp.crouching:
			player.movement_comp.crouching = false
			player.crouch_anim.play("uncrouch")
			player.crouch_anim.seek(0.3)
	else:
		player.enabled = true
		player = null
		door_interactable.label = "Enter Car"
