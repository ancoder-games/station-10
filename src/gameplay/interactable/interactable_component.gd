class_name InteractableComponent extends Area3D

signal interacted(player: Player)
signal interacting(player: Player)
signal interacting_stopped(player: Player)

@export var enabled: bool = true
@export var time_to_interact: float = 0.5
@export var label: String = "Interact"

func interact(player: Player) -> void:
	if enabled:
		interacted.emit(player)

func never() -> void:
	interacting.emit()
	interacting_stopped.emit()