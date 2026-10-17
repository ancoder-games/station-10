extends Area3D

var enabled: bool = true
@export var anim: AnimationPlayer

func _ready() -> void:
	collision_mask = 2
	body_entered.connect(_body_entered)

func _body_entered(body: Node) -> void:
	if not enabled: return
	if body is Player:
		enabled = false
	Global.car.global_rotation_degrees = Vector3(0, 90, 0)
	Global.car.control = false
	await get_tree().create_timer(2).timeout
	anim.play("game_over")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
