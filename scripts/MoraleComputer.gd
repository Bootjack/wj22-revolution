class_name MoraleComputer
extends Node

var enforcers = []
var enforcer_grid = []
var grid_size = 2.0
var height = 20.0
var mesh:MeshInstance
var origin:Vector3
var protestors = []
var protestor_grid = []
var width = 60.0

func get_class():
	return "MoraleComputer"

func is_class(name:String):
	return name == "MoraleComputer" || .is_class(name)

func _init():
	enforcer_grid = []
	enforcer_grid.resize(int(height / grid_size))
	for row in range(0, height / grid_size):
		enforcer_grid[row] = []
		enforcer_grid[row].resize(int(width / grid_size))
	
	protestor_grid = []
	protestor_grid.resize(int(height / grid_size))
	for row in range(0, height / grid_size):
		protestor_grid[row] = []
		protestor_grid[row].resize(int(width / grid_size))

func _ready():
	origin = -Vector3(width / 2.0, 0.0, height / 2.0)
	
func _process(delta):
	bucket_enforcers()
	bucket_protestors()

func bucket_enforcers():
	for row in range(0, height / grid_size):
		for col in range(0, width / grid_size):
			enforcer_grid[row][col] = 0

	for enforcer in enforcers:
		var coords = world_to_grid(enforcer.global_transform.origin)
		if coords:
			var row = coords[0]
			var col = coords[1]
			if (row < height && col < width):
				enforcer_grid[row][col] += enforcer.intimidation

func bucket_protestors():
	for row in range(0, height / grid_size):
		for col in range(0, width / grid_size):
			protestor_grid[row][col] = 0

	for protestor in protestors:
		var coords = world_to_grid(protestor.global_transform.origin)
		if coords:
			var row = coords[0]
			var col = coords[1]
			if (row < height / grid_size && col < width / grid_size):
				protestor_grid[row][col] += protestor.morale

func find_biggest_peak(location:Vector3):
	var biggest
	var biggest_value = 0.0
	var candidate = 0.0
	var location_coords = world_to_grid(location)
	
	if (!location_coords):
		return null

	for row in range(0, height / grid_size):
		for col in range(0, width / grid_size):
			var current = row == location_coords[0] && col == location_coords[1]
			var grid_center = grid_to_world(row, col)
			candidate = protestor_grid[row][col] - enforcer_grid[row][col]
			if (!current && candidate > biggest_value):
				biggest_value = candidate
				biggest = grid_center
	return biggest

func find_biggest_valley(location:Vector3):
	var biggest
	var biggest_value = 0.0
	var candidate = 0.0
	var location_coords = world_to_grid(location)

	if (!location_coords):
		return null

	for row in range(0, height / grid_size):
		for col in range(0, width / grid_size):
			var current = row == location_coords[0] && col == location_coords[1]
			var grid_center = grid_to_world(row, col)
			candidate = enforcer_grid[row][col]
			if (!current && candidate > biggest_value):
				biggest_value = candidate
				biggest = grid_center
	return biggest

func find_closest_peak(location:Vector3, threshold:float):
	var closest = location
	var closest_distance = 1000.0
	var candidate = 0.0
	var location_coords = world_to_grid(location)

	if (!location_coords):
		return null

	for row in range(0, height / grid_size):
		for col in range(0, width / grid_size):
			var current = row == location_coords[0] && col == location_coords[1]
			var grid_center = grid_to_world(row, col)
			var high_enough = (protestor_grid[row][col] - enforcer_grid[row][col]) > threshold
			var distance = location.distance_to(grid_center)
			if (!current && high_enough && distance < closest_distance):
				candidate = protestor_grid[row][col]
				closest_distance = distance
				closest = grid_center
	return closest

func grid_to_world(row, col):
	if (row < height && col < width):
		var grid_center = Vector3((col + 0.5) * grid_size, 0.0, (row + 0.5) * grid_size) + origin
		return grid_center

func intimidation_at_location(location:Vector3):
	var coords = world_to_grid(location)
	
	if !coords:
		return 0
	
	var row = coords[0]
	var col = coords[1]
	return enforcer_grid[row][col]

func morale_at_location(location:Vector3):
	var coords = world_to_grid(location)
	
	if !coords:
		return 0

	var row = coords[0]
	var col = coords[1]
	return protestor_grid[row][col]

func set_mesh(m:MeshInstance):
	mesh = m

func update_enforcers(enfos:Array):
	enforcers = enfos

func update_protestors(pros:Array):
	protestors = pros

func world_to_grid(position:Vector3):
	position -= origin
	var row = int(position.z / grid_size)
	var col = int(position.x / grid_size)
	if (row < height && col < width):
		return [row, col]
