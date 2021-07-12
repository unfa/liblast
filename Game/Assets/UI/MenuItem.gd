extends Control

@export var label = "":
	set(_label):
		label = _label
		on_label_changed()
	get:
		return label

func on_label_changed():
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
