extends Control

var main_menu
var main_menu_res = preload("res://MainMenu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	show_main_menu()

func add_main_menu():
	if (!main_menu):
		main_menu = main_menu_res.instance()
		add_child(main_menu)
		main_menu.connect("start_game", self, "on_start_game")
		main_menu.connect("quit_game", self, "on_quit_game")
		
func on_start_game():
	pass

func on_quit_game():
	get_tree().quit()

func show_splash():
	pass

func show_main_menu():
	if (!main_menu):
		add_main_menu()
	main_menu.visible = true
