extends Node
# Called when the node enters the scene tree for the first time.

var game_scene = preload("res://scene/game.tscn")
var shop_scene = preload("res://scene/shop.tscn")

func _ready():
	Events.open_shop.connect(open_shop)
	Events.close_shop.connect(close_shop)
	Events.game_over.connect(_on_game_over)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_game_over():
	$Menu.show()
	get_node("Game").queue_free()


func _on_play_button_pressed():
	add_child(game_scene.instantiate())
	$Menu.hide()


func open_shop():
	get_node("Game").pause()
	add_child(shop_scene.instantiate())
	
func close_shop():
	get_node("Game").unpause()
	get_node("Shop").queue_free()
