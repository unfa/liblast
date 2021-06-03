extends Node

enum GameFocus {IN_MENU, PLAYING, TYPING, AFK}

var mode = GameFocus.IN_MENU

func _input(event) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if mode == GameFocus.PLAYING:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			$CanvasLayer/GUI.show()
			$Level/Player.input_active = false
			mode = GameFocus.IN_MENU
		elif mode == GameFocus.IN_MENU:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			$CanvasLayer/GUI.hide()
			$Level/Player.input_active = true
			mode = GameFocus.PLAYING
