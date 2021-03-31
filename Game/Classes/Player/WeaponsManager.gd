extends Spatial


# Store available weapons during runtime.
var weapons = []
var current_weapon_index
var active_weapon


func _ready():
	# Remove every child node and store them in the weapons array.
	for weapon in get_children():
		weapon.visible = true
		weapons.append(weapon)
		remove_child(weapon)

	# If we have at least one weapon, activate the first one.
	if weapons.size() > 0:
		_activate_weapon(0)

func _activate_weapon(index):
	current_weapon_index = index

	# Deactivate the current weapon.
	if active_weapon:
		remove_child(active_weapon)

	# Activate the requested weapon.
	active_weapon = weapons[index]
	add_child(active_weapon)

func switch_to_weapon(index):
	# Take a modulo here as a quick and easy way to have a valid index.
	_activate_weapon(index % weapons.size())
	return active_weapon

func next_weapon():
	current_weapon_index = (current_weapon_index + 1) % weapons.size()
	return switch_to_weapon(current_weapon_index)

func prev_weapon():
	current_weapon_index = (current_weapon_index - 1) % weapons.size()
	return switch_to_weapon(current_weapon_index)
