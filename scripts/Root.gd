extends Spatial

var game_menu_scene
var game_menu_res = preload("res://scenes/GameMenu.tscn")
var main_menu_scene
var main_menu_res = preload("res://scenes/MainMenu.tscn")
var protest_scene
var protest_res = preload("res://scenes/Protest.tscn")
var today = 0
var total_days = 14

# Called when the node enters the scene tree for the first time.
func _ready():
	add_main_menu()
	add_game_menu()
	show_main_menu()
	
func _input(event):
	if (event.is_action_pressed("ui_menu") and protest_scene):
		toggle_game_menu()

func add_game_menu():
	game_menu_scene = game_menu_res.instance()
	add_child(game_menu_scene)
	game_menu_scene.connect("save_game", self, "on_save_game")
	game_menu_scene.connect("stop_game", self, "on_stop_game")
	game_menu_scene.visible = false

func add_main_menu():
	main_menu_scene = main_menu_res.instance()
	add_child(main_menu_scene)
	main_menu_scene.connect("start_game", self, "on_start_game")
	main_menu_scene.connect("quit_game", self, "on_quit_game")
	main_menu_scene.visible = false

func add_protest():
	protest_scene = protest_res.instance()
	add_child(protest_scene)
	protest_scene.connect("protest_ended", self, "on_protest_ended")
	hide_main_menu()

func hide_game_menu():
	game_menu_scene.visible = false

func hide_main_menu():
	main_menu_scene.visible = false

func on_protest_ended():
	remove_protest()
	show_main_menu()

func on_save_game():
	print("Saving game")

func on_start_game():
	add_protest()
	unpause_game()
	
func on_stop_game():
	pause_game()
	hide_game_menu()
	remove_protest()
	show_main_menu()

func on_quit_game():
	get_tree().quit()

func pause_game():
	get_tree().paused = true

func remove_protest():
	pause_game()
	remove_child(protest_scene)

func show_splash():
	pass

func show_main_menu():
	main_menu_scene.visible = true

func show_game_menu():
	game_menu_scene.visible = true

func toggle_game_menu():
	game_menu_scene.visible = !game_menu_scene.visible
	
	if (game_menu_scene.visible):
		pause_game()
	else:
		unpause_game()

func unpause_game():
	get_tree().paused = false
