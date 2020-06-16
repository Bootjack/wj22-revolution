class_name Character
extends RigidBody

var destination:Vector3 = Vector3.ZERO
var energy = 100.0
var force:float = 50.0
var movement_computer:MovementComputer
var top_speed:float = 5.0
var urgency = 0.5

func get_class():
	return "Character"

func is_class(name:String):
	return name == "Character" || .is_class(name)

func _init():
	axis_lock_angular_x = true
	axis_lock_angular_z = true
	axis_lock_linear_y = true
	mass = 80
	movement_computer = MovementComputer.new()
	movement_computer.set_force(force)
	movement_computer.set_rigid_body(self)

func _ready():
	pass

func _process(delta):
	movement_computer.set_top_speed(top_speed * urgency)

func _physics_process(delta):
	var movement = movement_computer.calculate_impulse(delta)
	energy -= movement["energy"]
	apply_central_impulse(movement["impulse"])

func set_destination(dest:Vector3):
	destination = dest
	movement_computer.set_destination(dest)

func set_skin_tone(val:float):
	var mat = $Meshes/Torso.get_surface_material(0).duplicate()
	mat.set_shader_param("skin_tone", val)
	$Meshes/Torso.set_surface_material(0, mat)
	$Meshes/Head.set_surface_material(0, mat)
	$Meshes/HandLeft.set_surface_material(0, mat)
	$Meshes/HandRight.set_surface_material(0, mat)
