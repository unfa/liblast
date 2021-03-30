extends Spatial


onready var spawn_points = get_children()


# Return an available spawn point.
func get_spawn_point(index: int = -1):
	# If index is negative, return a randomly chosen spawn point.
	if index < 0:
		return spawn_points[randi() % spawn_points.size()]
	# If index is positive, return a specific spawn point.
	# This is mostly for debugging.
	else:
		# Take the modulo of the index argument, in case the number is too high.
		return spawn_points[index % spawn_points.size()]
