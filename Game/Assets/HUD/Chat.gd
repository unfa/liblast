extends Control

@onready var main = get_tree().get_root().get_node("Main")

enum ChatState {INACTIVE, TYPING_ALL, TYPING_TEAM}

enum GameFocus {MENU, GAME, CHAT, AWAY} # copied from Main.gd TODO: delete this

var state = ChatState.INACTIVE :
	set(new_state):
		state = new_state
		match new_state:
			0: #ChatState.INACTIVE:
				$VBoxContainer/Typing.hide()
				$VBoxContainer/Typing/LineEdit.release_focus()
			1: #ChatState.TYPING_ALL:
				$VBoxContainer/Typing.show()
				$VBoxContainer/Typing/LineEdit.grab_focus()
			2: #ChatState.TYPING_TEAM:
				$VBoxContainer/Typing.show()
				$VBoxContainer/Typing/LineEdit.grab_focus()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event) -> void:
	if Input.is_action_just_pressed("say_all"):
		main.focus = 1 #main.GameFocus.CHAT
		state = 1 #ChatState.TYPING_ALL
		
	if Input.is_action_just_pressed("say_team"):
		main.focus = 1 #main.GameFocus.CHAT
		state = 2 #ChatState.TYPING_TEAM
	
	if Input.is_action_just_pressed("UI_Accept") and state != 0: #ChatState.INACTIVE:
		$VBoxContainer/ChatHistory.text.append($VBoxContainer/Typing/LineEdit.text)
		$VBoxContainer/Typing/LineEdit.text.clear()
		state = 0 #ChatState.INACTIVE
		main.focus = 0 #main.GameFocus.GAME
	
func _unhandled_input(event) -> void:
	if state != 0: #ChatState.INACTIVE:
		get_tree().get_root().set_input_as_handled()
