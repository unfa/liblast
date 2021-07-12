extends "res://MenuItem.gd"

signal data_changed(data)

var data = null:
	set(_data):
		emit_signal("data_changed", _data)
		data = _data
		save_data()

func save_data():
	var GUI = get_parent().get_parent()
	
	GUI.settings[label] = data
	GUI.save_settings()
