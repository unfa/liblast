extends KinematicBody

const GRAVITY = 9.8 * 1.5
const JUMP_VELOCITY = 400
const WALK_VELOCITY = 550

const AIR_CONTROL = 0.1

const WALK_ACCEL = 0.25
const WALK_DECEL = 0.1

const MOUSE_SENSITIVITY = 1.0 / 1000

export var max_health = 150
onready var health = max_health

onready var camera = $Camera
onready var debug = $Debug

var is_dead = false

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
var walkDirection = Vector2.ZERO
var walkDirInt = Vector2.ZERO

#var bulletHitEffect = preload("res://Assets/Effects/BulletHit.tscn")
var bodyHitEffect = preload("res://Assets/Effects/BodyHit.tscn")

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

func gravity():
	if not is_on_floor():
		self.velocity.y -= GRAVITY

func get_closest_point(_A: Vector3, _B: Vector3):
	var A = transform.inverse().xform(_A)
	var B = transform.inverse().xform(_B)
	
	var diff = B - A
	var result = A - (A.dot(diff) * diff) / (diff.length_squared())
	return result.xform(transform)

func on_bullet_flyby(from, to):
	var closest_point = get_closest_point(from, to)
	
	get_tree().root.call_deferred("add_child", preload("res://Audio/BulletFlyBySoundPlayer.tscn"))

remote func walk(direction: Vector2):
	
	var walkDirectionNormalized = direction.normalized()
	#print("Player walkDirection: ", walkDirectionNormalized)
	
	var walkVelocity = WALK_VELOCITY * walkDirectionNormalized
	
	var interpolation
	
	var currentVelocity = Vector2(- velocity.z, velocity.x)
	if walkVelocity.dot(currentVelocity) > 0:
		interpolation = WALK_ACCEL
	else:
		interpolation = WALK_DECEL
	
	if not is_on_floor():
		interpolation *= AIR_CONTROL
	
	debug.text = "Interpolation: " + String(interpolation)
	debug.text += "\nwalkVelocity: " + String(walkVelocity)
	debug.text += "\ncurrentVelocity: " + String(currentVelocity)
	debug.text += "\nvelocity: " + String(velocity)
	debug.text += "\nis_on_floor(): " + String(is_on_floor())
	debug.text += "\nhealth: " + String(health)
	
	velocity.x = lerp(velocity.x, walkVelocity.rotated(- self.rotation.y).y, interpolation)
	velocity.z = lerp(velocity.z, - walkVelocity.rotated(- self.rotation.y).x, interpolation)
	
	if walkVelocity.length() > 0 and is_on_floor():
		$Sounds/Footsteps.play()
#
remote func jump():
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
		$Sounds/Jump.play() 

remote func mouselook_abs(x, y):
	camera.rotation.x = x
	rotation.y = y

remote func mouselook(rel):
	var sensitivity = MOUSE_SENSITIVITY * game.mouse_sensitivity_multiplier
	rotate_y(- rel.x * sensitivity)
	camera.rotation.x = clamp(camera.rotation.x-rel.y * sensitivity, -PI/2, PI/2)
	
	rpc_unreliable("mouselook_abs", camera.rotation.x, rotation.y)

func motion(delta):
	var slide_velocity = move_and_slide(velocity * delta, Vector3.UP, true)
	#var slide_velocity = move_and_collide(velocity * delta, Vector3.UP)
	
	debug.text += "\nslide_velocity: " + String( slide_velocity )
	debug.text += "\nslide dot product: " + String( velocity.normalized().dot(slide_velocity.normalized()) )
	debug.text += "\nslide count: " + String( self.get_slide_count() )
	for i in range(0, self.get_slide_count() ):
		debug.text += "\nslide " + String(i) + ": " + String( self.get_slide_collision(i).normal )
		var dot_product = self.get_slide_collision(i).normal.dot(velocity)
		debug.text += "\nslide dot " + String(i) + ": " + String( dot_product )
		
		#if dot_product < 0:
		#	# Push represents the component vector pushing into the surface
		#	var push = dot_product * self.get_slide_collision(i).normal
		#	debug.text += "\npush " + String(i) + ": " + String( push )
		#	
		#	velocity -= push
	
	velocity = slide_velocity / delta
	
	if is_on_floor():
		velocity -= get_floor_normal() * 150

