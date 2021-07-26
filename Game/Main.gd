extends Node

enum GameFocus {MENU, GAME, CHAT, AWAY}
enum NetworkRole {NONE, CLIENT, SERVER, DEDICATED_SERVER, RELAY_SERVER}

const NET_PORT = 12597
const NET_SERVER = "localhost" #liblast.unfa.xyz"

var peer = NetworkedMultiplayerENet.new()

var role = NetworkRole.NONE:
	set(new_role):
		role = new_role
		print("Network Role changed to ", NetworkRole.keys()[new_role])

var player_scene = preload("res://Assets/Characters/Player.tscn")

@onready var gui = $GUI
@onready var hud = $HUD
@onready var chat = hud.get_node("Chat")
var local_player: Node = null


class PlayerList:
	var items = {}
	
	func store(pid, item):
		items[pid] = item
	
	func erase(pid):
		items.erase(pid)
	
	func update(pid, item):
		if items[pid]:
			items[pid] = item
	
	func get():
		return items
	
var player_list = []

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
	var new_player
	
	if player_scene.has_method(&"instance"):
		new_player = player_scene.instance()
	else:
		new_player = player_scene.instantiate()
		
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
	
	$NetworkTesting/TextEdit.text = local_player.player_info.name
	$NetworkTesting/ColorPickerButton.color = local_player.player_info.color

func start_dedicated_server():	
	role = NetworkRole.DEDICATED_SERVER
	peer.create_server(NET_PORT, 16)
	get_tree().network_peer = peer
	#create_player(1, true)

func _on_Host_pressed():
	role = NetworkRole.SERVER
	$NetworkTesting/Host.disabled = true
	$NetworkTesting/Connect.disabled = true
	
	peer.create_server(NET_PORT, 16)
	get_tree().network_peer = peer
	create_player(1, true)
	focus = GameFocus.GAME

func _on_Connect_pressed():
	$NetworkTesting/Host.disabled = true
	$NetworkTesting/Connect.disabled = true
	
	peer.create_client(NET_SERVER, NET_PORT)
	get_tree().network_peer = peer
	
func _player_connected(id) -> void:
	print("player connected, id: ", id)
	create_player(id, false)
	if local_player:
		local_player.rpc(&"update_info")

func _player_disconnected(id) -> void:
	print("player disconnected, id: ", id)
	
func _connected_ok() -> void:
	print("connected to server")
	var id = get_tree().get_network_unique_id()
	create_player(id, true)
	focus = GameFocus.GAME
	role = NetworkRole.CLIENT
	
func _connected_fail() -> void:
	print("connection to server failed")
	
func _server_disconnected() -> void:
	print("server disconnected")
	
	role = NetworkRole.NONE

func _ready() -> void:
	
	print("Commandline arguments: ", OS.get_cmdline_args())
	
	get_tree().connect("network_peer_connected", self._player_connected)
	get_tree().connect("network_peer_disconnected", self._player_disconnected)
	get_tree().connect("connected_to_server", self._connected_ok)
	get_tree().connect("connection_failed", self._connected_fail)
	get_tree().connect("server_disconnected", self._server_disconnected)


func _on_TextEdit_text_submitted(new_text):
	local_player.player_info.name = new_text
	local_player.update_info()


func _on_ColorPickerButton_color_changed(color):
	local_player.player_info.color = color
	local_player.update_info()
