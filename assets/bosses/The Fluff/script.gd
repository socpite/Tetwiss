extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func boss_start(game):
	var tilemap: TileMap = game.get_node("TileMap")
	var cover_height: int = tilemap.board_height/2
	var cover_width: int = tilemap.board_length
	
	for i in cover_height:
		for j in cover_width:
			tilemap.set_cell(tilemap.layers.HUD, Vector2i(j, i + cover_height), 0, Vector2i(0, 0), 8)
	
	tilemap.clear_layer(tilemap.layers.ghost_piece)
	tilemap.ghost_piece_enabled = false

func boss_process(game):
	pass

func boss_end(game):
	var tilemap: TileMap = game.get_node("TileMap")
	var cover_height: int = tilemap.board_height/2
	var cover_width: int = tilemap.board_length
	
	for i in cover_height:
		for j in cover_width:
			tilemap.set_cell(tilemap.layers.HUD, Vector2i(j, i + cover_height))
	
	tilemap.clear_layer(tilemap.layers.ghost_piece)
	tilemap.ghost_piece_enabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
