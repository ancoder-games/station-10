extends Node

var subtitle_colors: Dictionary[String, Color] = {
	"You": Color("#c76b6b")
}
var player: Player

var subtitle_queue: Array[Dictionary] = []

func _ready() -> void:
	add_queue("You", "Hello!")

var queue_timer: float = 0.0

func add_queue(person: String, text: String) -> void:
	subtitle_queue.push_back({"person": person, "text": text})

func clear_queue() -> void:
	subtitle_queue = []

func _physics_process(delta: float) -> void:
	if queue_timer >= 0.0:
		queue_timer -= delta
	if subtitle_queue.size() == 0:
		queue_timer = 0.0
		return
	if queue_timer <= 0:
		var subtitle: Dictionary[String, String]
		var s: Dictionary = subtitle_queue.pop_front()
		subtitle.assign(s)
		player.subtitle(subtitle["person"], subtitle["text"])
		queue_timer += 2.0 + (subtitle["text"].length() * 0.1)
