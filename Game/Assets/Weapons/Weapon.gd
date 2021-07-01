extends Node3D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#enum Trigger {TRIGGER_PRIMARY, TRIGGER_SECONDARY}

@remotesync func trigger(index: int, active: bool) -> void:
	print("Weapon " + str(name) + ", Trigger " + str(index) + ", active: " + str(active))
	
	if index == 0 and active:
		$Flash/AnimationPlayer.play("Flash")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
