extends Node

export var SERVER_PORT = 12597 setget , get_port
export(String, "172.28.162.191", "172.28.166.24", "127.0.0.1") var SERVER_IP = "172.28.162.191" setget , get_ip
export var MAX_PLAYERS = 10
export (String, "MENU", "PLAYING") var GAME_MODE = "MENU"
export var auto_host = false

var mouse_sensitivity_multiplier = 1.0

var player_scene = preload("res://Assets/Characters/Default/Default.tscn")

var settingmap = {
	"is_fullscreen": "set_fullscreen",
	"mouse_sensitivity": "set_mouse_sensitivity",
	"nickname": "set_nickname"
}

var peer = NetworkedMultiplayerENet.new()
var local_player = null setget set_local_player

onready var menu_stack = [$MenuContainer/MainMenu]

func set_local_player(player):
	if local_player != null:
		$Players.remove_child(local_player)
	
	local_player = player
	
	var id = peer.get_unique_id()
	player.name = str(id)
	player.set_network_master(id)
	$Players.add_child(local_player)
	player.set_local_player()
	
	var nickname = $MenuContainer/MainMenu/Name.text
	set_nickname(nickname)
	player.set_nickname(nickname)
	on_player_added(player)
	
	var player_data = get_player_data()
	print(player_data)
	
	rpc("set_player_data", player_data)
	 
	player.hide()

# Called when the node enters the scene tree for the first time.
func _ready():
	$MenuContainer/ConnectMenu/Destination/IPAdress.set_text(SERVER_IP)
	$MenuContainer/ConnectMenu/Destination/Port.set_text(str(SERVER_PORT))
	
	load_settings()
	
	if auto_host:
		initialize_server(false)

func load_settings():
	var load_settings = File.new()
	load_settings.open("user://settings.save", File.READ)
	
	if load_settings.is_open():
		var settings = parse_json(load_settings.get_as_text())
		
		for setting in settings:
			load_setting(setting, settings[setting])

func load_setting(setting, value):
	call(settingmap[setting], value, false)

func save_setting(setting, value):
	var save_settings = File.new()
	save_settings.open("user://settings.save", File.READ_WRITE)
	
	if save_settings.is_open():
		var settings = parse_json(save_settings.get_as_text())
		settings[setting] = value
		save_settings.store_string(to_json(settings))
	else:
		save_settings.close()
		save_settings.open("user://settings.save", File.WRITE)
		var settings = {setting: value}
		save_settings.store_string(to_json(settings))

func _input(event):
	if event.is_action_pressed("ToggleMenu"):
		if GAME_MODE == "PLAYING" and not $MenuContainer.is_visible():
			open_menus()
		elif $MenuContainer/CharacterSelectScreen.is_visible():
			close_menus()
		else:
			# Find the back button
			var children = $MenuContainer.get_children()
			for child in children:
				if child.is_visible():
					var buttons = child.get_children()
					for button in buttons:
						if button.name == "Back":
							button.emit_signal("pressed")
	
	if event.is_action_pressed("ShowPlayerList") and !$MenuContainer.visible:
		$PlayerListContainer.show()
	
	if event.is_action_released("ShowPlayerList"):
		$PlayerListContainer.hide()

func open_menus():
	GAME_MODE = "MENU"
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$MenuContainer.show()

func close_menus():
	if has_node("MenuContainer"):
		GAME_MODE = "PLAYING"
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$MenuContainer.hide()

func return_to_menu(type=null):
	if type == null:
		menu_stack.pop_back()
		type = menu_stack[-1].name
	
	for menu in $MenuContainer.get_children():
		if menu.name == type:
			if type != null:
				while menu_stack[-1].name != type:
					menu_stack.pop_back()
			menu.show()
		else:
			menu.hide()

func open_menu(type):
	for menu in $MenuContainer.get_children():
		if menu.name == type:
			menu_stack.append(menu)
			menu.show()
		else:
			menu.hide()

func join_test_server():
	SERVER_IP = "85.144.28.107"
	initialize_client()

#sync func set_player_name(player, name):
#	print(name)

func join_home():
	SERVER_IP = "127.0.0.1"
	initialize_client()

func join_unfa():
	SERVER_IP = "172.25.162.191"
	initialize_client()

func join_jan():
	SERVER_IP = "172.25.166.24"
	initialize_client()

func set_ip(ip):
	SERVER_IP = ip

