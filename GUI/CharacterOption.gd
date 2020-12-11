extends Control

func set_character(packed_character):
	var character = packed_character.instance()
	character.show_healthbar = false
	
	$Viewport.add_child(character)

func _process(delta):
	$Viewport.size = rect_size

