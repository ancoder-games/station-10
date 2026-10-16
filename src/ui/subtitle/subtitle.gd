class_name Subtitle extends HBoxContainer

@onready var name_label: Label = %Name
@onready var text_label: Label = %Text
@onready var anim: AnimationPlayer = %Anim

@export var type_delay: float = 0.1
@export var live_time: float = 4.0

const SCENE: PackedScene = preload("uid://b2ob1pr5hrlos")

signal done

func _ready() -> void:
	name_label.label_settings = name_label.label_settings.duplicate()

static func create() -> Subtitle:
	return SCENE.instantiate()

func typewrite(person: String, text: String, color: Color) -> void:
	name_label.text = person + ":"
	name_label.label_settings.font_color = color
	text_label.text = text
	anim.play("RESET")
	text_label.visible_characters = 0
	for _i: int in text_label.text.length():
		await get_tree().create_timer(type_delay).timeout
		text_label.visible_characters += 1
	done.emit()
	await get_tree().create_timer(live_time).timeout
	anim.play("fade_out")
	await anim.animation_finished
	queue_free.call_deferred()
