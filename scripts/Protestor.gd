class_name Protestor
extends Character

var mat:SpatialMaterial
var morale = 10.0
var morale_base_rate = 0.1
var protestors = []

func get_class():
	return "Protestor"

func is_class(name:String):
	return name == "Protestor" || .is_class(name)

func _ready():
	pass

func _process(delta):
	update_morale(delta)
	#mat.emission_energy = clamp(morale - 80.0, 0.0, 20.0) / 100.0

func set_shirt_color(val:float):
	var mat = $Meshes/Shirt.get_surface_material(0).duplicate()
	mat.set_shader_param("shirt_color", val)
	$Meshes/Shirt.set_surface_material(0, mat)

func suggest_destination(dest:Vector3, proximity_index:int):
	var distance_factor = 2.0
	var proximity_factor = 20.0
	# NOTE: This is likely the second time iterating through to find distnace
	# See if this could be optimized later
	var distance = global_transform.origin.distance_squared_to(dest)
	var threshold = distance * distance_factor + proximity_index + proximity_factor
	if (morale > threshold):
		set_destination(dest)

func update_morale(delta):
	var neigbors = 0
	var morale_delta = -2.0
	for body in $InfluenceArea.get_overlapping_bodies():
		if (body.is_class("Protestor")):
			neigbors += 1
	morale_delta += neigbors
	morale = min(100, morale + morale_delta * morale_base_rate)
