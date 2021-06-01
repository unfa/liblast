extends VBoxContainer

var previous_menu : Node = null

# Called when the node enters the scene tree for the first time.
func _ready():
	if previous_menu == null:
		$Back.hide()

func open_menu(path : String):
	var menu = load(path).instance()
	menu.previous_menu = self
	get_parent().add_child(menu)
	hide()

func go_back():
	previous_menu.show()
	previous_menu = null
	queue_free()
