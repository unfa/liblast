extends KinematicBody3D

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

@onready var body_height = body.shape.height
@onready var body_y = body.translation.y
@onready var mesh_height = mesh.mesh.mid_height
@onready var mesh_y = mesh.translation.y
@onready var climb_check_y = climb_check.translation.y
@onready var ground_check_y = ground_check.translation.y


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
		body.translation.y = body_y + factor * climb_height / 2
		
		mesh.mesh.mid_height = mesh_height - factor * climb_height
		mesh.translation.y = mesh_y + factor * climb_height / 2
		
		ground_check.translation.y = ground_check_y + factor * climb_height / 2
		climb_check.translation.y = climb_check_y + factor * climb_height / 2

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
var movement := Vector3.ZERO
var gravity_vec := Vector3.ZERO
var slide := Vector3.ZERO
var snap := Vector3.ZERO

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	view_zoom = 1.0

func aim(event) -> void:
	var mouse_motion = event as InputEventMouseMotion
	
	if mouse_motion:
		rotation_degrees.y -= mouse_motion.relative.x * mouse_sensitivity / view_zoom
		
		var current_tilt: float = head.rotation_degrees.x
		current_tilt -= mouse_motion.relative.y * mouse_sensitivity / view_zoom
		head.rotation_degrees.x = clamp(current_tilt, -90, 90)

func _input(event) -> void:
	
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	if Input.is_action_just_pressed("view_zoom"):
		tween.remove_all()
		tween.interpolate_property(self, "view_zoom", view_zoom, 4.0, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tween.start()
	
	if Input.is_action_just_released("view_zoom"):
		tween.remove_all()
		tween.interpolate_property(self, "view_zoom", view_zoom, 1.0, 0.25, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tween.start()
		
	aim(event)
	
func _physics_process(delta):
	direction = Vector3.ZERO
	
	if is_on_floor() and ground_check.is_colliding():
		snap = -get_floor_normal()
		medium = "ground"
		gravity_vec = Vector3.ZERO
	else:
		snap = Vector3.DOWN
		medium = "air"
		gravity_vec += Vector3.DOWN * gravity * delta
		
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
	
	movement = velocity + gravity_vec
	
	slide = move_and_slide_with_snap(movement, snap, Vector3.UP)
	
	if not is_on_floor() and not ground_check.is_colliding(): # while in mid-air collisions affect momentum
		velocity.x = slide.x
		velocity.z = slide.z
		gravity_vec.y = slide.y
		
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
			global_transform.origin.y += climb_height * climb_state * 2
			climb_state = clamp((step - start) / climb_height, 0, 1)
			#print("climb state to start: ", climb_state)
#			print("Climb height: ", step - start, " Climb state: ", climb_state)
			climb_tween.remove_all()
			climb_tween.interpolate_property(self, "climb_state", climb_state, 0.0, climb_time, Tween.TRANS_CUBIC, Tween.EASE_IN)
			climb_tween.start()
