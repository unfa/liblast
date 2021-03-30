extends HBoxContainer

var player setget set_player
var network_id

func set_player(_player):
	$Nickname.text = _player.nickname
	network_id = _player.name
