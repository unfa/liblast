extends "res://Classes/Player/Player.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	if name == String(get_tree().get_network_unique_id()):
		$SmartFridge/Cube.cast_shadow = 3
		$SmartFridge/Cube001.cast_shadow = 3
