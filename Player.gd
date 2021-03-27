extends KinematicBody

const GRAVITY = Vector3.DOWN * 9.8 * 1.5
const JUMP_VELOCITY = 9
const WALK_VELOCITY = 8

const AIR_CONTROL = 0.1

const WALK_ACCEL = 5
const WALK_DECEL = 0.1

const MOUSE_SENSITIVITY = 1.0 / 1000

export var show_healthbar = true
export var max_health = 150
onready var health = max_health setget set_health

onready var camera = $Camera
onready var debug = $Debug

onready var weapon_bob_anim = $Camera/Hand/WeaponBobAnimationTree["parameters/playback"]

var is_dead = true
var was_on_floor = false

const JETPACK_FUEL_MAX = 1
const JETPACK_REFILL_RATE = 1/5
const JETPACK_THRUST = 1500

var jetpack_active = false # is the jetpack active?
var jetpack_fuel = JETPACK_FUEL_MAX # max fuel (in seconds)

#onready var sfx_foosteps = [$"Sounds/Footstep-Concrete-01",
#							$"Sounds/Footstep-Concrete-02",
#							$"Sounds/Footstep-Concrete-03",
#							$"Sounds/Footstep-Concrete-04"]	

#var sfx_footsteps_last = 0
#var sfx_footsteps_next = 0
#var sfx_footsteps_delay = 0.2
#var sfx_footsteps_play = false

onready var game = get_parent().get_parent()

var velocity = Vector3.ZERO
var walk_direction = Vector2.ZERO
var walkDirInt = Vector2.ZERO

#var bulletHitEffect = preload("res://Assets/Effects/BulletHit.tscn")
var bodyHitEffect = preload("res://Assets/Effects/BodyHit.tscn")
onready var nickname = "guest" setget set_nickname
var player_class = "none"

#func sfx_play_footsteps():
#	if not sfx_footsteps_play:
#		sfx_footsteps_play = true
#		while sfx_footsteps_next == sfx_footsteps_last:
#			sfx_footsteps_next = randi() % len(sfx_foosteps)
#		sfx_footsteps_last = sfx_footsteps_next
#		print("Play footstep: ", String(sfx_footsteps_next) )
#		sfx_foosteps[sfx_footsteps_next].play()
#		yield(get_tree().create_timer(sfx_footsteps_delay),"timeout")
#		sfx_footsteps_play = false

func set_health(value):
	health = value
	$HUD.updateHealth(value)
	$Billboard.rpc("set_health", value)
	#$Billboard.set_health(value)

func set_nickname(_nickname):
	$Billboard.set_nickname(_nickname)
	nickname = _nickname

remote func set_player_data(player):
	nickname = player.nickname

func get_closest_point(_A: Vector3, _B: Vector3):
	var A = transform.inverse().xform(_A)
	var B = transform.inverse().xform(_B)
	
	var diff = B - A
	var result = A - (A.dot(diff) * diff) / (diff.length_squared())
	return transform.xform(result)

func on_bullet_flyby(from, to):
	var closest_point = get_closest_point(from, to)
	
	var flyby_noise = preload("res://Audio/BulletFlyBySoundPlayer.tscn").instance()
	flyby_noise.translation = closest_point
	
	get_tree().root.call_deferred("add_child", flyby_noise)

remote func jump():
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
		$Sounds/Jump.play()
		weapon_bob_anim.travel("Jump")

remote func mouselook_abs(x, y):
	camera.rotation.x = x
	rotation.y = y

remote func mouselook(rel):
	var sensitivity = MOUSE_SENSITIVITY * game.mouse_sensitivity_multiplier
	rotate_y(- rel.x * sensitivity)
	camera.rotation.x = clamp(camera.rotation.x-rel.y * sensitivity, -PI/2, PI/2)
	
	rpc_unreliable("mouselook_abs", camera.rotation.x, rotation.y)

func _physics_process(delta):
	if is_dead:
		return
	
	if str(get_tree().get_network_unique_id()) != name:
		return
	
	walk(delta)
	fall(delta)
	
	
	var movement_vector = Vector3()
	if Input.is_action_just_pressed("MoveJump"):
		movement_vector = move_and_slide(velocity, Vector3.UP)
	else:
		var upvector = Vector3.UP
		
		if is_on_floor():
			upvector = get_floor_normal()
		
		movement_vector = move_and_slide_with_snap(velocity, Vector3.DOWN, upvector, true)
	velocity = movement_vector
	
	rset("translation", translation)

