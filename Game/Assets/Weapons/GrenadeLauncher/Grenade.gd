extends RigidBody

func _process(delta):
	# TODO: synchronize position
	pass

func explode():
	queue_free()
