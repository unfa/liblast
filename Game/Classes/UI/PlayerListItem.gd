extends HBoxContainer

var player setget set_player
var network_id

func set_player(_player):
	$Nickname.text = _player.nickname
	$Score.text = String(_player.player_stats.score)
	network_id = _player.name
