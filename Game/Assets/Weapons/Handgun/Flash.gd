extends Node3D

func _ready():
	$CPUParticles3D.emitting = true
	$AnimationPlayer.play("Flash")

func _on_Timer_timeout():
	queue_free()
