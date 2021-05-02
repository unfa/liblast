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

sync func dry_fire():
	pass

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
