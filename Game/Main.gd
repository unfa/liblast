extends Node

enum GameFocus {MENU, GAME, CHAT, AWAY}

@onready var gui = $GUI
@onready var hud = $HUD
@onready var player = $Level/Player
@onready var chat = hud.get_node("Chat")

var focus = GameFocus.MENU

func _input(event) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if focus == GameFocus.GAME:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			gui.show()
			player.input_active = false
			focus = GameFocus.MENU
		elif focus == GameFocus.MENU:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			gui.hide()
			player.input_active = true
			focus = GameFocus.GAME
