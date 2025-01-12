extends Node
# Called when the node enters the scene tree for the first time.

var game_scene = preload("res://scene/tile_map.tscn")


func _ready():
	Events.open_shop.connect(open_shop)
	Events.game_over.connect(_on_game_over)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_game_over():
	$Menu.show()
	get_node("TileMap").queue_free()


func _on_play_button_pressed():
	add_child(game_scene.instantiate())
	$Menu.hide()


func open_shop():
	pass
