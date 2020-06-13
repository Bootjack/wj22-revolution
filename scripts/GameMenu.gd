extends Control

signal save_game
signal stop_game

func _ready():
	$ButtonContainer/SaveButton.connect("pressed", self, "on_save")
	$ButtonContainer/QuitButton.connect("pressed", self, "on_quit")

func on_save():
	emit_signal("save_game")

func on_quit():
	emit_signal("stop_game")
