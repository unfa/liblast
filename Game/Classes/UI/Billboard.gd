extends MeshInstance

# Called when the node enters the scene tree for the first time.
func _ready():
	var texture = $Viewport.get_texture()
	var material = SpatialMaterial.new()
	
	material.params_billboard_mode = SpatialMaterial.BILLBOARD_ENABLED
	material.flags_transparent = true
	material.flags_unshaded = true
	material.albedo_texture = texture
	
	set_surface_material(0, material)

func set_nickname(name):
	$Viewport/VBoxContainer/Nametag.text = name

sync func set_health(health):
	$Viewport/VBoxContainer/Health/HealthBar.value=health
