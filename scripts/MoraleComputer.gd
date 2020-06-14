class_name MoraleComputer
extends Node

var grid_size = 1.0
var height = 20.0
var origin:Vector3
var protestors = []
var protestor_grid = []
var width = 20.0

func get_class():
	return "MoraleComputer"

func is_class(name:String):
	return name == "MoraleComputer" || .is_class(name)

func _init():
	protestor_grid = []
	protestor_grid.resize(int(height / grid_size))
	for row in range(0, height, grid_size):
		protestor_grid[row] = []
		protestor_grid[row].resize(int(width / grid_size))

func _ready():
	origin = -Vector3(width / 2.0, 0.0, height / 2.0)
	
func _process(delta):
	bucket_protestors()

func bucket_protestors():
	for row in range(0, height, grid_size):
		for col in range(0, width, grid_size):
			protestor_grid[row][col] = 0

	for protestor in protestors:
		var coords = world_to_grid(protestor.global_transform.origin)
		var row = coords[0]
		var col = coords[1]
		protestor_grid[row][col] += protestor.morale

func find_closest_peak(location:Vector3, threshold:float):
	var closest = location
	var closest_distance = 1000.0
	var candidate = 0.0
	var location_coords = world_to_grid(location)
	
	for row in range(0, height, grid_size):
		for col in range(0, width, grid_size):
			var current = row == location_coords[0] && col == location_coords[1]
			var grid_center = grid_to_world(row, col)
			var high_enough = protestor_grid[row][col] > threshold
			var distance = location.distance_to(grid_center)
			if (!current && high_enough && distance < closest_distance):
				candidate = protestor_grid[row][col]
				closest_distance = distance
				closest = grid_center
	return closest

func grid_to_world(row, col):
	var grid_center = Vector3(row + 0.5 * grid_size, 0.0, col + 0.5 * grid_size) + origin
	return grid_center

func update_protestors(pros:Array):
	protestors = pros

func world_to_grid(position:Vector3):
	position -= origin
	var row = int(position.x / grid_size)
	var col = int(position.z / grid_size)
	return [row, col]
