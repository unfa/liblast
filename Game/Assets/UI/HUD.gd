extends Control

func update_ammo(var weapon, var amount):
	$Weapon/VBoxContainer/RoundsClips.text = str(amount)

func updateHealth(health: int):
	$Health/HealthBar.value = health
	$Health/HealthBar/HealthText.text = String(health)

func update_crosshair(visible: bool, hit: bool):
	$Crosshair.visible = visible
	if hit:
		$Crosshair/HitConfirmation.activate(0.2)
