extends Control

func updateHealth(health: int):
	$Health/HealthBar.value = health
	$Health/HealthBar/HealthText.text = String(health)
	
func updateCrosshair(visible: bool, hit: bool):
	$Crosshair.visible = visible
	if hit:
		$Crosshair/HitConfirmation.activate(0.2)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
