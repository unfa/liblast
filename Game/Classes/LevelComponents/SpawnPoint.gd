extends Spatial

# Move the player to the starting location.
func spawn(player: Player):
	# Set the player's position and rotation to our position and rotation.
	player.global_transform = global_transform
