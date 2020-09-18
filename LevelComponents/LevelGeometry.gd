extends CSGCombiner

var bulletHitEffect = preload("res://Assets/Effects/BulletHit.tscn")

remotesync func on_hit(damage, position):
	var effect = bulletHitEffect.instance()
	effect.global_transform.origin = position
	get_tree().root.call_deferred("add_child", effect)
