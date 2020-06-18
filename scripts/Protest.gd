extends Spatial

signal protest_ended
signal story_card_activated

var enforcer_res = preload("res://scenes/Enforcer.tscn")
var enforcers = []
var enforcement_size = 10
var latitude = 0.2 * PI
var mat:SpatialMaterial
var morale_computer:MoraleComputer
var protest_size:int = 10
var protestor_res = preload("res://scenes/Protestor.tscn")
var protestors = []
var ray:RayCast
var rng = RandomNumberGenerator.new()
var suggested_location:Vector3
var sunrise_time = 5.5 * 60 * 60
var sunset_time = 20.5 * 60 * 60
var territory_texture:TerritoryTexture
var time_computer:TimeComputer
var timer:Timer

func _ready():
	morale_computer = MoraleComputer.new()
	add_child(morale_computer)

	territory_texture = TerritoryTexture.new()
	mat = SpatialMaterial.new()
	mat.albedo_color = Color.white
	mat.albedo_texture = territory_texture.texture
	$Terrain/MeshInstance.material_override = mat
	
	ray = RayCast.new()
	ray.enabled = true
	add_child(ray)
	
	rng.randomize()

	for p in range(0, protest_size):
		add_protestor(p % 5 + 1)
	
	morale_computer.update_protestors(protestors)
	
	for e in range(0, enforcement_size):
		add_enforcer(e % 5 + 1)

	morale_computer.update_enforcers(enforcers)
	
	time_computer = TimeComputer.new()
	add_child(time_computer)
	time_computer.connect("curfew_reached", self, "on_curfew_reached")
	$TimeDisplay.set_time_computer(time_computer)
	
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.connect("timeout", self, "show_initial_story_card")
	timer.start(1)

func _process(delta):
	var daytime = sunset_time - sunrise_time
	var since_sunrise = time_computer.current_time - sunrise_time
	var time_weight = since_sunrise / daytime
	var angle = lerp(PI, 2.0 * PI, time_weight)
	$Sun.rotation = Vector3(angle, 0.5 * PI, latitude)

func _physics_process(delta):
	var selected_protestor = get_hovered_protestor()
	$CharacterDetail.character = selected_protestor
	pass

func _input(event):
	if (event.is_action_pressed("select_location")):
		on_select_location(event)

func on_curfew_reached():
	emit_signal("protest_ended")

func add_enforcer(i:int):
	var enforcer = enforcer_res.instance()
	enforcer.energy = rand_range(80, 100)
	enforcer.force = rand_range(50, 65)
	enforcer.mass = rand_range(85, 95)
	enforcer.morale_computer = morale_computer
	enforcer.nav_computer = $Navigation
	enforcer.phase = i
	enforcer.top_speed = rand_range(4, 5)
	enforcer.set_skin_tone(rng.randfn(0.8, 0.05))
	enforcers.append(enforcer)
	enforcer.global_transform.origin = position_in_area($EnforcerSpawnArea)
	add_child(enforcer)
	
func add_protestor(i:int):
	var protestor = protestor_res.instance()
	protestor.energy = rand_range(80, 100)
	protestor.force = rand_range(30, 60)
	protestor.mass = rand_range(65, 90)
	protestor.morale_computer = morale_computer
	protestor.nav_computer = $Navigation
	protestor.phase = i
	protestor.top_speed = rand_range(3, 7)
	protestor.set_skin_tone(rng.randfn(0.5, 0.2))
	protestor.set_shirt_color(rng.randfn(0.5, 0.2))
	protestors.append(protestor)
	protestor.global_transform.origin = position_in_area($ProtestorSpawnArea)
	add_child(protestor)

func get_hovered_protestor():
	for protestor in protestors:
		protestor.selected = false
	
	# cast a ray from camera at mouse position, and get the object colliding with the ray	var mouse_pos = get_viewport().get_mouse_position()
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_from = $Camera.project_ray_origin(mouse_pos)
	var ray_to = ray_from + $Camera.project_ray_normal(mouse_pos) * 1000
	var space_state = get_world().direct_space_state
	var selection = space_state.intersect_ray(ray_from, ray_to)
	var object = selection.get("collider")
	if (object && object.is_class("Protestor")):
		object.selected = true
		return object

func on_select_location(event):
	var camera = get_viewport().get_camera()
	var origin = camera.project_ray_origin(event.position)
	var normal = camera.project_ray_normal(event.position)
	ray.global_transform.origin = origin
	ray.cast_to = normal * 1000
	ray.force_update_transform()
	ray.force_raycast_update()
	suggested_location = ray.get_collision_point()

	protestors.sort_custom(self, "protestor_proximity_sorter")
	for i in protestors.size():
		protestors[i].suggest_destination(suggested_location, i)

func position_in_area(area:Area):
	var box = area.get_node("CollisionShape").shape
	var offset = Vector3(
		rng.randf_range(-1.0, 1.0) * box.extents.x,
		0.0,
		rng.randf_range(-1.0, 1.0) * box.extents.z
	)
	return area.global_transform.origin + offset

func protestor_proximity_sorter(a:Protestor, b:Protestor):
	var distance_a = a.global_transform.origin.distance_to(suggested_location)
	var distance_b = b.global_transform.origin.distance_to(suggested_location)
	return distance_a < distance_b

func show_initial_story_card():
	emit_signal("story_card_activated", "day_01")

func update_terrain_texture():
	mat.albedo_texture = territory_texture.texture
	$Terrain/MeshInstance.material_override = mat
