class_name TerritoryTexture
extends Node2D

var width = 2048;
var height = 2048;
var image:Image
var texture:ImageTexture

func _init():
	image = Image.new()
	texture = ImageTexture.new()

func _process(_delta):
	update()

func _draw():
	image = Image.new()
	image.create(width, height, false, Image.FORMAT_RGB8)
	image.fill(Color.white);
	
	texture = ImageTexture.new()
	texture.create_from_image(image)
	draw_texture(texture, Vector2(0,0))
	draw_rect(Rect2(0,0, width/2,height/2), Color.red)
