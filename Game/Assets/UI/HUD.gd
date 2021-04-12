extends Control

func update_ammo(var weapon, var amount):
	$Weapon/VBoxContainer/RoundsClips.text = str(amount)

func updateHealth(health: int):
	$Health/HealthBar.value = health
	$Health/HealthBar/HealthText.text = String(health)

func update_crosshair(kill):
	$Crosshair.visible = true # visible
	#$Crosshair/HitConfirmation.activate(0.15, false)
	
	print("HUD: kill = ", kill)
	
	if kill:
		$Crosshair/HitConfirmation.activate(0.3, true)
	else:
		$Crosshair/HitConfirmation.activate(0.15, false)
