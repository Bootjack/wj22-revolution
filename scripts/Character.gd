class_name Character
extends RigidBody

var destination:Vector3 = Vector3.ZERO
var force:float = 100.0
var movement_computer:MovementComputer
var top_speed:float = 10.0
var urgency = 0.5

func _init():
	axis_lock_angular_x = true
	axis_lock_angular_z = true
	axis_lock_linear_y = true
	mass = 80
	movement_computer = MovementComputer.new()
	movement_computer.set_force(force)
	movement_computer.set_rigid_body(self)

func _ready():
	# destination = global_transform.origin
	pass

func _process(delta):
	movement_computer.set_top_speed(top_speed * urgency)

func _physics_process(delta):
	var impulse = movement_computer.calculate_impulse(delta)
	apply_central_impulse(impulse)

func set_destination(dest:Vector3):
	destination = dest
	movement_computer.set_destination(dest)
