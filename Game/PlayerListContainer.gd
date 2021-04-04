extends CenterContainer

var tracked_players = []

func update_player_list():
	var players = get_parent().get_node("Players").get_children()
	
	for child in $Panel/PlayerList.get_children():
		$Panel/PlayerList.remove_child(child)
	
	for player in players:
		var player_list_item = preload("res://Classes/UI/PlayerListItem.tscn").instance()
		$Panel/PlayerList.add_child(player_list_item)
		player_list_item.player = player
	
