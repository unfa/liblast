extends Spatial

var casing = preload("res://Assets/Weapons/Handgun/Casing.tscn")
var tracer = preload("res://Assets/Effects/BulletTracer.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

remote func shoot():
	var casing_instance = casing.instance()
	casing_instance.global_transform = find_node("Ejector").global_transform
	
	casing_instance.rotate_y(deg2rad(90))
	casing_instance.angular_velocity = Vector3(rand_range(0, 40), 0, 0)
	casing_instance.linear_velocity = Vector3(rand_range(0, 1), 5, 0)
	
	get_tree().root.call_deferred("add_child", casing_instance)
	
	var tracer_instance = tracer.instance()
	tracer_instance.global_transform = find_node("Muzzle").global_transform
	
	get_tree().root.call_deferred("add_child", tracer_instance)
	
	#tracer_instance.rotate_object_local(Vector3.AXIS_Y, PI/4)
	#tracer_instance.angular_velocity = Vector3(rand_range(0, 40), 0, 0)
	#tracer_instance.linear_velocity = Vector3(rand_range(0, 1), 5, 0)
	
	
	# TODO - fix casing rotation
	# TODO - apply initial linear and angular velocity	
	
	
	
	$Handgun/AnimationPlayer.stop()
	$Handgun/AnimationPlayer.play("Shoot", -1, 2)
	
	$SoundShoot.play()
	
	
