extends Control

func update_ammo(var weapon, var amount):
	$Weapon/VBoxContainer/RoundsClips.text = str(amount)

func updateHealth(health: int):
	$Health/HealthBar.value = health
	$Health/HealthBar/HealthText.text = String(health)

func update_crosshair(visible: bool, hit: bool, kill: bool):
	$Crosshair.visible = visible
	if hit:
		$Crosshair/HitConfirmation.activate(0.15, false)
	elif kill:
		$Crosshair/HitConfirmation.activate(0.3, true)
