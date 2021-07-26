extends Node3D
					#Hand		Camera			Head		Player
@onready var player = get_parent().get_parent().get_parent().get_parent()
@onready var ejector = find_node("Ejector")
@onready var muzzle = find_node("Muzzle")

var casing = preload("res://Assets/Weapons/Handgun/Casing.tscn")
var flash = preload("res://Assets/Weapons/Handgun/Flash.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#enum Trigger {TRIGGER_PRIMARY, TRIGGER_SECONDARY}

@puppetsync func trigger(index: int, active: bool) -> void:
	#print("Weapon " + str(name) + ", Trigger " + str(index) + ", active: " + str(active))
	
	if index == 0 and active:
		
		$Handgun/AnimationPlayer.play("Shoot", 0, 2.5)
		
		var flash_effect
		if flash.has_method(&"instance"):
			flash_effect = flash.instance()
		else:
			flash_effect = flash.instantiate()
			
		get_parent().add_child(flash_effect)
		flash_effect.global_transform = muzzle.global_transform
		
		var casing_instance
		if casing.has_method(&"instance"):
			casing_instance = casing.instance()
		else:
			casing_instance = casing.instantiate()
		
		get_tree().root.add_child(casing_instance)

		casing_instance.global_transform = ejector.global_transform.translated(player.linear_velocity / 30) #approximating delta
		#casing_instance.rotate_object_local(Vector3.FORWARD, deg2rad(90))
		#casing_instance.angular_velocity = - ejector.global_transform.basis[2] * randf_range(13, 17)
		casing_instance.linear_velocity = ejector.global_transform.basis[0] * randf_range(6.2, 8.5)# - ejector.global_transform.basis[2] * randf_range(-1.2, -1.7) + player.linear_velocity
	


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
