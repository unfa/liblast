class_name Player
extends KinematicBody

const GRAVITY = Vector3.DOWN * 9.8 * 1.5
const JUMP_VELOCITY = 8
const WALK_VELOCITY = 8

const AIR_CONTROL = 0.1

const JUMP_ACCEL = 1
const WALK_ACCEL = 5
#const WALK_DECEL = 0.1

const MOUSE_SENSITIVITY = 1.0 / 1000

export var show_healthbar = true
export var max_health = 150
onready var health = max_health setget set_health

onready var camera = $Camera
onready var debug = $Debug

onready var weapon_bob_anim = $Camera/Hand/WeaponBobAnimationTree["parameters/playback"]

var is_dead = true
var is_on_floor = false
var jump_timeout = 0.0
var floor_normal = Vector3.UP
var was_on_floor = false

const JETPACK_FUEL_MAX = 0.6
const JETPACK_REFILL_RATE = 0.2
const JETPACK_THRUST = 25

var jetpack_active = false # is the jetpack active?
var jetpack_used = false # Is the jetpack recharging?
var jetpack_fuel = JETPACK_FUEL_MAX # max fuel (in seconds)

onready var weapons = $Camera/Hand/Weapons
onready var active_weapon = weapons.switch_to_weapon(0)

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
	
	var flyby_noise = preload("res://Classes/Audio/BulletFlyBySoundPlayer.tscn").instance()
	flyby_noise.translation = closest_point
	
	get_tree().root.call_deferred("add_child", flyby_noise)

remote func jump():
	if is_on_floor:
		velocity.y = JUMP_VELOCITY
		jump_timeout = 0.2
		$Sounds/Jump.play()
		weapon_bob_anim.travel("Jump")

func jetpack(delta):
	# Swap these to try the different versions of the jetpack.
	jetpack_grounded(delta)
	#jetpack_empty(delta)

func jetpack_empty(delta):
	debug.text = "JP fuel: %s\nJP active: %s\nJP used: %s\nJP sound: %s" % [
		jetpack_fuel, jetpack_active, jetpack_used, !$Sounds/Jetpack.stream_paused
	]
	
	# Enable jetpack when it is fully charged.
	if jetpack_fuel > (JETPACK_FUEL_MAX - 0.001):
		jetpack_used = false
	# Disable jetpack when it is empty.
	elif jetpack_fuel <= 0 and not jetpack_active:
		jetpack_used = true
	
	if jetpack_active and not jetpack_used and jetpack_fuel > 0:
		velocity.y += JETPACK_THRUST * delta
		jetpack_fuel -= delta
		$Sounds/Jetpack.stream_paused = false
	else:
		$Sounds/Jetpack.stream_paused = true
	
	# Only charge when fully empty.
	if jetpack_used:
		jetpack_fuel = clamp(
			jetpack_fuel + JETPACK_REFILL_RATE * delta,
			0.0,
			JETPACK_FUEL_MAX
		)

# Charge when grounded variant.
func jetpack_grounded(delta):
	debug.text = "JP fuel: %s\nJP active: %s\nJP sound: %s" % [
		jetpack_fuel, jetpack_active, !$Sounds/Jetpack.stream_paused
	]
	
	# Only charge when grounded.
	if is_on_floor:
		jetpack_fuel = clamp(
			jetpack_fuel + JETPACK_REFILL_RATE * delta,
			0.0,
			JETPACK_FUEL_MAX
		)
		
		$Sounds/Jetpack.stream_paused = true
	
	# Only use jetpack in the air.
	else:
		if jetpack_active and jetpack_fuel > 0:
			velocity.y += JETPACK_THRUST * delta
			jetpack_fuel -= delta
			$Sounds/Jetpack.stream_paused = false
		else:
			$Sounds/Jetpack.stream_paused = true

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
	
	check_floor_collision()
	
	walk(delta)
	fall(delta)
	jetpack(delta)
	
	var movement_vector = Vector3()
	if jump_timeout > 0:
		movement_vector = move_and_slide(velocity, Vector3.UP)
	else:
		var upvector = floor_normal
		movement_vector = move_and_slide_with_snap(velocity, Vector3.DOWN, upvector, true)
		
	velocity = movement_vector
	
	rset("translation", translation)

func check_floor_collision():
	var space_state = get_world().direct_space_state
	
	var from = global_transform.xform(Vector3(0, 0.0, 0))
	var to = global_transform.xform(Vector3(0, -0.3, 0.0))
	
	var result  = space_state.intersect_ray(from, to)
	
	if jump_timeout > 0:
		is_on_floor = false
	elif result:
		is_on_floor = true
		floor_normal = result.normal
	else:
		is_on_floor = false

func walk(delta):
	jump_timeout -= delta
	
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
	
	if is_on_floor:
		walking_speed = lerp(walking_speed, walk_direction * WALK_VELOCITY, delta * WALK_ACCEL)
	else:
		walking_speed = lerp(walking_speed, walk_direction * JUMP_VELOCITY, delta * JUMP_ACCEL)
	walking_speed = walking_speed.rotated(-rotation.y)
	
	velocity.x = walking_speed.x
	velocity.z = walking_speed.y
	
	# Make walking perpendicular to the floor
	if is_on_floor:
		velocity.y -= velocity.dot(floor_normal) / floor_normal.y
	
	if walking_speed.length() > 0 and is_on_floor:
		weapon_bob_anim.travel("Walk")
	elif walking_speed.length() == 0 and is_on_floor:
		weapon_bob_anim.travel("Idle")


func fall(delta):
	if is_on_floor:
		if not was_on_floor: # if this is the first frame of ground conotact after a frame of no ground contact - we've just ended a fall
			weapon_bob_anim.travel("Land")
	
	else:
		velocity += delta * GRAVITY
	
	was_on_floor = is_on_floor
	

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
	
	is_dead = true
	
	set_health(0)
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
	# The underscore indicates an unused variable.
	# Because it is declared in this scope, it will disappear as soon as the
	# function returns. As is, it exists solely to catch the return value of shoot().
	var _remaining_ammo = active_weapon.shoot($Camera)

func reload():
	active_weapon.reload()

sync func switch_to_next_weapon():
	active_weapon = weapons.next_weapon()

sync func switch_to_prev_weapon():
	active_weapon = weapons.prev_weapon()

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
	if event.is_action_released("MoveJetpack"):
		jetpack_active = false
		
	if event.is_action_pressed("WeaponPrimary"):
		shoot()
	if event.is_action_pressed("WeaponReload"):
		reload()
	
	if event.is_action_pressed("NextWeapon"):
		rpc("switch_to_next_weapon")
	if event.is_action_pressed("PrevWeapon"):
		rpc("switch_to_prev_weapon")


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
