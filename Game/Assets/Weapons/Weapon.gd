extends Node3D

@onready var ejector = find_node("Ejector")
@onready var muzzle = find_node("Muzzle")

var casing = preload("res://Assets/Weapons/Handgun/Casing.tscn")
var flash = preload("res://Assets/Weapons/Handgun/Flash.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#enum Trigger {TRIGGER_PRIMARY, TRIGGER_SECONDARY}

@puppetsync func trigger(index: int, active: bool) -> void:
	print("Weapon " + str(name) + ", Trigger " + str(index) + ", active: " + str(active))
	
	if index == 0 and active:
		
		$Handgun/AnimationPlayer.play("Shoot", 0, 2.5)
		
		var flash_effect
		if flash.has_method(&"instance"):
			flash_effect = flash.instance()
		else:
			flash_effect = flash.instantiate()
			
		get_parent().add_child(flash_effect)
		flash_effect.global_transform = muzzle.global_transform

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
