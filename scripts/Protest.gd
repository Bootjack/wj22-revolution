extends Spatial

signal protest_ended

var latitude = 0.2 * PI
var protestor_res = preload("res://scenes/Protestor.tscn")
var protestors = []
var ray:RayCast
var rng = RandomNumberGenerator.new()
var size:int = 5
var suggested_location:Vector3
var time_computer:TimeComputer
var sunrise_time = 5.5 * 60 * 60
var sunset_time = 20.5 * 60 * 60

func _ready():
	ray = RayCast.new()
	ray.enabled = true
	add_child(ray)
	
	rng.randomize()

	for p in range(0, size):
		add_protestor()
	
	time_computer = TimeComputer.new()
	add_child(time_computer)
	time_computer.connect("curfew_reached", self, "on_curfew_reached")
	$TimeDisplay.set_time_computer(time_computer)

func _process(delta):
	var daytime = sunset_time - sunrise_time
	var since_sunrise = time_computer.current_time - sunrise_time
	var time_weight = since_sunrise / daytime
	var angle = lerp(PI, 2.0 * PI, time_weight)
	$Sun.rotation = Vector3(angle, 0.5 * PI, latitude)

func _input(event):
	if (event.is_action_pressed("select_location")):
		on_select_location(event)

func on_curfew_reached():
	emit_signal("protest_ended")

func add_protestor():
	var protestor = protestor_res.instance()
	protestor.energy = rand_range(80, 100)
	protestor.force = rand_range(30, 60)
	protestor.mass = rand_range(65, 90)
	protestor.protestors = protestors
	protestor.top_speed = rand_range(3, 6)
	protestors.append(protestor)
	add_child(protestor)

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

func protestor_proximity_sorter(a:Protestor, b:Protestor):
	var distance_a = a.global_transform.origin.distance_to(suggested_location)
	var distance_b = b.global_transform.origin.distance_to(suggested_location)
	return distance_a < distance_b
