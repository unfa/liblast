extends CSGCombiner

var bulletHitEffect = preload("res://Assets/Effects/BulletHit.tscn")

remotesync func on_hit(damage, position):
	var effect = bulletHitEffect.instance()
	add_child(effect)
	effect.global_transform.origin = position
