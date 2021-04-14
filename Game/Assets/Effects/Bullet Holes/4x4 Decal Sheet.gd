extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_children()[randi() % get_child_count()].show()
	rotate_y(randf())


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
