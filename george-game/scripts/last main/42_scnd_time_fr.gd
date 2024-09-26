extends Control

@onready var label = Label
@onready var time = Timer

func _ready():
	label = $Label
	time = $"42 second timer"

func update_lable_text():
	label.text = str(ceil(time.time_left))

func _process(delta: float) -> void:
	update_lable_text()

func _on__second_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://recources/death_screen.tscn")
