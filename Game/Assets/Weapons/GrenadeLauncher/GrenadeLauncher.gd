extends "res://Classes/Weapon/Weapon.gd"

var grenade = preload("res://Assets/Weapons/GrenadeLauncher/Grenade.tscn")

func set_trigger_held_primary(active:bool):
	trigger_held_primary = active
	
	if active:
		shoot(camera)

func shoot(camera):
	if is_reloading:
		return
	
	if currently_fireing == true:
		cached_fire = true
		yield($Model/AnimationPlayer, "animation_finished")
	
	rpc("fire_weapon")

sync func fire_weapon():
	var grenade_instance = grenade.instance()
	var muzzle_transform = $Model/Muzzle.global_transform
	grenade_instance.global_transform = muzzle_transform
	
	grenade_instance.linear_velocity = muzzle_transform.basis.y * 20 + player.velocity
	
	get_tree().root.call_deferred("add_child", grenade_instance)
