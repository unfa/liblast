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

func get_players():
	return $Players.get_children()

remote func check_players(players):
	for player in players:
		if not $Players.has_node(player.name):
			$Players.add_child(player)

func add_player(id):
	var player = player_scene.instance()
	
	player.name = str(id)
	$Players.add_child(player)
	player.set_network_master(id)
	player.translation += Vector3(0.0, 3.0, 0.0)
	
	rpc("check_players", get_players())

func on_peer_connected(id):
	print("Peer connected with id ", id)
	
	add_player(id)
	

func on_connection_established():
	print("Connection has been established")

func on_connection_failed():
	print("Connection has failed")
