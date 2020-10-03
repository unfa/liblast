extends HBoxContainer

var player setget set_player
var network_id

func set_player(player):
	$Nickname.text = player.nickname
	network_id = player.name
