extends KinematicBody3D

@export var mouse_sensitivity := 0.35
@export var move_speed := 15

@onready var head = $Head
@onready var ground_check = $GroundCheck


var move_direction := Vector3.ZERO
var accel_h := 12
var accel_air := 1
var accel_ground := 12
var gravity := 28
var jump := 14

var vel_h := Vector3.ZERO
var movement := Vector3.ZERO
var gravity_vec := Vector3.ZERO
var ground_contact := false
var slide := Vector3.ZERO

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func aim(event) -> void:
	var mouse_motion = event as InputEventMouseMotion
	
	if mouse_motion:
		rotation_degrees.y -= mouse_motion.relative.x * mouse_sensitivity
		
		var current_tilt: float = head.rotation_degrees.x
		current_tilt -= mouse_motion.relative.y * mouse_sensitivity
		head.rotation_degrees.x = clamp(current_tilt, -90, 90)

func _input(event) -> void:
	
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	aim(event)
	
func _physics_process(delta):
	move_direction = Vector3.ZERO
	
	if ground_check.is_colliding():
		ground_contact = true
	else:
		ground_contact = false
	
	if not is_on_floor():
		gravity_vec += Vector3.DOWN * gravity * delta
		accel_h = accel_air
		print("AIR")
	elif is_on_floor() and ground_contact:
		accel_h = accel_ground
		print("FLOOR")
		gravity_vec = -get_floor_normal() * gravity
	else:
		print("OTHER")
		accel_h = accel_ground
		#gravity_vec = -get_floor_normal()
		gravity_vec = Vector3.DOWN * gravity * delta
		
	if Input.is_action_just_pressed("move_jump") and (is_on_floor() or ground_contact):
		gravity_vec = Vector3.UP * jump
	
	if Input.is_action_pressed("move_forward"):
		move_direction -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		move_direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		move_direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		move_direction += transform.basis.x
	
	if move_direction.length() > 0: # normalized() will return a null
		move_direction = move_direction.normalized()
	
	vel_h = vel_h.lerp(move_direction * move_speed, accel_h * delta)
	
	movement.z = vel_h.z + gravity_vec.z
	movement.x = vel_h.x + gravity_vec.x
	movement.y = gravity_vec.y
	
	slide = move_and_slide(movement, Vector3.UP, )
	
	if not is_on_floor():
		vel_h.x = slide.x
		vel_h.z = slide.z
		gravity_vec.y = slide.y
