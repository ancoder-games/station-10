extends Node3D

@export var interactable: InteractableComponent
@export var trigger: Area3D

var triggered: bool = false

func _ready() -> void:
	interactable.interacted.connect(_interacted)
	interactable.interacting.connect(func(_player: Player) -> void:
		_player.arms_anim.play("Collect_something")
		# await _player.arms_anim.animation_finished
		)
	interactable.interacting_stopped.connect(func(_player: Player) -> void:
		# _player.arms_anim.stop()
		_player.arms_anim.play_backwards("Collect_something")
		)

	trigger.body_entered.connect(_trigger)

func _trigger(body: Node) -> void:
	if body is Player:
		triggered = true

func _process(_delta: float) -> void:
	if triggered: return
	if Global.car.fuel <= 0.05:
		Global.car.fuel = 0.05

func _interacted(_player: Player) -> void:
	interactable.enabled = false
	hide()
	Global.car.fuel = 1
	Global.add_queue("You", "That should be enough gas.")
	Global.add_queue("You", "I should go back to the car now.")
