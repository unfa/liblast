extends Spatial

signal damage_dealt
signal ammo_changed(type, amount)

export(bool) var Hitscan = false
export(int) var Damage = 100
export(float) var Delay = 0.1
export(bool) var Automatic = false
export(int) var Rounds = 10
export(int) var MaxRoundsInClip = 10
export(int) var Clips = 1
export(int) var MaxClips = 4

onready var player = get_parent().get_parent().get_parent()

onready var ejector = find_node("Ejector")
onready var muzzle = find_node("Muzzle")

onready var current_rounds = Rounds

var currently_fireing = false
var cached_fire = false

#onready var sound_shoot = $SoundShoot

var casing = preload("res://Assets/Weapons/Handgun/Casing.tscn")
var tracer = preload("res://Assets/Effects/BulletTracer.tscn")

func _ready():
	$Sounds.global_transform.origin = get_parent().get_parent().global_transform.origin

func shoot(camera):
	if cached_fire == true:
		return
	
	if currently_fireing == true:
		cached_fire = true
		yield($Handgun/AnimationPlayer, "animation_finished")
	
	# TODO: mutexes
	currently_fireing = true
	cached_fire = false
	
	if current_rounds > 0:
		rpc("fire_weapon", current_rounds)
		rpc("compute_bullet_flyby")
		
		current_rounds -= 1
		emit_signal("ammo_changed", "handgun", current_rounds)
		
		var space_state = get_world().direct_space_state
		
		var crosshair_pos = get_viewport().size / 2
		
		var from = camera.project_ray_origin(crosshair_pos)
		var to = from + camera.project_ray_normal(crosshair_pos) * 1000
	
		var result = space_state.intersect_ray(from, to)
		
		if "collider" in result:
			var hit = result.collider
					
			if hit.has_method("on_hit"):
				hit.rpc("on_hit", 30, result.position)
			
			if hit is Player:
				emit_signal("damage_dealt")
				print(player.get_network_master())
	else:
		reload()
	
	return current_rounds

sync func fire_weapon(var rounds_left):
	show_muzzle_flash(rounds_left)
	show_tracer()
	spawn_casing()
	yield($Handgun/AnimationPlayer, "animation_finished")
	
	if !cached_fire:
		currently_fireing = false

sync func dry_fire():
	pass

func show_muzzle_flash(var rounds_left):
	$Handgun/AnimationPlayer.stop()
	
	if rounds_left == 1:
		$Handgun/AnimationPlayer.play("Empty", -1, 2)
	else:
		$Handgun/AnimationPlayer.play("Shoot", -1, 2)
	
	$MuzzleFlash.emitting = true
	yield(get_tree().create_timer(0.07),"timeout")
	$MuzzleFlash.emitting = false
	
	$Sounds/SoundShoot.play()

func show_tracer():
	var tracer_instance = tracer.instance()
	tracer_instance.hide()
	tracer_instance.global_transform = muzzle.global_transform
	
	get_tree().root.call_deferred("add_child", tracer_instance)
	tracer_instance.call_deferred("show")

func spawn_casing():
	var casing_instance = casing.instance()
	casing_instance.global_transform = ejector.global_transform
	
	casing_instance.rotate_object_local(Vector3.FORWARD, deg2rad(90))

	casing_instance.angular_velocity = - ejector.global_transform.basis[2] * rand_range(23, 37)
	casing_instance.linear_velocity = ejector.global_transform.basis[0] * rand_range(3.2, 4.5) - ejector.global_transform.basis[2] * rand_range(2.6, 3.7)
	
	get_tree().root.call_deferred("add_child", casing_instance)

remote func compute_bullet_flyby():
	var local_player = get_tree().root.get_node("Game").local_player
	var transform = find_node("Muzzle").global_transform
	
	var from = global_transform.xform(Vector3())
	var to = global_transform.xform(Vector3(-1000, 0, 0))
	
	if local_player:
		local_player.on_bullet_flyby(from, to)

func reload():
	rpc("play_reload_animation")
	
	currently_fireing = true
	cached_fire = false
	
	yield($Handgun/AnimationPlayer, "animation_finished")
	
	if not cached_fire:
		currently_fireing = false
	
	current_rounds = Rounds
	
	emit_signal("ammo_changed", "handgun", current_rounds)

sync func play_reload_animation():
	$Handgun/AnimationPlayer.play("Reload", 0.5, 1)
	$Sounds/SoundReload.play()
