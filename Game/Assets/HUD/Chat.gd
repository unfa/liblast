extends Control

@onready var main = get_tree().get_root().get_node("Main")
@onready var player = main.player

class chat_message:
	var sender_id := 0
	var team := 0
	var message := ''
	
	func _init(sender_id, team, message):
		self.sender_id = sender_id
		self.team = team
		self.message = message

@remotesync var message: chat_message:
	set(new_message):
		print("message changed")
		$VBoxContainer/ChatHistory.text += "\n" + str(new_message.sender_id) + ' : ' + new_message.message

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
				$VBoxContainer/Typing/Label.text = "all: "
				$VBoxContainer/Typing.show()
				$VBoxContainer/Typing/LineEdit.grab_focus()
				$VBoxContainer/Typing/LineEdit.text = ''
			2: #ChatState.TYPING_TEAM:
				$VBoxContainer/Typing/Label.text = "team: "
				$VBoxContainer/Typing.show()
				$VBoxContainer/Typing/LineEdit.grab_focus()
				$VBoxContainer/Typing/LineEdit.text = ''

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _input(event) -> void:
	if state == ChatState.INACTIVE:
		if Input.is_action_just_pressed("say_all"):
			main.focus = 2 #main.GameFocus.CHAT
			state = 1 #ChatState.TYPING_ALL
			
		if Input.is_action_just_pressed("say_team"):
			main.focus = 2 #main.GameFocus.CHAT
			state = 2 #ChatState.TYPING_TEAM
	elif Input.is_action_just_pressed("say_cancel"):
			main.focus = 1 #main.GameFocus.GAME
			state = 0 #ChatState.INACTIVE
	
func _unhandled_input(event) -> void:
	if state != 0: #ChatState.INACTIVE:
		get_tree().get_root().set_input_as_handled()

# doesn't work due to missing RPC implementation in Godot 4
#@remotesync func chat_message(peer_id: int, message: String) -> void:
#	var player = str(peer_id)
#	$VBoxContainer/ChatHistory.text += '\n' + player + " | " + message

func _on_LineEdit_text_entered(new_text):
	# RPC is currently not implemented in the engine
	var sender_id = get_tree().get_network_unique_id()
	var new_message = chat_message.new(sender_id, 0, new_text)
	rset("message", new_message)
	#chat_message.rpc(get_tree().get_network_unique_id(), $VBoxContainer/Typing/LineEdit.text)
	$VBoxContainer/Typing/LineEdit.text = ''
	state = 0 #ChatState.INACTIVE
	main.focus = 0 #main.GameFocus.GAME
