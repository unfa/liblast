extends "res://Classes/Weapon/Weapon.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#var trigger_held_primary = false
#var trigger_held_secondary = false
#var is_reloading = false

func set_trigger_held_primary(active:bool):
	trigger_held_primary = active
	print("trigger_active", active)

#func get_trigger_held_primary():
#	return trigger_held_primary
#	print("trigger_get")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
