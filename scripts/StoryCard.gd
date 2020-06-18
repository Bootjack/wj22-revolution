extends Control

signal dismissed

var stories = {
	"day_01": "You have invited some friends to a protest at the local square."
}

func _ready():
	$ColorRect/Button.connect("pressed", self, "on_okay_pressed")
	
func on_okay_pressed():
	emit_signal("dismissed")

func set_text(key:String):
	$ColorRect/Text.text = stories[key]
