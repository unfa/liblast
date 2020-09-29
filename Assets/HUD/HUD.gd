extends Control

func updateHealth(health: int):
	$Health/HealthBar.value = health
	$Health/HealthBar/HealthText.text = String(health)
	
func updateCrosshair(visible: bool, hit: bool):
	$Crosshair.visible = visible
	if hit:
		$Crosshair/HitConfirmation.activate(0.2)
