extends Control

func spawn():
	get_parent().get_parent().spawn(get_tree().get_network_unique_id())
