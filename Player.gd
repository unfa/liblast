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

onready var game = get_parent().get_parent()

var velocity = Vector3.ZERO

var walkDirection = Vector2.ZERO
var walkDirInt = Vector2.ZERO

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func gravity():
	if not is_on_floor():
		self.velocity.y -= GRAVITY

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
	
remote func jump():
	if is_on_floor():
		velocity.y = JUMP_VELOCITY

remote func mouselook(rel):
	var sensitivity = MOUSE_SENSITIVITY * game.mouse_sensitivity_multiplier
	self.rotate_y(- rel.x * sensitivity)
	camera.rotation.x = clamp(camera.rotation.x-rel.y * sensitivity, -PI/2, PI/2)

func motion(delta):
	self.move_and_slide(velocity * delta, Vector3.UP, true)

func _physics_process(delta):
	if str(get_tree().get_network_unique_id()) != name:
		return
	
	gravity()
	
	rpc("walk", walkDirection)
	walk(walkDirection)
	
	motion(delta)
	
	rset("translation", translation)

master func on_hit():
	health -= 30
	print(health)

master func kill():
	health = 0
	spawn()

func spawn():
	health = 150
	game.get_spawn_point().spawn(self)

func shoot():
	var space_state = get_world().direct_space_state
	var crosshair_pos = OS.get_real_window_size() / 2
	
	var from = $Camera.project_ray_origin(crosshair_pos)
	var to = from + $Camera.project_ray_normal(crosshair_pos) * 1000
	
	var result = space_state.intersect_ray(from, to)
	
	if "collider" in result:
		var hit = result.collider
		print(hit)
		if hit.has_method("on_hit"):
			hit.rpc("on_hit")

func _input(event):
	if str(get_tree().get_network_unique_id()) != name:
		return
	
	if game.GAME_MODE != "PLAYING":
		return
	
	# Moouselook
	if event is InputEventMouseMotion:
		var rel = event.relative
		
		rpc("mouselook", rel)
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
	rset_config("translation", MultiplayerAPI.RPC_MODE_SYNC)
	
	# only show the debug label on local machine
	if name != String(get_tree().get_network_unique_id()):
		debug.hide()
		print(get_tree().get_network_unique_id())
		print(name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
