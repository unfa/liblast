extends Control

@export var filename = "user://settings.save"
var settings = {}

func _ready():
	if has_settings():
		load_settings()

func has_settings():
	return false

func save_settings():
	var file = File.new()
	file.open(filename, File.WRITE)
	file.store_var(settings)
	file.close()

func load_settings():
	var file = File.new()
	file.open(filename, File.READ)
	settings = file.get_var()
	file.close()

func quit_game():
	get_tree().quit()
