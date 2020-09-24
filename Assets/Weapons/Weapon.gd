extends Spatial

export(bool) var Hitscan = false
export(int) var Damage = 100

onready var camera = get_parent().get_parent()

onready var player = get_parent().get_parent().get_parent()

onready var ejector = find_node("Ejector")

onready var sound_shoot = $SoundShoot

var casing = preload("res://Assets/Weapons/Handgun/Casing.tscn")
var tracer = preload("res://Assets/Effects/BulletTracer.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	sound_shoot.global_transform = camera.get_global_transform()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

remote func shoot():
	
	#print ("Camera location: ", camera.global_transform.origin)
		
	var tracer_instance = tracer.instance()
	tracer_instance.hide()
	tracer_instance.global_transform = find_node("Muzzle").global_transform
	
	get_tree().root.call_deferred("add_child", tracer_instance)
	tracer_instance.call_deferred("show")
	
	$Handgun/AnimationPlayer.stop()
	$Handgun/AnimationPlayer.play("Shoot", -1, 2)
	
	$SoundShoot.play()
	
	$MuzzleFlash.emitting = true
	
	yield(get_tree().create_timer(0.05),"timeout")
	
	var casing_instance = casing.instance()
	casing_instance.global_transform = ejector.global_transform
	
	casing_instance.rotate_object_local(Vector3.FORWARD, deg2rad(90))

	casing_instance.angular_velocity = - ejector.global_transform.basis[2] * rand_range(23, 37)
	casing_instance.linear_velocity = ejector.global_transform.basis[0] * rand_range(3.2, 4.5) - ejector.global_transform.basis[2] * rand_range(2.6, 3.7)
	
	
	get_tree().root.call_deferred("add_child", casing_instance)
	
	yield(get_tree().create_timer(0.05),"timeout")

	$MuzzleFlash.emitting = false
	

