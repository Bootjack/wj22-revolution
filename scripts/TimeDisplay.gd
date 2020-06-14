class_name TimeDisplay
extends Control

var label:Label
var time_computer:TimeComputer

func get_class():
	return "TimeDisplay"

func is_class(name:String):
	return name == "TimeDisplay" || .is_class(name)

func _ready():
	label = get_node("Label")

func _process(delta):
	if (time_computer):
		label.text = time_computer.format_time()
	
func set_time_computer(t:TimeComputer):
	time_computer = t
