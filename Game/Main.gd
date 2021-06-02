extends Node

enum Gamemode {IN_MENU, PLAYING}

var mode = Gamemode.IN_MENU

func _input(event) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if mode == Gamemode.PLAYING:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			$CanvasLayer/GUI.show()
			$Level/Player.input_active = false
			mode = Gamemode.IN_MENU
		elif mode == Gamemode.IN_MENU:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			$CanvasLayer/GUI.hide()
			$Level/Player.input_active = true
			mode = Gamemode.PLAYING
