extends Node

enum GameFocus {MENU, GAME, CHAT, AWAY}

const NET_PORT = 12597
const NET_SERVER = "localhost"# "liblast.unfa.xyz"

var peer = NetworkedMultiplayerENet.new()

var player_scene = preload("res://Assets/Characters/Player.tscn")

@onready var gui = $GUI
@onready var hud = $HUD
@onready var chat = hud.get_node("Chat")
var local_player: Node = null

var focus = GameFocus.MENU :
	set(new_focus):
		match new_focus:
			0:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				gui.show()
				if local_player:
					local_player.input_active = false
			1:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				gui.hide()
				if local_player:
					local_player.input_active = true
			2:
				if local_player:
					local_player.input_active = false
			3:
				if local_player:
					local_player.input_active = true

		focus = new_focus

func _input(_event) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if focus == GameFocus.GAME:
			focus = GameFocus.MENU
		elif focus == GameFocus.MENU:
			focus = GameFocus.GAME
	
	
func create_player(id: int, is_local: bool) -> void:
	var new_player = player_scene.instance() #tiate()
	var spawnpoint = $Map/SpawnPoints.get_children()[randi() % len($Map/SpawnPoints.get_children())]
	new_player.name = str(id)
	new_player.global_transform = spawnpoint.global_transform
	new_player.set_network_master(id)
	$Players.add_child(new_player)
	
	if is_local:
		local_player = $Players.get_node(str(id))
		local_player.get_node("Head/Camera").current = true
	else:
		$Players.get_node(str(id) + "/Head/Camera").current = false
		if local_player:
			local_player.get_node("Head/Camera").current = true

func start_dedicated_server():	
	peer.create_server(NET_PORT, 16)
	get_tree().network_peer = peer
	#create_player(1, true)

func _on_Host_pressed():
	$NetworkTesting/Host.disabled = true
	$NetworkTesting/Connect.disabled = true
	
	peer.create_server(NET_PORT, 16)
	get_tree().network_peer = peer
	create_player(1, true)

func _on_Connect_pressed():
	$NetworkTesting/Host.disabled = true
	$NetworkTesting/Connect.disabled = true
	
	peer.create_client(NET_SERVER, NET_PORT)
	get_tree().network_peer = peer
	
	
func _player_connected(id) -> void:
	print("player connected, id: ", id)
	create_player(id, false)


func _player_disconnected(id) -> void:
	print("player disconnected, id: ", id)
	
	
func _connected_ok() -> void:
	print("connected to server")
	var id = get_tree().get_network_unique_id()
	create_player(id, true)
	
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
