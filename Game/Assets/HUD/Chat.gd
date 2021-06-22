extends Control

@onready var main = get_tree().get_root().get_node("Main")
@onready var player = main.local_player
@onready var chat_history = $VBoxContainer/ChatHistory
@onready var chat_typing = $VBoxContainer/Typing
@onready var chat_editor = $VBoxContainer/Typing/Editor
@onready var chat_label = $VBoxContainer/Typing/Label

enum ChatState {INACTIVE, TYPING_ALL, TYPING_TEAM}
enum GameFocus {MENU, GAME, CHAT, AWAY} # copied from Main.gd TODO: delete this

var state = ChatState.INACTIVE :
	set(new_state):
		state = new_state
		match new_state:
			0: #ChatState.INACTIVE:
				chat_typing.hide()
				chat_editor.release_focus()
			1: #ChatState.TYPING_ALL:
				chat_label.text = "all: "
				chat_typing.show()
				chat_editor.grab_focus()
				chat_editor.text = ''
			2: #ChatState.TYPING_TEAM:
				chat_label.text = "team: "
				chat_typing.show()
				chat_editor.grab_focus()
				chat_editor.text = ''

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _input(_event) -> void:
	if state == ChatState.INACTIVE:
		if Input.is_action_just_pressed("say_all"):
			main.focus = 2 #main.GameFocus.CHAT
			state = 1 #ChatState.TYPING_ALL
			get_tree().get_root().set_input_as_handled()
			
		if Input.is_action_just_pressed("say_team"):
			main.focus = 2 #main.GameFocus.CHAT
			state = 2 #ChatState.TYPING_TEAM
			get_tree().get_root().set_input_as_handled()
			
	elif Input.is_action_just_pressed("say_cancel"):
			main.focus = 1 #main.GameFocus.GAME
			state = 0 #ChatState.INACTIVE
	
func _unhandled_input(_event) -> void:
	if state != 0: #ChatState.INACTIVE:
		get_tree().get_root().set_input_as_handled()

# doesn't work over network due to missing RPC implementation in Godot 4
@remotesync func chat_message(sender_id: int, recipient_team, message: String) -> void:
	var sender_info = main.get_node("Players").get_node(str(sender_id)).player_info
	
	
	chat_history.append_bbcode('\n' + '[b][color=' + sender_info.color.to_html() +']' + str(sender_info.name) + '[/color][/b] : [i]' + message + '[/i]')

func _on_LineEdit_text_entered(new_text):
	# RPC is currently not implemented in the engine
	var sender_id = get_tree().get_network_unique_id()
	var new_message = [sender_id, 0, new_text]
	rpc(&'chat_message',sender_id, 0, new_text)
	chat_editor.text = ''
	state = 0 #ChatState.INACTIVE
	main.focus = 0 #main.GameFocus.GAME
