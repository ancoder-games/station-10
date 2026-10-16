extends AnimationPlayer

@export var fps: int = 30
var timer: float = 0

func _ready() -> void:
	callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL

func _process(delta: float) -> void:
	timer += delta
	if timer >= (1.0 / fps):
		advance(1.0 / fps)
		timer -= (1.0 / fps)
