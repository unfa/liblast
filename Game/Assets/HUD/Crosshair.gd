extends Control

@onready var aplayer = $AnimationPlayer

func hit():
	aplayer.stop()
	aplayer.play("Hit")
	
func kill():
	aplayer.stop()
	aplayer.play("Kill")
