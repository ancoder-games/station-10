extends Area3D

@export var anim: AnimationPlayer
@export var dialog_enabled: bool = false
@export var dialog: String = ""
@export var dialog_delay: int = 0

var enabled: bool = true

func _ready() -> void:
	collision_mask = 2
	body_entered.connect(_body_entered)

func _body_entered(body: Node) -> void:
	if not enabled: return
	if body is Player:
		enabled = false
		if anim:
			anim.play("triggered")
		if dialog_enabled:
			await get_tree().create_timer(dialog_delay).timeout
			Global.player.subtitle("You", dialog)