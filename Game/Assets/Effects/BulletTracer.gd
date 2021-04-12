extends Spatial

var first = true
var velocity = 200

const bullet_hit = preload("res://Assets/Effects/BulletHit.tscn")

func _ready():
	translate_object_local(Vector3(-10,0,0))
	set_process(true)

func face_vector(target):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	translate_object_local(Vector3(-velocity * delta,0,0))
	if $RayCast.is_colliding():
				if $RayCast.get_collider() is Player:
					queue_free()
				else:
					var bullet_hit_effect = bullet_hit.instance()
					get_tree().root.add_child(bullet_hit_effect)
					
					bullet_hit_effect.look_at($RayCast.get_collision_normal(), Vector3(0.29348756, 0.834576, 0.2384765))
					bullet_hit_effect.rotate_object_local(Vector3(1, 0, 0), -PI/2)
					bullet_hit_effect.global_translate($RayCast.get_collision_point())
					
					
					queue_free()

const casing = preload("res://Assets/Weapons/Handgun/Casing.gd")

func _on_Raycast_body_entered(body):
	if not (body is Player) and not (body is casing):
		queue_free()
		#var bullet_hit_effect = bullet_hit.instance()
		#bullet_hit_effect.global_transform = 
		#get_tree().root.call_deferred("add_child")
		
