extends Spatial

signal damage_dealt(kill)
signal ammo_changed(weapon)

export(bool) var Hitscan = true
export(int) var Damage = 100
export(float) var Delay = 0.1
export(bool) var Automatic = false
export(int) var Rounds = 10

onready var camera = get_parent().get_parent().get_parent()
onready var player = camera.get_parent()

onready var ejector = find_node("Ejector")
onready var muzzle = find_node("Muzzle")

onready var current_rounds = Rounds

var currently_fireing = false
var cached_fire = false

#onready var sound_shoot = $SoundShoot

var casing = preload("res://Assets/Weapons/Handgun/Casing.tscn")
var tracer = preload("res://Assets/Effects/BulletTracer.tscn")

var trigger_held_primary = false setget set_trigger_held_primary, get_trigger_held_primary
var trigger_held_secondary = false
var is_reloading = false
#var is_active = false #TODO - for reimplementing weapins switching

func set_trigger_held_primary(active:bool):
	trigger_held_primary = active

func get_trigger_held_primary():
	return trigger_held_primary

func _ready():
	$Sounds.global_transform.origin = camera.global_transform.origin

func switched_to_weapon():
	emit_signal("ammo_changed", self)

sync func fire_weapon(var rounds_left):
	show_muzzle_flash(rounds_left)
	show_tracer()
	spawn_casing()
	yield($Model/AnimationPlayer, "animation_finished")
	
	if !cached_fire:
		currently_fireing = false

sync func dry_fire():
	pass

func show_muzzle_flash(var rounds_left):
	$Model/AnimationPlayer.stop()
	
	if rounds_left == 1:
		$Model/AnimationPlayer.play("Empty", -1, 2)
	else:
		$Model/AnimationPlayer.play("Shoot", -1, 2)
	
	$Effects/Flash.stop(true)
	$Effects/Flash.play("Flash")
	
	$Effects/MuzzleFlash.emitting = true
	yield(get_tree().create_timer(0.07),"timeout")
	$Effects/MuzzleFlash.emitting = false
	
	$Sounds/Shoot.play()

func show_tracer():
	var tracer_instance = tracer.instance()
	tracer_instance.hide()
	tracer_instance.global_transform = global_transform
	tracer_instance.translation = $Model/Muzzle.global_transform.origin

	get_tree().root.call_deferred("add_child", tracer_instance)
	tracer_instance.call_deferred("show")

func spawn_casing():
	#while [ true ]:
		#var casing_instance = load("res://Assets/Weapons/Handgun/Casing.tscn").instance()
	var casing_instance = casing.instance()
	casing_instance.global_transform = ejector.global_transform
	
	casing_instance.rotate_object_local(Vector3.FORWARD, deg2rad(90))

	casing_instance.angular_velocity = - ejector.global_transform.basis[2] * rand_range(23, 37)
	casing_instance.linear_velocity = ejector.global_transform.basis[0] * rand_range(3.2, 4.5) - ejector.global_transform.basis[2] * rand_range(2.6, 3.7)
	
	get_tree().root.call_deferred("add_child", casing_instance)
	
		#yield(get_tree().create_timer(1),"timeout")
	

remote func compute_bullet_flyby():
	var local_player = get_tree().root.get_node("Game").local_player
	var transform = find_node("Muzzle").global_transform
	
	var from = global_transform.xform(Vector3())
	var to = global_transform.xform(Vector3(-1000, 0, 0))
	
	if local_player:
		local_player.on_bullet_flyby(from, to)

func reload():
	rpc("play_reload_animation")
	
	is_reloading = true
	cached_fire = false
	
	yield($Model/AnimationPlayer, "animation_finished")
	
	#if not cached_fire:
	currently_fireing = false
	is_reloading = false
	current_rounds = Rounds
	
	emit_signal("ammo_changed", self)
	
func reset():
	currently_fireing = false
	current_rounds = Rounds
	emit_signal("ammo_changed", self)

sync func play_reload_animation():
	$Model/AnimationPlayer.play("Reload", 0.5, 1)
	$Sounds/Reload.play()