func _physics_process(delta):
	
	if is_dead:
		return
	
	if str(get_tree().get_network_unique_id()) != name:
		return
	
	gravity()
	
	rpc("walk", walkDirection)
	walk(walkDirection)
	
	motion(delta)
	
	rset("translation", translation)

master func on_hit(damage, location):
	health -= 30
	
	rpc("blood_splatter", location)
	
	if health <= 0:
		rpc("kill")
		$Sounds/Death.play()
	else:
		$Sounds/Pain.play()

remote func blood_splatter(location):
	var effect = bodyHitEffect.instance()
	get_tree().root.add_child(effect)
	effect.global_transform.origin = location

master func kill():
	health = 0
	
	$CollisionShapeBody.disabled = true
	$CollisionShapeFeet.disabled = true
	
	# spawn gibs
	
	var gibs = $Player/Gibs.duplicate()
	get_tree().root.add_child(gibs)
	gibs.global_transform = global_transform
	gibs.show()
	
	# enable the ragdoll colliders
	for i in gibs.get_children():
		i.get_child(1).disabled = false
	
	# Respawn timer
	
	is_dead = true
	$MeshInstance.hide()
	$Camera/Hand.hide()
	$CrosshairContainer.hide()
	
	
	yield(get_tree().create_timer(3), "timeout")
	
	
	$MeshInstance.show()
	spawn()
	
	yield(get_tree().create_timer(3), "timeout")
	
	for i in gibs.get_children():
		i.queue_free()
		yield(get_tree().create_timer(rand_range(0.1, 1)), "timeout")
	
	gibs.queue_free()

func spawn():
	is_dead = false
	health = 150
	
	velocity = Vector3()
	walkDirection = Vector2.ZERO
	
	game.get_spawn_point().spawn(self)
	
	$MeshInstance.show()
	$Camera/Hand.show()
	
	$CrosshairContainer.show()
	
	$CollisionShapeBody.disabled = false
	$CollisionShapeFeet.disabled = false
	
	$Camera.rotation = Vector3.ZERO
	rotation = Vector3.ZERO

func shoot():
	var gun = find_node("Weapon")
	
	
	gun.shoot()
	
	var space_state = get_world().direct_space_state
	var crosshair_pos = get_viewport().size / 2
	
	var from = $Camera.project_ray_origin(crosshair_pos)
	var to = from + $Camera.project_ray_normal(crosshair_pos) * 1000
	
	var result = space_state.intersect_ray(from, to)
	
	if "collider" in result:
		var hit = result.collider
				
		if hit.has_method("on_hit"):
			hit.rpc("on_hit", 30, result.position)
		
		if hit is get_script():
			print("Is a live player")
			
			$CrosshairContainer/HitConfirmation.activate(.2)

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

	# Walk
	if event.is_action_pressed("MoveForward"):
		walkDirection.x += 1
	if event.is_action_pressed("MoveBack"):
		walkDirection.x -= 1
	if event.is_action_pressed("MoveRight"):
		walkDirection.y += 1
	if event.is_action_pressed("MoveLeft"):
		walkDirection.y -= 1
	
	if event.is_action_released("MoveForward"):
		walkDirection.x += -1
	if event.is_action_released("MoveBack"):
		walkDirection.x -= -1
	if event.is_action_released("MoveRight"):
		walkDirection.y += -1
	if event.is_action_released("MoveLeft"):
		walkDirection.y -= -1
	
	if event.is_action_pressed("WeaponPrimary"):
		shoot()

# Called when the node enters the scene tree for the first time.
func _ready():
	# disabled the ragdoll collider
	for i in $Player/Gibs.get_children():
		i.get_child(1).disabled = true
		#disabled = true
		#$"Player/Gibs/PlayerGibs _cell /shape0".set_disabled(true)
	
	rset_config("translation", MultiplayerAPI.RPC_MODE_SYNC)
	
	# only show the debug label on local machine
	if name != String(get_tree().get_network_unique_id()):
		debug.hide()
		print(get_tree().get_network_unique_id())
		print(name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
