extends Control

onready var game = get_parent().get_parent()
var selected_character = null

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
	
	var character_option = preload("res://Classes/UI/CharacterOption.tscn").instance()
	$CenterContainer/VBoxContainer/CharacterList.add_child(character_option)
	
	character_option.set_character(packed_character)
	character_option.connect("character_selected", self, "character_selected", [character_name, packed_character])

func character_selected(character_name, packed_character):
	print(character_name)
	game.local_player = packed_character.instance()

func spawn():
	game.spawn(get_tree().get_network_unique_id())
