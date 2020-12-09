extends Control

onready var game = get_parent().get_parent()

func _ready():
	var dir = Directory.new()
	dir.open("res://Assets/Characters/")
	
	#$CenterContainer/VBoxContainer/CharacterList.add_child(null)

func spawn():
	get_parent().get_parent().spawn(get_tree().get_network_unique_id())
