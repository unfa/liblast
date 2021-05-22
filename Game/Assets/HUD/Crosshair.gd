extends Control

@onready var aplayer = $AnimationPlayer

func hit():
	aplayer.stop()
	aplayer.play("Hit")
	
func kill():
	aplayer.stop()
	aplayer.play("Kill")

#func hide():
#	aplayer.stop()
#	aplayer.play("Hide")
##
#func show():
#	aplayer.stop()
#	aplayer.play("Show")
