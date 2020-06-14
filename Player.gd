extends KinematicBody

const GRAVITY = 9.8 
const JUMP_VELOCITY = 400
const WALK_VELOCITY = 550

const MOUSE_SENSITIVITY = 1.0 / 300

onready var camera = $Camera

var velocity = Vector3.ZERO

var walkDirection = Vector2.ZERO

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func gravity():
	self.velocity.y -= GRAVITY
	
remote func walk(direction: Vector2):
	#print ("Walk: ", direction)
	
	var walkDirectionNormalized = direction.normalized()
	#print("Player walkDirection: ", walkDirectionNormalized)
	
	var walkVelocity = WALK_VELOCITY * walkDirectionNormalized
	
	velocity.x =   walkVelocity.y
	velocity.z = - walkVelocity.x
	
remote func jump():
	print("JUMP")
	velocity.y = JUMP_VELOCITY

remote func mouselook(rel):
	self.rotate_y(- rel.x * MOUSE_SENSITIVITY)
	camera.rotate_x(-rel.y * MOUSE_SENSITIVITY)

func motion(delta):
	self.move_and_slide(velocity.rotated(Vector3.UP, self.rotation.y) * delta, Vector3.UP)

func _physics_process(delta):
	gravity()
	
	rpc("walk", walkDirection)
	walk(walkDirection)
	
	motion(delta)

func _input(event):
	#print(event)
	
	# Moouselook
	if event is InputEventMouseMotion:
		var rel = event["relative"]
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
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
