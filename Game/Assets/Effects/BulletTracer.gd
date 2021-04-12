extends Spatial

var first = true
var velocity = 200

const bullet_hit = preload("res://Assets/Effects/BulletHit.tscn")

func _ready():
	translate_object_local(Vector3(-10,0,0))
	set_process(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	translate_object_local(Vector3(-velocity * delta,0,0))
	if $RayCast.is_colliding():
				if $RayCast.get_collider() is Player:
					queue_free()
				else:
					var bullet_hit_effect = bullet_hit.instance()
					bullet_hit_effect.global_translate($RayCast.get_collision_point())
					#bullet_hit_effect.global_transform *= bullet_hit_effect.global_transform.looking_at($RayCast.get_collision_point() + $RayCast.get_collision_normal(), Vector3.UP)
					get_tree().root.call_deferred("add_child", bullet_hit_effect)
					queue_free()

const casing = preload("res://Assets/Weapons/Handgun/Casing.gd")

func _on_Raycast_body_entered(body):
	if not (body is Player) and not (body is casing):
		queue_free()
		#var bullet_hit_effect = bullet_hit.instance()
		#bullet_hit_effect.global_transform = 
		#get_tree().root.call_deferred("add_child")
		
