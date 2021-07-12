extends Control

var settings_filename = "user://settings.save"
var settings = {}

func _ready():
	if has_settings():
		load_settings()
		print(settings)

func has_settings():
	var filecheck = File.new()
	return filecheck.file_exists(settings_filename)

func save_settings():
	var file = File.new()
	file.open(settings_filename, File.WRITE)
	file.store_var(settings)
	file.close()

func load_settings():
	var file = File.new()
	file.open(settings_filename, File.READ)
	settings = file.get_var()
	file.close()

func quit_game():
	get_tree().quit()
