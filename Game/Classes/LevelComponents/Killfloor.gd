extends Spatial

func on_player_enters(player):
	player.rpc("kill")
