extends Control

onready var hit_sound = $HitConfirmationSound
onready var kill_sound = $KillConfirmationSound

var remaining_time = -10.0

func activate(time, kill = false):
	remaining_time = time
	if kill:
		kill_sound.play()
	else:
		hit_sound.play()

func _process(delta):
	remaining_time -= delta
	self.modulate = Color(1, 1, 1, exp(remaining_time * 10))
