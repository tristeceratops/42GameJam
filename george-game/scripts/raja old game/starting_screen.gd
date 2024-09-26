extends Control

var scene_folder_path = "res://testing stages/"
var i = 42

func _ready() -> void:
	# Call randomize to ensure proper random selection
	randomize()

func _on_button_pressed() -> void:
	print("Button Pressed!")  # Debug: Check if the button press is detected
		# Get all files in the folder
	var dir = DirAccess.open(scene_folder_path)
	if dir:
		var scenes = []
		dir.list_dir_begin()
				
		# Loop through all files in the directory
		var file_name = dir.get_next()
		print("Reading Directory:")  # Debug: See if we enter the loop
		while file_name != "" and i >= 0:
			print("Found file: ", file_name)  # Debug: Print each file found
						
						# Skip directories and hidden files
			if dir.current_is_dir() or file_name.begins_with(".") or file_name.ends_with(".tmp"):
				file_name = dir.get_next()
				continue

						# Only add .tscn files (Godot scene files)
			if file_name.ends_with(".tscn"):
				scenes.append(file_name)
				file_name = dir.get_next()
			i -= 1
				
		dir.list_dir_end()

				# If there are scenes available, load a random one
		if scenes.size() > 0:
			var random_scene_path = scene_folder_path + scenes[randi() % scenes.size()]
			print("Loading scene: ", random_scene_path)  # Debug: Check which scene is being loaded
					
					# Here, we directly use the path with change_scene_to_file
			var result = get_tree().change_scene_to_file(random_scene_path)
			if result != OK:
				print("Failed to load scene: " + random_scene_path)
		else:
			print("No scenes found in the folder!")
	else:
		print("Failed to open directory: " + scene_folder_path)
