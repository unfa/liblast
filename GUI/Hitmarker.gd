extends Control

var remaining_time = -10.0

func activate(time):
	remaining_time = time

func _process(delta):
	remaining_time -= delta
	self.modulate = Color(1, 1, 1, exp(remaining_time * 10))
