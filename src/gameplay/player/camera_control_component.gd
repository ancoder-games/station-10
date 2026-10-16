class_name CameraControlComponent extends Node

@export var enabled: bool = true

@export_category("Axis Controls")
## Which node should moving the mouse horizontally rotate?
@export var x_axis_control: Node3D
## Which node should moving the mouse vertically rotate?
@export var y_axis_control: Node3D
@export_category("Settings")
@export var mouse_sensitivity: float = 0.002

func _unhandled_input(e: InputEvent) -> void:
	if not _should_run(): return
	if e is InputEventMouseMotion:
		var event: InputEventMouseMotion = e
		x_axis_control.rotate_y(-event.relative.x * mouse_sensitivity)
		y_axis_control.rotate_x(-event.relative.y * mouse_sensitivity)

		# Clamp vertical movement
		y_axis_control.rotation.x = clamp(y_axis_control.rotation.x, -1.2, 1.2)

func _should_run() -> bool:
	return Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and enabled and x_axis_control and y_axis_control