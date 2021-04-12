extends Spatial

var first = true
var velocity = 200

func _ready():
	translate_object_local(Vector3(-10,0,0))
	set_process(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	translate_object_local(Vector3(-velocity * delta,0,0))

const casing = preload("res://Assets/Weapons/Handgun/Casing.gd")

func _on_Raycast_body_entered(body):
	if not (body is Player) and not (body is casing):
		queue_free()
