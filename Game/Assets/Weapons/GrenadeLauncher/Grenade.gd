extends RigidBody

var explosion_effect = preload("res://Assets/Effects/GrenadeExplosion.tscn")

func _process(delta):
	# TODO: synchronize position
	pass

func explode():
	var explosion = explosion_effect.instance()
	explosion.global_transform = global_transform
	get_tree().root.call_deferred("add_child", explosion)
	queue_free()
