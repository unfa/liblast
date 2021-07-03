extends Node

func _ready():
	print("Starting Liblast server")
	$Main.start_dedicated_server()
