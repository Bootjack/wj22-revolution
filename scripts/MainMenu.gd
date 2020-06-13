extends Control

signal start_game
signal quit_game

func _ready():
	$ButtonContainer/StartButton.connect("pressed", self, "on_start_game")
	$ButtonContainer/QuitButton.connect("pressed", self, "on_quit_game")

func on_start_game():
	emit_signal("start_game")
	
func on_quit_game():
	emit_signal("quit_game")
