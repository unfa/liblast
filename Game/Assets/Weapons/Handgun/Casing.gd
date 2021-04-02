extends RigidBody

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var collisions = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$CollisionCoarse.disabled = false
	$CollisionFine.disabled = true
	
	$Smoke.emitting = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Smoke.global_transform.basis = Transform.IDENTITY.basis # reset particle emmiter rotation

func _on_FreeTimer_timeout():
	queue_free()
func _on_Casing_body_entered(body):
	var vel = linear_velocity.length()
	#print(linear_velocity.length())
	
	if vel > 1:
		$Sound.pitch_scale = rand_range(0.99, 1.01)
		$Sound.unit_db = -48 + min((pow(vel, 3)), 48)
		#print(String($Sound.unit_db) + " dB")
		$Sound.play()
	
	collisions += 1
	#print("collision: ", String(collisions))
	
	if collisions == 5:
		$CollisionCoarse.disabled = true
		$CollisionFine.disabled = false
	
	#if collisions == 10:
	#	queue_free()


func _on_SmokeTimer_timeout():
	$Trail3D.emit = false
