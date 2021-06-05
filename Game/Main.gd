extends Node

enum GameFocus {MENU, GAME, CHAT, AWAY}

const NET_PORT = 12597

var peer = NetworkedMultiplayerENet.new()

@onready var gui = $GUI
@onready var hud = $HUD
@onready var player = $Level/Player
@onready var chat = hud.get_node("Chat")

var focus = GameFocus.MENU :
	set(new_focus):
		match new_focus:
			0:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				gui.show()
				player.input_active = false
			1:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				gui.hide()
				player.input_active = true
			2:
				player.input_active = false
			3:
				player.input_active = true

		focus = new_focus

func _input(_event) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if focus == GameFocus.GAME:
			focus = GameFocus.MENU
		elif focus == GameFocus.MENU:
			focus = GameFocus.GAME

func _on_Host_pressed():
	peer.create_server(NET_PORT, 16)
	get_tree().network_peer = peer

func _on_Connect_pressed():
	peer.create_client('localhost', NET_PORT)
	get_tree().network_peer = peer
	
func _player_connected(id) -> void:
	print("player connected, id: ", id)

func _player_disconnected(id) -> void:
	print("player disconnected, id: ", id)
	
func _connected_ok() -> void:
	print("connected to server")
	
func _connected_fail() -> void:
	print("connection to server failed")
	
func _server_disconnected() -> void:
	print("server disconnected")

func _ready() -> void:
	get_tree().connect("network_peer_connected", self._player_connected)
	get_tree().connect("network_peer_disconnected", self._player_disconnected)
	get_tree().connect("connected_to_server", self._connected_ok)
	get_tree().connect("connection_failed", self._connected_fail)
	get_tree().connect("server_disconnected", self._server_disconnected)
