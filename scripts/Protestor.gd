class_name Protestor
extends Character

var fear = 0.0
var fear_base_rate = 0.05
var mat:SpatialMaterial
var morale = 50.0
var morale_base_rate = 0.02
var morale_computer:MoraleComputer
var seeking = false
var selected = false
var suggested_destination:Vector3
var threshold_afraid = 40.0
var threshold_lonely = 50.0
var threshold_panic = 80.0
var threshold_saddened = 20.0

func get_class():
	return "Protestor"

func is_class(name:String):
	return name == "Protestor" || .is_class(name)

func _process(delta):
	
	if (selected):
		show_destination()
	else:
		hide_destination()
	
	update_fear(delta)
	update_morale(delta)
	update_urgency()

	seeking = global_transform.origin.distance_to(destination) > 2.0

	var acted = false

	if (!acted):
		acted = panic()
	if (!acted):
		acted = avoid_danger()
	if (!acted):
		acted = seek_morale()
	if (!acted):
		acted = wander()
	if (!acted):
		acted = comply_with_suggestion()

func avoid_danger():
	if (fear > threshold_panic):
		var panic_location = morale_computer.find_biggest_valley(global_transform.origin)
		if (panic_location):
			var panic_direction = panic_location.direction_to(global_transform.origin)
			var panic_destination = global_transform.origin + panic_direction * 5.0
			clear_suggested_destination()
			set_destination(panic_destination)
			return true

	if (!seeking && fear > threshold_afraid):
		var fear_destination = morale_computer.find_biggest_peak(global_transform.origin)
		if (fear_destination):
			set_destination(fear_destination)
			return true

	return false

func clear_suggested_destination():
	suggested_destination = Vector3.INF

func comply_with_suggestion():
	if (suggested_destination != Vector3.INF):
		set_destination(suggested_destination)
	return true

func hide_destination():
	$DestinationVisualization.visible = false

func panic():
	return false

func seek_morale():
	if (morale < threshold_saddened):
		var sad_dest = morale_computer.find_biggest_peak(global_transform.origin)
		if (sad_dest):
			clear_suggested_destination()
			set_destination(sad_dest)
			return true

	if (!seeking && morale < threshold_lonely):
		var morale_dest = morale_computer.find_closest_peak(global_transform.origin, 2.0 * morale)
		if (morale_dest):
			set_destination(morale_dest)
			return true
		
	return false

func set_destination(dest:Vector3):
	.set_destination(dest)

func set_shirt_color(val:float):
	var mat = $Meshes/Shirt.get_surface_material(0).duplicate()
	mat.set_shader_param("shirt_color", val)
	$Meshes/Shirt.set_surface_material(0, mat)

func show_destination():
	$DestinationVisualization.visible = true
	$DestinationVisualization.transform.origin = to_local(destination)

func suggest_destination(dest:Vector3, proximity_index:int):
	var distance_factor = 1.0
	var proximity_factor = 10.0
	# NOTE: This is likely the second time iterating through to find distnace
	# See if this could be optimized later
	var distance = global_transform.origin.distance_squared_to(dest)
	var threshold = distance * distance_factor + proximity_index * proximity_factor
	if (morale > threshold):
		suggested_destination = dest

func update_fear(delta):
	# By default, fear will slowly decrease
	var fear_delta = -10.0
	# Each enforcer increases fear by 1
	#for body in $InfluenceArea.get_overlapping_bodies():
	#	if (body != self && body.is_class("Enforcer")):
	#		intimidation += body.intimidation
	var intimidation = morale_computer.intimidation_at_location(global_transform.origin)
	fear_delta += intimidation * 0.5
	fear = clamp(fear + fear_delta * fear_base_rate, 0, 100)

func update_morale(delta):
	var fear_factor = 1.0
	# By default, morale will slowly drain
	var morale_delta = -10.0
	# Each neighbor improves morale by 1
	#for body in $InfluenceArea.get_overlapping_bodies():
	#	if (body != self && body.is_class("Protestor")):
	#		group_morale += body.morale
	var morale_boost = morale_computer.morale_at_location(global_transform.origin)
	if (morale_delta > 1):
		fear_factor = (100.0 - fear) / 100.0
	morale_delta += morale_boost * 0.5
	morale = clamp(morale + morale_delta * morale_base_rate * fear_factor, 0, 100)

func update_urgency():
	var urgency_floor = 0.1
	if (suggested_destination != Vector3.INF):
		urgency_floor = 0.5

	urgency = clamp((100 - morale + fear) / 100.0, urgency_floor, 1.0)

func wander():
	var wander_direction = Vector3.ZERO
	if (morale == 100.0 && rng.randf() > 0.99):
		var wander_avoid = morale_computer.find_biggest_valley(global_transform.origin)
		var wander_from = morale_computer.find_biggest_peak(global_transform.origin)
		if (wander_from):
			wander_direction = wander_from.direction_to(global_transform.origin)
		if (wander_avoid):
			wander_direction += wander_avoid.direction_to(global_transform.origin)
		var wander_dest = global_transform.origin + wander_direction.normalized() * rng.randf_range(1.0, 3.0)
		set_destination(wander_dest)
		return true
