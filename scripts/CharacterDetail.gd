class_name CharacterDetail
extends Control

var character:Character
var fear_progress:ProgressBar
var morale_progress:ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready():
	fear_progress = $PanelContainer/MarginContainer/VBoxContainer/FearStatus/Progress
	morale_progress = $PanelContainer/MarginContainer/VBoxContainer/MoraleStatus/Progress

func _process(delta):
	if (character):
		visible = true
		fear_progress.value = character.fear
		morale_progress.value = character.morale
	else:
		visible = false
