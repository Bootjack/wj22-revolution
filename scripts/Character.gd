class_name Character
extends RigidBody

var destination:Vector3 = Vector3.ZERO
var force:float = 100.0
var top_speed:float = 10.0
var urgency = 0.5

func _init():
	axis_lock_angular_x = true
	axis_lock_angular_z = true
	axis_lock_linear_y = true
	mass = 80

func _ready():
	# destination = global_transform.origin
	pass

func _process(delta):
	pass

func _physics_process(delta):
	var impulse = calculate_impulse(delta)
	apply_central_impulse(impulse)
	
func calculate_impulse(time_delta:float):
	var available_impulse = force * time_delta
	var velocity_delta = calculate_velocity_delta()
	var available_speed_delta = available_impulse / mass
	var speed = min(velocity_delta.length(), available_speed_delta)
	return mass * velocity_delta.normalized()
	
func calculate_velocity_delta():
	var destination_direction = global_transform.origin.direction_to(destination)
	var target_velocity = destination_direction * target_speed()
	return target_velocity - linear_velocity

func range_to_destination():
	return global_transform.origin.distance_to(destination)

func set_destination(dest:Vector3):
	destination = dest

func speed_toward_destination():
	var speed = linear_velocity.length()
	var alignment = linear_velocity.dot(destination)

func stopping_distance():
	var kinetic_energy = 0.5 * mass * linear_velocity.length_squared()
	return kinetic_energy / force

func target_speed():
	if (stopping_distance() >= range_to_destination()):
		return -top_speed
	else:
		return top_speed * urgency
