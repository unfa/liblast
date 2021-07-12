extends "res://Menu.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func toggle_fullscreen(button_pressed):
	if button_pressed:
		get_tree().get_root().mode = Window.MODE_FULLSCREEN
	else:
		get_tree().get_root().mode = Window.MODE_WINDOWED