func walk(delta):
	# Walk
	walk_direction = Vector2()
	
	if Input.is_action_pressed("MoveForward"):
		walk_direction.y -= 1
	if Input.is_action_pressed("MoveBack"):
		walk_direction.y += 1
	if Input.is_action_pressed("MoveLeft"):
		walk_direction.x -= 1
	if Input.is_action_pressed("MoveRight"):
		walk_direction.x += 1
	
	walk_direction = walk_direction.normalized()
	
	var walking_speed = Vector2(velocity.x, velocity.z)
	
	walking_speed = walking_speed.rotated(rotation.y)
	walking_speed = lerp(walking_speed, walk_direction * WALK_VELOCITY, delta * WALK_ACCEL)
	walking_speed = walking_speed.rotated(-rotation.y)
	
	velocity.x = walking_speed.x
	velocity.z = walking_speed.y
	
	if walking_speed.length() > 0 and is_on_floor():
		weapon_bob_anim.travel("Walk")
	elif walking_speed.length() == 0 and is_on_floor():
		weapon_bob_anim.travel("Idle")


func fall(delta):
	if is_on_floor():
		velocity -= delta * get_floor_normal() * 20
		
		# If this is the first frame of ground contact after a frame of no
		# ground contact - we've just ended a fall.
		if not was_on_floor:
			weapon_bob_anim.travel("Land")
		
	else:
		velocity += delta * GRAVITY
	
	was_on_floor = is_on_floor()
	

master func on_hit(damage, location):
	set_health(health - 30)
	
	rpc("blood_splatter", location)
	
	if health <= 0:
		rpc("kill")
	else:
		$Sounds/Pain.rpc("play")

sync func blood_splatter(location):
	var effect = bodyHitEffect.instance()
	get_tree().root.add_child(effect)
	effect.global_transform.origin = location

master func kill():
	if is_dead:
		return
	
	$Sounds/Death.rpc("play")
	
	#print ("kill")
	is_dead = true
	
	
	#print ("set as dead")
		
	set_health(0)
	#print ("health:", health)
	
	$CollisionShapeBody.disabled = true
	
	$Camera/Hand.hide()
	#$HUD.update_crosshair(false, false)
	
	yield(get_tree().create_timer(3), "timeout")
	
	spawn()
	
	yield(get_tree().create_timer(3), "timeout")
	
#	for i in gibs.get_children():
#		i.queue_free()
#		yield(get_tree().create_timer(rand_range(0.1, 1)), "timeout")
	
#	gibs.queue_free()

func spawn():
	is_dead = false
	set_health(150)
	
	velocity = Vector3()
	
	game.get_spawn_point().spawn(self)
	
	$Camera/Hand.show()
	$HUD.show()
	
	$CollisionShapeBody.disabled = false
	
	$Camera.rotation = Vector3.ZERO
	rotation = Vector3.ZERO

func shoot():
	var weapon = find_node("Weapon")
	
	var remaining_ammo = weapon.shoot($Camera)

func reload():
	var weapon = find_node("Weapon")
	
	weapon.reload()

func _input(event):
	if is_dead:
		return
	
	if str(get_tree().get_network_unique_id()) != name:
		return
	
	if game.GAME_MODE != "PLAYING":
		return
	
	# Moouselook
	if event is InputEventMouseMotion:
		var rel = event.relative
		
		mouselook(rel)
	# Jump
	
	if event.is_action_pressed("MoveJump"):
		rpc("jump")
		jump()
	
	if event.is_action_pressed("MoveJetpack"):
		jetpack_active = true
	else:
		jetpack_active = false
		
	if event.is_action_pressed("WeaponPrimary"):
		shoot()
	if event.is_action_pressed("WeaponReload"):
		reload()
		

func set_local_player():
	set_network_master(get_tree().get_network_unique_id())
	camera.current = true
	#$HUD.show()
	$Billboard.hide()

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set player class
	var path = get_script().get_path()
	
	if path.find("res://Assets/Characters/") != -1:
		player_class = path.replace("res://Assets/Characters/", "").split("/")[0]
	
	set_health(max_health)
	# disabled the ragdoll collider
	#for i in $Player/Gibs.get_children():
	#	i.get_child(1).disabled = true
		#disabled = true
		#$"Player/Gibs/PlayerGibs _cell /shape0".set_disabled(true)
	
	rset_config("translation", MultiplayerAPI.RPC_MODE_SYNC)
	if !show_healthbar:
		$Billboard.hide()
	
	# only show the debug label on local machine
	if name != String(get_tree().get_network_unique_id()):
		debug.hide()
	
	# initialize sound looping
	
	#$Sounds/Jetpack.stream.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
