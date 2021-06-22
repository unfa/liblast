extends CharacterBody3D

@export var mouse_sensitivity := 0.35
#var speed := 15

@onready var hud = get_tree().root.find_node("HUD", true, false)
@onready var crosshair = hud.get_node("Crosshair")
@onready var vignette = hud.get_node("Vignette")
@onready var head = $Head
@onready var camera = $Head/Camera
@onready var tween = $Head/Camera/Tween

@onready var ground_check = $GroundCheck
@onready var climb_tween = $ClimbTween
@onready var climb_check = $ClimbCheck
@onready var body = $Body
@onready var mesh = $Mesh

@onready var weapon = $Head/Camera/Hand/Weapon

@onready var body_height = body.shape.height
@onready var body_y = body.position.y
@onready var mesh_height = mesh.mesh.mid_height
@onready var mesh_y = mesh.position.y
@onready var climb_check_y = climb_check.position.y
@onready var ground_check_y = ground_check.position.y

class PlayerInfo:
	var name: String
	var team: int
	var color: Color
	var focus: int #"res://Main.gd".GameFocus.GAME

	func _init(name: String, team: int, color: Color):
		self.name = name
		self.team = team
		self.color = color
		self.focus = 0 #false
		
	func serialize():
		return {
			'name': self.name,
			'team': str(self.team),
			'color': self.color.to_html(),
			'focus': self.focus,
		}

var input_active = false

var player_info: PlayerInfo

var base_fov = 90
var view_zoom := 1.0 :
	set(zoom):
		view_zoom = zoom
		camera.fov = base_fov / zoom
		crosshair.modulate.a = clamp(1 - (zoom - 1), 0, 1)
		vignette.modulate.a = (zoom - 1) / 3

var climb_height := 0.75
var climb_time := 0.15
var climb_state := 0.0 :
	set(factor):
		#print("climb_state is now ", factor)
		climb_state = factor
		body.shape.height = body_height - factor * climb_height
		body.position.y = body_y + factor * climb_height / 2
		
		mesh.mesh.mid_height = mesh_height - factor * climb_height
		mesh.position.y = mesh_y + factor * climb_height / 2
		
		ground_check.position.y = ground_check_y + factor * climb_height / 2
		climb_check.position.y = climb_check_y + factor * climb_height / 2

var direction := Vector3.ZERO
var accel := 0
var speed := 0
var medium = "ground"
var accel_type := {
	"ground": 12,
	"air": 1,
	"water": 4
	}
var speed_type := {
	"ground": 10,
	"air": 10,
	"water": 5
	}
var gravity := 28
var jump := 14

var velocity := Vector3.ZERO
var gravity_vec := Vector3.ZERO

@remotesync func set_info(info):
	player_info = PlayerInfo.new(info['name'], info['team'].to_int(), Color(info['color']))

@master func generate_info() -> void:
	var player_name = ""
	for i in range(0, 4):
		player_name += ['a','b','c', 'd', 'e', 'f'][randi() % 5]
	
	var color = Color(randf(),randf(),randf())
	rpc(&'set_info', PlayerInfo.new(player_name, 0, color).serialize() )

func _ready() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	view_zoom = 1.0
	
	generate_info()

	rpc_config(&"move_and_slide", MultiplayerAPI.RPC_MODE_PUPPETSYNC)
	rpc_config(&"aim", MultiplayerAPI.RPC_MODE_PUPPETSYNC)
	rpc_config(&"set_global_transform", MultiplayerAPI.RPC_MODE_PUPPET)
	rpc_config(&"set_linear_velocity", MultiplayerAPI.RPC_MODE_PUPPET)
	head.rpc_config(&"set_rotation", MultiplayerAPI.RPC_MODE_PUPPETSYNC)
	#rpc_config(&"set_info", MultiplayerAPI.RPC_MODE_PUPPETSYNC)
	
func aim(event) -> void:
	var mouse_motion = event as InputEventMouseMotion
	
	if mouse_motion:
		rotation_degrees.y -= mouse_motion.relative.x * mouse_sensitivity / view_zoom
		
		var current_tilt: float = head.rotation_degrees.x
		current_tilt -= mouse_motion.relative.y * mouse_sensitivity / view_zoom
		head.rotation_degrees.x = clamp(current_tilt, -90, 90)

