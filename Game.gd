extends Spatial

export var is_server = true

export var SERVER_PORT = 9999
export var SERVER_IP = "172.28.162.191"
export var MAX_PLAYERS = 10

var player_scene = preload("res://Player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	initialize()
	
	debug_connection_status()

func debug_connection_status():
	#if (get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED):
	#	print("We have connected succesfully")
	
	if (get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTING):
		print("We are trying to connect")

func initialize():
	var peer
	
	if is_server:
		peer = initialize_server()
	else:
		peer = initialize_client()
	
	get_tree().network_peer = peer
	

func initialize_server():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().connect("network_peer_connected", self, "on_peer_connected")
	add_player(get_tree().get_network_unique_id())
	return peer

func initialize_client():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(SERVER_IP, SERVER_PORT)
	get_tree().connect("connected_to_server", self, "on_connection_established")
	get_tree().connect("connection_failed", self, "on_connection_failed")
	return peer

func get_player_names():
	var players =  $Players.get_children()
	
	var player_names = []
	for player in players:
		player_names.append(player.name)
	
	return player_names

remote func check_players(player_names):
	print(player_names)
	
	for player_name in player_names:
		if not $Players.has_node(player_name):
			var player = player_scene.instance()
			
			player.name = player_name
			$Players.add_child(player)
			player.translation += Vector3(0.0, 3.0, 0.0)

func add_player(id):
	var player = player_scene.instance()
	
	$Players.add_child(player)
	player.name = str(id)
	player.set_network_master(id)
	player.translation += Vector3(0.0, 3.0, 0.0)
	
	var player_names = get_player_names()
	rpc("check_players", player_names)

func on_peer_connected(id):
	print("Peer connected with id ", id)
	
	add_player(id)
	

func on_connection_established():
	print("Connection has been established")

func on_connection_failed():
	print("Connection has failed")
