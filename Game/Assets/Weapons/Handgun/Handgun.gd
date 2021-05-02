extends "res://Classes/Weapon/Weapon.gd"

func set_trigger_held_primary(active:bool):
	trigger_held_primary = active
	
	if active:
		shoot(camera, true)
	print("trigger_active", active)

func shoot(camera, primary):
	if not Automatic:
		if cached_fire == true:
			return
	
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
