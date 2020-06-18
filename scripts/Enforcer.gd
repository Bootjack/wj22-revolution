class_name Enforcer
extends Character

var intimidation = 5.0
var intimidation_base_rate = 0.2
var lonely_threshold = 20.0
var discipline = 50.0
var discipline_base_rate = 0.2
var morale_computer:MoraleComputer

func get_class():
	return "Enforcer"

func is_class(name:String):
	return name == "Enforcer" || .is_class(name)

func _process(delta):
	#update_discipline(delta)
	update_intimidation(delta)

func suggest_destination(dest:Vector3, proximity_index:int):
	var distance_factor = 1.0
	var proximity_factor = 10.0
	# NOTE: This is likely the second time iterating through to find distnace
	# See if this could be optimized later
	var distance = global_transform.origin.distance_squared_to(dest)
	var threshold = distance * distance_factor + proximity_index * proximity_factor
	if (discipline > threshold):
		set_destination(dest)

func update_intimidation(delta):
	# By default, intimidation will slowly decrease
	var intimidation_delta = -2.0
	# Each neighbor increases intimidation by 1
	#for body in $InfluenceArea.get_overlapping_bodies():
	#	if (body != self && body.is_class("Enforcer")):
	#		intimidation_boost += body.intimidation
	var intimidation_boost = morale_computer.intimidation_at_location(global_transform.origin)
	intimidation_delta += intimidation_boost
	intimidation = clamp(intimidation + intimidation_delta * intimidation_base_rate, 0, 100)
