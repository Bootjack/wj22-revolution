class_name CrowdNavigationComputer
extends Navigation

var elevation = 0.5
var grid_size = 1.0
var height = 20.0
var mat:SpatialMaterial
var obstacles = []
var obstacle_grid = []
var origin:Vector3
var width = 20.0

func get_class():
	return "CrowdNavigationComputer"

func is_class(name:String):
	return name == "CrowdNavigationComputer" || .is_class(name)

func _init():
	obstacle_grid = []
	obstacle_grid.resize(int(height / grid_size))
	for row in range(0, height, grid_size):
		obstacle_grid[row] = []
		obstacle_grid[row].resize(int(width / grid_size))

func _ready():
	global_transform.origin -= Vector3(width / 2.0, 0.0, height / 2.0)

	mat = SpatialMaterial.new()
	mat.albedo_color = Color(0.0, 1.0, 1.0, 0.5)
	mat.flags_transparent = true

func bucket_obstacles():
	for row in range(0, height, grid_size):
		for col in range(0, width, grid_size):
			obstacle_grid[row][col] = 0

	for obstacle in obstacles:
		var local_pos = obstacle - origin
		if (local_pos.x < width && local_pos.z < height):
			var row = int(local_pos.x / grid_size)
			var col = int(local_pos.z / grid_size)
			obstacle_grid[row][col] = 1

func build_array_mesh():
	var normals = []
	var uvs = []
	var vertices = []
	
	for row in range(0, height, grid_size):
		for col in range(0, width, grid_size):
			if (!cell_has_obstacle(row, col)):
				
				# Corner points clockwise from top-left
				var point_1 = Vector3(row, elevation, col)
				var point_2 = Vector3(row + grid_size, elevation, col)
				var point_3 = Vector3(row + grid_size, elevation, col + grid_size)
				var point_4 = Vector3(row, elevation, col + grid_size)
	
				# Upper-left triangle for this quad
				vertices.append(point_1)
				vertices.append(point_2)
				vertices.append(point_4)
				
				# Lower-right triangle for this quad
				vertices.append(point_2)
				vertices.append(point_3)
				vertices.append(point_4)

	$NavMeshInstance.navmesh.set_vertices(vertices)

	# The rest is simply for visualization at this point
	var mesh_arrays = []
	mesh_arrays.resize(ArrayMesh.ARRAY_MAX)
	mesh_arrays[ArrayMesh.ARRAY_VERTEX] = $NavMeshInstance.navmesh.get_vertices()

	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arrays)
	
	return mesh

func cell_has_obstacle(row, col):
	return obstacle_grid[row][col]

func navigate(from:Vector3, to:Vector3):
	var closest_local_from = get_closest_point(to_local(from))
	var closest_local_to = get_closest_point(to_local(to))
	var path = get_simple_path(closest_local_from, closest_local_to)
	var global_path_array = []
	for vector in path:
		global_path_array.append(to_global(vector))
	return PoolVector3Array(global_path_array)

func update_navmesh():
	var mesh = build_array_mesh()
	mesh.surface_set_material(0, mat)
	$Visualization.mesh = mesh

func update_obstacles(spatials:Array):
	obstacles = []
	for spatial in spatials:
		obstacles.append(spatial.global_transform.origin - global_transform.origin)
	bucket_obstacles()
	update_navmesh()
