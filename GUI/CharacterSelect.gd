extends Control

onready var game = get_parent().get_parent()

func _ready():
	var dir = Directory.new()
	dir.open("res://Assets/Characters/")
	dir.list_dir_begin()
	
	var file = dir.get_next()
	while file != "":
		if not file.begins_with("."):
			# Add character
			add_character(file)
		
		file = dir.get_next()

func add_character(character_name):
	var path = "res://Assets/Characters/" + character_name + "/" + character_name + ".tscn"
	var packed_character = load(path)
	
	var character_option = preload("res://GUI/CharacterOption.tscn").instance()
	$CenterContainer/VBoxContainer/CharacterList.add_child(character_option)
	character_option.set_character(packed_character)

func spawn():
	get_parent().get_parent().spawn(get_tree().get_network_unique_id())
