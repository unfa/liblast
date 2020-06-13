extends Spatial

export var is_server = true

export var SERVER_PORT = 9999
export var SERVER_IP = "172.28.162.191"
export var MAX_PLAYERS = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_server:
		initialize_server()
	else:
		initialize_client()
	debug_connection_status()

func debug_connection_status():
	if (get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED):
		print("We have connected succesfully")
	
	if (get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTING):
		print("We are trying to connect")

func initialize_server():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().network_peer = peer

func initialize_client():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(SERVER_IP, SERVER_PORT)
	get_tree().network_peer = peer
