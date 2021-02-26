extends Node3D

func on_player_enters(player):
	player.rpc("kill")
