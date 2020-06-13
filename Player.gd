extends KinematicBody

const GRAVITY = 9.8 

var velocity = Vector3.ZERO

var walkDirection = Vector2.ZERO

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func gravity():
	self.velocity.y -= GRAVITY
	
func walk():
	walkDirection = Vector2.ZERO
	
	if Input.is_action_pressed("MoveForward"):
		walkDirection.x += 1
	if Input.is_action_pressed("MoveBack"):
		walkDirection.x -= 1
	if Input.is_action_pressed("MoveRight"):
		walkDirection.y += 1
	if Input.is_action_pressed("MoveLeft"):
		walkDirection.y -= 1
		
	print("Player walkDirection: ", walkDirection)
	
func motion(delta):
	self.move_and_slide(velocity * delta, Vector3.UP)
	#rpc("move_and_slide", velocity, Vector3.UP)
	
func _physics_process(delta):
	gravity()
	walk()
	motion(delta)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
