extends OmniLight

onready var base_energy = self.light_energy
onready var noise = OpenSimplexNoise.new()

export var speed = 100
export var noise_amount = 1.0

var time = 0

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	noise.octaves = 4
	noise.persistence = 0.5
	noise.period = 4


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	#self.light_energy = base_energy + (noise.get_noise_1d(time) * 10) - 0.5
	self.light_energy = base_energy + ((noise.get_noise_1d(time * speed) - 0.5) * noise_amount)
