# This script moves the shape up half the amount it shrinks when crouching
# This way the top of the capsule keeps the same relative position to the camera
# Moving the camera instead would cause a camera move when crouching in the air
# which is weird (I tested it).
#
# It also acts as a middleman to ensure crouching will work with all shape types

extends CollisionShape

var height: = 1.0 setget set_height, get_height

var _normal_height: float
var _normal_y: float

func _ready() -> void:
	_normal_y = translation.y

	match shape.get_class():
		"CapsuleShape":
			_normal_height = shape.height

		"BoxShape":
			_normal_height = shape.extents.z

		var another_class:
			push_error("Height logic not implemented for shape %s" % another_class)

func _process(delta: float) -> void:
	if _normal_height:
		# Using self. make so we call the setter even though we're inside the objecr
		translation.y = _normal_y + (_normal_height - self.height) / 2.0

func set_height(value: float) -> void:
	match shape.get_class():
		"CapsuleShape":
			shape.height = value

		"BoxShape":
			shape.extents.z = value

func get_height() -> float:
	match shape.get_class():
		"CapsuleShape":
			return shape.height

		"BoxShape":
			return shape.extents.z

		var _:
			return 0.0

