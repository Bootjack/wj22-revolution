extends Spatial

signal protest_ended

func _ready():
	$Timer.connect("curfew_reached", self, "on_curfew_reached")
	
func on_curfew_reached():
	emit_signal("protest_ended")
