extends "res://Classes/Weapon/Weapon.gd"

func set_trigger_held_primary(active:bool):
	trigger_held_primary = active
	
	if active:
		shoot(camera)
	print("trigger_active", active)

func shoot(camera):
	if is_reloading:
		return
	
	if currently_fireing == true:
		cached_fire = true
		yield($Model/AnimationPlayer, "animation_finished")
	
	# TODO: mutexes
	currently_fireing = true
	cached_fire = false
	
	if current_rounds > 0:
		rpc("fire_weapon", current_rounds)
		rpc("compute_bullet_flyby")
		
		current_rounds -= 1
		
		var space_state = get_world().direct_space_state
		
		var crosshair_pos = get_viewport().size / 2
		
		var from = camera.project_ray_origin(crosshair_pos)
		var to = from + camera.project_ray_normal(crosshair_pos) * 1000
	
		var result = space_state.intersect_ray(from, to)
		
		if "collider" in result:
			var hit = result.collider
			
			if hit.has_method("on_hit"):
				hit.rpc("on_hit", 30, result.position, player.name)
			
			if hit is Player:
				var kill = true if hit.health <= 0 else false
				
				#print ("Player: kill = ", kill, " Target health: ", hit.health)
				emit_signal("damage_dealt", kill)
				
				#print(get_signal_connection_list("damage_dealt")[0]["target"].name)
				
				if kill:
					player.score(hit.name)
		
		#print(get_signal_connection_list("ammo_changed")[0]["target"].name)
		emit_signal("ammo_changed", self)
	
	if current_rounds == 0:
		reload()
	
	return current_rounds

sync func fire_weapon(var rounds_left):
	show_muzzle_flash(rounds_left)
	show_tracer()
	spawn_casing()
	yield($Model/AnimationPlayer, "animation_finished")
	
	if !cached_fire:
		currently_fireing = false

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

remote func compute_bullet_flyby():
	var local_player = get_tree().root.get_node("Game").local_player
	var transform = find_node("Muzzle").global_transform
	
	var from = global_transform.xform(Vector3())
	var to = global_transform.xform(Vector3(-1000, 0, 0))
	
	if local_player:
		local_player.on_bullet_flyby(from, to)

