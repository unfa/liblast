extends "res://Player.gd"

func _ready():
	if name == String(get_tree().get_network_unique_id()):
		print("SELF")
		#$Throne/Cube.cast_shadow = 3
