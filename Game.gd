extends Spatial

export var is_server = true

export var SERVER_PORT = 9999
export var SERVER_IP = "172.28.162.191"
export var MAX_PLAYERS = 10

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
	peer.connect("connected_to_server", self, "on_connection_established")
	peer.connect("connection_failed", self, "on_connection_failed")
	return peer

func initialize_client():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(SERVER_IP, SERVER_PORT)
	peer.connect("network_peer_connected", self, "on_peer_connected")
	return peer

func on_peer_connected(id):
	print("Peer connected with id ", id)

func on_connection_established():
	print("Connection has been established")

func on_connection_failed():
	print("Connection has failed")
