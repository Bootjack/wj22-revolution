class_name TimeComputer
extends Node

signal curfew_reached

const default_curfew_time = 19.0 * 60.0 * 60
const default_start_time = 9.0 * 60.0 * 60

var curfew_time
var current_time
var timescale = 5.0 * 60.0 # 1 minute : 5 hours

func get_class():
	return "TimeComputer"

func is_class(name:String):
	return name == "TimeComputer" || .is_class(name)

func _ready():
	curfew_time = default_curfew_time
	current_time = default_start_time

func _process(delta):
	current_time += delta * timescale
	if (current_time > curfew_time):
		emit_signal("curfew_reached")

func format_time() -> String:
	var hours = int(floor(current_time / (60 * 60))) % 24
	var minutes = int(floor(current_time / 60)) % 60
	minutes = floor(minutes / 5) * 5
	var time = "%02d:%02d" % [hours, minutes]
	return time

func set_curfew(minutes:float):
	curfew_time = minutes

func set_time(minutes:float):
	current_time = minutes
