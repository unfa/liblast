extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func play():
	$A/SoundPlayer.play()
	$B/SoundPlayer.play()
	$C/SoundPlayer.play()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
