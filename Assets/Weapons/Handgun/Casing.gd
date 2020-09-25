extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var collisions = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	$CollisionCoarse.disabled = false
	$CollisionFine.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_FreeTimer_timeout():
	queue_free()
	
func _on_Casing_body_entered(body):
	
	$AudioStreamPlayer3D.max_db = max(20 - (linear_velocity.length() * 10), 0)
	$AudioStreamPlayer3D.pitch_scale = rand_range(0.98, 1.02)
	print($AudioStreamPlayer3D.max_db)
	#$AudioStreamPlayer3D.play()
	
	collisions += 1
	#print("collision: ", String(collisions))
	
	if collisions == 3:
		$CollisionCoarse.disabled = true
		$CollisionFine.disabled = false
		
	if collisions == 10:
		queue_free()
