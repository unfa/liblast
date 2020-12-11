extends "res://Player.gd"

func _ready():
	if name == String(get_tree().get_network_unique_id()):
		return
		#$Throne/Cube.cast_shadow = 3