func _input(event) -> void:
	if not input_active:
		return
	
	if Input.is_action_just_pressed("view_zoom"):
		tween.remove_all()
		tween.interpolate_property(self, "view_zoom", view_zoom, 4.0, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tween.start()
	
	if Input.is_action_just_released("view_zoom"):
		tween.remove_all()
		tween.interpolate_property(self, "view_zoom", view_zoom, 1.0, 0.25, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tween.start()
		
	rpc_unreliable(&'aim', event)
#	rpc(&'aim', event)
	
	if Input.is_action_just_pressed("trigger_primary"):
		weapon.rpc(&'trigger', 0, true)
	elif Input.is_action_just_released("trigger_primary"):
		weapon.rpc(&'trigger', 0, false)
	if Input.is_action_just_pressed("trigger_secondary"):
		weapon.rpc(&'trigger', 1, true)
	elif Input.is_action_just_released("trigger_secondary"):
		weapon.rpc(&'trigger', 1, false)
	
func _physics_process(delta):
	rpc_unreliable(&'set_global_transform', global_transform)
	head.rpc_unreliable(&'set_rotation', head.get_rotation())
#	rpc(&'set_global_transform', global_transform)
#	head.rpc(&'set_rotation', head.get_rotation())
	
	direction = Vector3.ZERO
	
	if is_on_floor() and ground_check.is_colliding():
		snap = -get_floor_normal()
		medium = "ground"
		gravity_vec = Vector3.ZERO
	else:
		snap = Vector3.DOWN
		medium = "air"
		gravity_vec += Vector3.DOWN * gravity * delta
		
	if input_active:
		if Input.is_action_just_pressed("move_jump") and is_on_floor():
			snap = Vector3.ZERO
			gravity_vec = Vector3.UP * jump
		
		if Input.is_action_pressed("move_forward"):
			direction -= transform.basis.z
		if Input.is_action_pressed("move_backward"):
			direction += transform.basis.z
		if Input.is_action_pressed("move_left"):
			direction -= transform.basis.x
		if Input.is_action_pressed("move_right"):
			direction += transform.basis.x
	
	if direction.length() > 0: # normalized() will return a null
		direction = direction.normalized()
	
	speed = speed_type[medium]
	accel = accel_type[medium]
	
	velocity = velocity.lerp(direction * speed, accel * delta)
	
	linear_velocity = velocity + gravity_vec
	#slide = move_and_slide_with_snap(movement, snap, Vector3.UP)
	rpc_unreliable(&'set_linear_velocity', linear_velocity)
	rpc_unreliable(&"move_and_slide")
#	rpc(&'set_linear_velocity', linear_velocity)
#	rpc(&"move_and_slide")
	#move_and_slide()
	
	if not is_on_floor() and not ground_check.is_colliding(): # while in mid-air collisions affect momentum
		velocity.x = linear_velocity.x
		velocity.z = linear_velocity.z
		gravity_vec.y = linear_velocity.y
		
	# (stair) climbing
	
	if get_slide_count() > 1 and climb_check.is_colliding():
		#print("climb started at climb state: ", climb_state)
		var test_y = climb_height * (1 - climb_state)
		#print("test_y: ", test_y)
		var climb_test_start = global_transform.translated(Vector3(0, test_y, 0))
		var climb_test_step =  Vector3(0,0,-0.1).rotated(Vector3.UP, rotation.y)
		if not test_move(climb_test_start, climb_test_step): # no collision
			var step = climb_check.get_collision_point().y
			var start = global_transform.origin.y
#			print("step: ", step, " start: ", start)
			climb_state = clamp((step - start) / climb_height, 0, 1)
			global_transform.origin.y += climb_height * climb_state
			#print("climb state to start: ", climb_state)
#			print("Climb height: ", step - start, " Climb state: ", climb_state)
			climb_tween.remove_all()
			climb_tween.interpolate_property(self, "climb_state", climb_state, 0.0, climb_time, Tween.TRANS_CUBIC, Tween.EASE_IN)
			climb_tween.start()
