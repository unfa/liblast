extends "res://MenuData.gd"

func on_label_changed():
	self.text = label

func on_toggle(button_pressed):
	data = button_pressed
