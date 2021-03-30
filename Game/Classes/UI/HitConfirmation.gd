extends Control

onready var sound = $HitConfirmationSound

var remaining_time = -10.0

func activate(time):
	remaining_time = time
	sound.play()

func _process(delta):
	remaining_time -= delta
	self.modulate = Color(1, 1, 1, exp(remaining_time * 10))
