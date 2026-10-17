class_name Player extends CharacterBody3D

@export var movement_comp: MovementComponent
@export var camera_control_comp: CameraControlComponent
@export var crouch_anim: AnimationPlayer

@export var arms_anim: AnimationPlayer
@export var head: Node3D
@export var item_placement: Node3D
@export var interaction_cast: RayCast3D
@export var crouch_cast: RayCast3D

@export var interact_progress: TextureProgressBar
@export var interact_text: Label
@export var crosshair_center: Control
@export var ambience: AudioStreamPlayer

@export var subtitles_container: VBoxContainer

var enabled: bool = true

var _since_last_animation: float = 0.0

var _current_interactable: InteractableComponent
var _interact_time: float = 0.0

func _enter_tree() -> void:
	Global.player = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _ready() -> void:
	Global.add_queue("You", "Where am I?")
	Global.add_queue("You", "I guess I'll drive forwards.")

func _physics_process(delta: float) -> void:
	if interaction_cast.is_colliding():
		if interaction_cast.get_collider() is InteractableComponent:
			var interactable: InteractableComponent = interaction_cast.get_collider()
			if interactable.enabled:
				interact_text.text = interactable.label
				interact_text.show()
				crosshair_center.show()
				if Input.is_action_pressed("interact"):
					if _current_interactable != interactable:
						_current_interactable = interactable
						interact_text.text = _current_interactable.label
						_interact_time = 0
						interact_progress.show()
						interact_text.show()
						crosshair_center.hide()
				else:
					_reset_interaction()
		else:
			_reset_interaction()
	else:
		interact_text.hide()
		crosshair_center.show()
		_reset_interaction()

	if _current_interactable:
		_interact_time += delta
		interact_progress.value = (_interact_time / _current_interactable.time_to_interact) * 100
		crosshair_center.hide()
		_current_interactable.interacting.emit(self)
		if _interact_time >= _current_interactable.time_to_interact:
			_current_interactable.interacting_stopped.emit(self)
			_current_interactable.interact(self)
			interact_text.hide()
			crosshair_center.show()
			_reset_interaction()

	if not enabled: return
	
	if Input.is_action_just_pressed("esc"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE

	if arms_anim.is_playing():
		_since_last_animation = 0
	else:
		_since_last_animation += delta
	if _since_last_animation > 0.1:
		arms_anim.play("Relax_hands_idle")
	
	if Input.is_action_just_pressed("jump"):
		movement_comp.jump()
	movement_comp.set_direction(Input.get_vector("left", "right", "forward", "backward"))
	movement_comp.sprinting = Input.is_action_pressed("sprinting")

	if Input.is_action_just_pressed("crouch"):
		if not movement_comp.crouching:
			movement_comp.crouching = true
			crouch_anim.play("crouch")
			crouch_anim.seek((1.0 - ((head.position.y - 1.0) / 0.75)) * 0.3)
			
	if not Input.is_action_pressed("crouch") and movement_comp.crouching:
		if not crouch_cast.is_colliding():
			movement_comp.crouching = false
			crouch_anim.play("uncrouch")
			crouch_anim.seek(((head.position.y - 1.0) / 0.75) * 0.3)

	movement_comp.tick(delta)

func _reset_interaction() -> void:
	if _current_interactable:
		_current_interactable.interacting_stopped.emit(self)
	_current_interactable = null
	interact_progress.hide()
	_interact_time = 0

func subtitle(person: String, text: String) -> Signal:
	var instance: Subtitle = Subtitle.create()
	subtitles_container.add_child(instance)
	instance.typewrite(person, text, Global.subtitle_colors[person])
	return instance.done
