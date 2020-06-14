class_name MovementComputer
extends Node

var destination:Vector3 = Vector3.ZERO
var energy_spent = 0.0
var force:float = 100.0
var top_speed:float = 10.0

var rigid:RigidBody

func get_class():
	return "MovementComputer"

func is_class(name:String):
	return name == "MovementComputer" || .is_class(name)

func calculate_impulse(time_delta:float):
	var available_impulse = force * time_delta
	var velocity_delta = calculate_velocity_delta()
	var available_speed_delta = available_impulse / rigid.mass
	var speed = min(velocity_delta.length(), available_speed_delta)
	return {
		"energy": 0.5 * rigid.mass * pow(speed, 2),
		"impulse": rigid.mass * velocity_delta.normalized()
	}
	
func calculate_velocity_delta():
	var destination_direction = rigid.global_transform.origin.direction_to(destination)
	var target_velocity = destination_direction * target_speed()
	return target_velocity - rigid.linear_velocity

func range_to_destination():
	return rigid.global_transform.origin.distance_to(destination)

func set_destination(dest:Vector3):
	destination = dest

func set_force(f:float):
	force = f

func set_rigid_body(body:RigidBody):
	rigid = body
	
func set_top_speed(s:float):
	top_speed = s

func speed_toward_destination():
	var speed = rigid.linear_velocity.length()
	var alignment = rigid.linear_velocity.dot(destination)

func stopping_distance():
	var kinetic_energy = 0.5 * rigid.mass * rigid.linear_velocity.length_squared()
	return kinetic_energy / force

func target_speed():
	if (stopping_distance() >= range_to_destination()):
		return 0
	else:
		return top_speed
