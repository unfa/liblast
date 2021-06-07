extends Control

@onready var main = get_tree().get_root().get_node("Main")
@onready var player = main.player
@onready var chat_history = $VBoxContainer/ChatHistory
@onready var chat_typing = $VBoxContainer/Typing
@onready var chat_editor = $VBoxContainer/Typing/Editor
@onready var chat_label = $VBoxContainer/Typing/Label


#class chat_message:
#	var sender_id := 0
#	var team := 0
#	var message := ''
#
#	func _init(sender_id, team, message):
#		self.sender_id = sender_id
#		self.team = team
#		self.message = message

#@remotesync var message: chat_message:
#	set(new_message):
#		print("message changed : ", new_message)
#		$VBoxContainer/ChatHistory.text += "\n" + str(new_message[0]) + ' : ' + new_message[2]

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
	chat_history.text += '\n' + str(sender_id) + " | " + message

func _on_LineEdit_text_entered(new_text):
	# RPC is currently not implemented in the engine
	var sender_id = get_tree().get_network_unique_id()
	var new_message = [sender_id, 0, new_text]
	chat_message(sender_id, 0, new_text)
	#chat_message.rpc(get_tree().get_network_unique_id(), $VBoxContainer/Typing/LineEdit.text)
	chat_editor.text = ''
	state = 0 #ChatState.INACTIVE
	main.focus = 0 #main.GameFocus.GAME
