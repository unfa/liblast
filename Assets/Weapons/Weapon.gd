extends Spatial

export(bool) var Hitscan = false
export(int) var Damage = 100
export(float) var Delay = 0.1
export(bool) var Automatic = false
export(int) var Rounds = 10
export(int) var MaxRoundsInClip = 10
export(int) var Clips = 1
export(int) var MaxClips = 4


onready var camera = get_parent().get_parent()
onready var player = get_parent().get_parent().get_parent()

onready var ejector = find_node("Ejector")
onready var muzzle = find_node("Muzzle")

#onready var sound_shoot = $SoundShoot

var casing = preload("res://Assets/Weapons/Handgun/Casing.tscn")
var tracer = preload("res://Assets/Effects/BulletTracer.tscn")

func shoot():
	rpc("show_muzzle_flash")
	rpc("show_tracer")
	rpc("spawn_casing")
	rpc("compute_bullet_flyby")


sync func show_muzzle_flash():
	$Handgun/AnimationPlayer.stop()
	$Handgun/AnimationPlayer.play("Shoot", -1, 2)
	$SoundShoot.play()
	
	$MuzzleFlash.emitting = true
	
	yield(get_tree().create_timer(0.07),"timeout")
	
	$MuzzleFlash.emitting = false

sync func show_tracer():
	var tracer_instance = tracer.instance()
	tracer_instance.hide()
	tracer_instance.global_transform = muzzle.global_transform
	
	get_tree().root.call_deferred("add_child", tracer_instance)
	tracer_instance.call_deferred("show")

sync func spawn_casing():
	var casing_instance = casing.instance()
	casing_instance.global_transform = ejector.global_transform
	
	casing_instance.rotate_object_local(Vector3.FORWARD, deg2rad(90))

	casing_instance.angular_velocity = - ejector.global_transform.basis[2] * rand_range(23, 37)
	casing_instance.linear_velocity = ejector.global_transform.basis[0] * rand_range(3.2, 4.5) - ejector.global_transform.basis[2] * rand_range(2.6, 3.7)
	
	get_tree().root.call_deferred("add_child", casing_instance)

remote func compute_bullet_flyby():
	var local_player = get_tree().root.get_node("Game").local_player
	var transform = find_node("Muzzle").global_transform
	
	var from = transform.xform(Vector3())
	var to = transform.xform(Vector3(-1000, 0, 0))
	
	local_player.on_bullet_flyby(from, to)
