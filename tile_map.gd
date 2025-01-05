extends TileMap

var piece_scene = preload("res://piece.tscn")
var current_piece = piece_scene.instantiate()
var holding_piece = piece_scene.instantiate()

const HOLDING_PIECE_POSITION = Vector2i(-5, 2)
const QUEUE_POSITION = Vector2i(12, 0)

var board_length = 10
var board_height = 22
var queue_sight = 5

enum layers {background, existing_tiles, ghost_piece, current_piece, HUD}
# Called when the node enters the scene tree for the first time.
func _ready():
	current_piece.set_piece($PieceQueue.get_next_piece())
	$PieceDropTimer.start()
	pass # Replace with function body.
	
# check if tile is valid
func check_valid_tile(position: Vector2i) -> bool:
	return 0 <= position.x and position.x < board_length and 0 <= position.y and position.y < board_height and get_cell_source_id(1, position) == -1	

func check_piece(piece) -> bool:
	var data = piece.get_tiles()
	for tile in data:
		if !check_valid_tile(tile[0]):
			return false
	
	return true

func move(direction: Vector2i):
	print(direction)
	var new_piece = current_piece.duplicate()
	new_piece.move(direction)
	if check_piece(new_piece):
		current_piece.move(direction)
		
func rotate_clockwise():
	var kick_list = current_piece.clockwise_kicktable[current_piece.current_rotation]
	for kick in kick_list:
		var new_piece = current_piece.duplicate()
		new_piece.move(Vector2i(kick[0], -kick[1]))
		new_piece.rotate_clockwise()
		if check_piece(new_piece):
			current_piece = new_piece
			break
		
func rotate_counterclockwise():
	var kick_list = current_piece.counterclockwise_kicktable[current_piece.current_rotation]
	print(kick_list)
	print(current_piece.current_rotation)
	for kick in kick_list:
		var new_piece = current_piece.duplicate()
		new_piece.move(Vector2i(kick[0], -kick[1]))
		new_piece.rotate_counterclockwise()
		if check_piece(new_piece):
			current_piece = new_piece
			break

func rotate_180():
	var kick_list = current_piece._180_kicktable[current_piece.current_rotation]
	for kick in kick_list:
		var new_piece = current_piece.duplicate()
		new_piece.move(Vector2i(kick[0], -kick[1]))
		new_piece.rotate_counterclockwise()
		new_piece.rotate_counterclockwise()
		if check_piece(new_piece):
			current_piece = new_piece
			break

func lock_piece():
	var piece_tiles = current_piece.get_tiles()
	for cell in piece_tiles:
		set_cell(1, cell[0], 0, Vector2i(0, 0), cell[1])	
	current_piece.set_piece($PieceQueue.get_next_piece())
	print(current_piece.piece_name)
	clear_lines()

func max_move(direction: Vector2i):
	while(true):
		var new_piece = current_piece.duplicate()
		new_piece.move(direction)
		if check_piece(new_piece):
			current_piece = new_piece
		else:
			break

func hard_drop():
	max_move(Vector2i.DOWN)
	lock_piece()

func draw_piece_on_layer(piece, layer):
	var piece_tiles = piece.get_tiles()
	for cell in piece_tiles:
		set_cell(layer, cell[0], 0, Vector2i(0, 0), cell[1])

func hold_piece():
	if holding_piece.piece_id != 0:
		var new_holding_piece = current_piece.duplicate()
		new_holding_piece.reset_to_default()
		current_piece = holding_piece.duplicate()
		current_piece.reset_to_default()
		holding_piece = new_holding_piece
	else:
		holding_piece = current_piece.duplicate()
		holding_piece.reset_to_default()
		current_piece.set_piece($PieceQueue.get_next_piece())

func draw_ghost_piece():
	clear_layer(layers.ghost_piece)
	var old_piece = current_piece.duplicate()
	max_move(Vector2i.DOWN)
	draw_piece_on_layer(current_piece, layers.ghost_piece)
	current_piece = old_piece

func draw_current_piece():
	clear_layer(layers.current_piece)
	draw_piece_on_layer(current_piece, layers.current_piece)

func draw_holding_piece():
	holding_piece.position = HOLDING_PIECE_POSITION
	draw_piece_on_layer(holding_piece, layers.HUD)

func draw_piece_queue():
	var current_position = QUEUE_POSITION
	var piece_queue = $PieceQueue.get_top_queue(queue_sight)
	for piece_name in piece_queue:
		var piece = piece_scene.instantiate()
		piece.set_piece(piece_name)
		piece.position = current_position
		draw_piece_on_layer(piece, layers.HUD)
		current_position += Vector2i(0, piece.grid_size)
	pass

func clear_lines():
	var count_lines_cleared = 0
	var board = []
	for i in board_height:
		var row = []
		for j in board_length:
			row.append(get_cell_alternative_tile(layers.existing_tiles, Vector2i(j, i)))
		var full = true
		for color in row:
			if color == -1:
				full = false
		if not full:
			board.append(row)
		else:
			count_lines_cleared += 1
	
	clear_layer(layers.existing_tiles)
	
	board.reverse()
	
	for i in board.size():
		for j in board_length:
			set_cell(layers.existing_tiles, Vector2i(j, board_height - 1 - i), 0, Vector2i(0, 0), board[i][j])
			
	$Score.clear_lines(count_lines_cleared)

func draw_HUD_piece():
	clear_layer(layers.HUD)
	draw_holding_piece()
	draw_piece_queue()

func _process(delta):
	draw_current_piece()
	draw_ghost_piece()
	draw_HUD_piece()

func _on_piece_drop_timer_timeout():
	move(Vector2i.DOWN)
	
