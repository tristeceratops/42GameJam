extends Control

var label = Label
var time = Timer

func _ready():
	label = $Label
	time = $"42 second timer"
	
	time.start()

func update_lable_text():
	label.text = str(ceil(time.time_left))

func _process(delta: float) -> void:
	update_lable_text()

func _on_timeout() -> void:
	get_tree().change_scene_to_file("res://recources/death_screen.tscn")
