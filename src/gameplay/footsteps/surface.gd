@tool
extends Resource
class_name Surface

@export_category("Surface Audio")
@export var footstep_walk: AudioStreamRandomizer
@export var footstep_jump: AudioStreamRandomizer
@export var footstep_sprint: AudioStreamRandomizer

@export_category("Editor Tools")
@export_dir var _footstep_walk_folder: String
@export_dir var _footstep_jump_folder: String
@export_dir var _footstep_sprint_folder: String
@export_tool_button("Load Footstep Sounds", "Callable") var load_sounds: Callable = _load_footstep_sounds

func _load_footstep_sounds() -> void:
	footstep_walk = AudioStreamRandomizer.new()
	footstep_jump = AudioStreamRandomizer.new()
	footstep_sprint = AudioStreamRandomizer.new()

	var walk_files: Array = DirAccess.open(_footstep_walk_folder).get_files()
	for file_name: String in walk_files:
		if file_name.get_extension().to_lower() != "ogg":
			continue
		var stream: AudioStreamOggVorbis = load(_footstep_walk_folder + "/" + file_name)
		if stream:
			footstep_walk.add_stream(0, stream)

	var jump_files: Array = DirAccess.open(_footstep_jump_folder).get_files()
	for file_name: String in jump_files:
		if file_name.get_extension().to_lower() != "ogg":
			continue
		var stream: AudioStreamOggVorbis = load(_footstep_jump_folder + "/" + file_name)
		if stream:
			footstep_jump.add_stream(0, stream)

	var sprint_files: Array = DirAccess.open(_footstep_sprint_folder).get_files()
	for file_name: String in sprint_files:
		if file_name.get_extension().to_lower() != "ogg":
			continue
		var stream: AudioStreamOggVorbis = load(_footstep_sprint_folder + "/" + file_name)
		if stream:
			footstep_sprint.add_stream(0, stream)