func set_mouse_sensitivity(sensitivity_multiplier, save=true):
	if mouse_sensitivity_multiplier != sensitivity_multiplier:
		mouse_sensitivity_multiplier = sensitivity_multiplier
	else:
		return
	
	if save:
		save_setting("mouse_sensitivity", sensitivity_multiplier)
	else:
		$MenuContainer/ControlsMenu/HBoxContainer/SensitivitySlider.value = sensitivity_multiplier

func set_fullscreen(is_fullscreen, save=true):
	if OS.window_fullscreen != is_fullscreen:
		OS.window_fullscreen = is_fullscreen
	else:
		return
	
	if save:
		save_setting("is_fullscreen", is_fullscreen)
	else:
		$MenuContainer/GraphicsMenu/Fullscreen.pressed = is_fullscreen

func set_nickname(nickname, save=true):
	if save:
		save_setting("nickname", nickname)
	else:
		$MenuContainer/MainMenu/Name.text = nickname

func debug_connection_status():
	if (get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTING):
		print("We are trying to connect")

func get_ip():
	return SERVER_IP

func get_port():
	return SERVER_PORT

func initialize_server(join=true):
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().connect("network_peer_connected", self, "on_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "on_peer_disconnected")
	get_tree().network_peer = peer
	
	initialize()
	
	if join:
		join_game()
		#add_player(peer.get_unique_id(), false)

func initialize_client():
	peer.create_client(SERVER_IP, SERVER_PORT)
	get_tree().connect("connected_to_server", self, "on_connection_established")
	get_tree().connect("connection_failed", self, "on_connection_failed")
	get_tree().network_peer = peer
	
	initialize()

func initialize():
	return_to_menu("MainMenu")
	
	#$MenuContainer/MainMenu/Connect.hide()
	#$MenuContainer/MainMenu/Disconnect.show()
	
	#close_menus()

func free_client():
	$MenuContainer/MainMenu/Connect.show()
	$MenuContainer/MainMenu/Disconnect.hide()
	
	for player in $Players.get_children():
		player.queue_free()
	
	for player_list_item in $PlayerListContainer/Panel/PlayerList.get_children():
		player_list_item.queue_free()
	
	peer.close_connection()
	
	get_tree().network_peer = null
	local_player = null
	
	return_to_menu("MainMenu")

func quit():
	get_tree().quit()

func get_player_data():
	var players =  $Players.get_children()
	
	var player_data = {}
	for player in players:
		var data = {}
		data["nickname"] = player.nickname
		data["char_class"] = player.player_class
		
		player_data[player.name] = data
	
	return player_data

func get_character_scene(character_name):
	var path = "res://Assets/Characters/" + character_name + "/" + character_name + ".tscn"
	var packed_character = load(path)
	return packed_character

remote func check_players(player_data):
	for player_name in player_data:
		var data = player_data[player_name]
		
		if $Players.has_node(player_name):
			var p = $Players.get_node(player_name)
			if data["char_class"] != p.player_class:
				$Players.remove_child(p)
		
		if not $Players.has_node(player_name):
			var player = get_character_scene(data["char_class"]).instance()
			
			player.name = player_name
			player.set_network_master(int(player_name))
			
			$Players.add_child(player)
			player.translation += Vector3(0.0, 3.0, 0.0)
			
			player.set_nickname(data["nickname"])
			
			on_player_added(player)
			
			print(player.player_class)

func join_game():
	var player = player_scene.instance()
	
	set_local_player(player)
	
	open_menu("CharacterSelectScreen")

sync func spawn(player_id):
	var spawning_player = $Players.get_node(str(player_id))
	
	$Level.show()
	
	spawning_player.spawn()
	spawning_player.show()
	close_menus()

func on_player_added(player):
	var player_list_item = preload("res://PlayerListItem.tscn").instance()
	$PlayerListContainer/Panel/PlayerList.add_child(player_list_item)
	player_list_item.player = player

sync func remove_player(id):
	for player_list_item in $PlayerListContainer/Panel/PlayerList.get_children():
		if player_list_item.network_id == str(id):
			player_list_item.queue_free()
	
	for player in $Players.get_children():
		if player.name == str(id):
			player.queue_free()

func get_spawn_point():
	return $Level/SpawnPoint

func on_peer_connected(id):
	print("Peer connected with id ", id)

master func set_player_data(player_data):
	check_players(player_data)
	
	var new_player_data = get_player_data()
	
	rpc("check_players", new_player_data)

func on_peer_disconnected(id):
	print("Peer disconnected with id ", id)
	
	rpc("remove_player", id)

func on_connection_established():
	print("connection_established")
	join_game()

func on_connection_failed():
	print("Connection has failed")
