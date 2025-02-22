extends TileMap

signal clear_lines_signal(line_count: int, is_spin_move: bool, last_piece: String)

var piece_scene = preload("res://scene/piece.tscn")
var current_piece = piece_scene.instantiate()
var holding_piece = piece_scene.instantiate()

const HOLDING_PIECE_POSITION = Vector2i(-5, 2)
const QUEUE_POSITION = Vector2i(12, 0)

var board_length = 10
var board_height = 22
var queue_sight = 5
var paused = false
var inventory = []
var ghost_piece_enabled = true
var last_spin_distance = -1

enum layers { background, existing_tiles, ghost_piece, current_piece, HUD }


# Called when the node enters the scene tree for the first time.
func _process(delta):
	check_pause()
	if paused:
		return

	if ghost_piece_enabled:
		draw_ghost_piece()
	draw_current_piece()
	draw_HUD_piece()


func _ready():
	$PauseBlur.hide()
	current_piece.set_piece($PieceQueue.get_next_piece())
	$PieceDropTimer.start()
	Events.open_shop.emit()


func check_pause():
	if Input.is_action_just_pressed("pause"):
		if paused:
			unpause()
		else:
			pause()


func pause():
	paused = true
	$InputHandler.paused = true
	$PauseBlur.show()
	get_tree().call_group("gameplay_timers", "set_paused", 1)


func unpause():
	paused = false
	$PauseBlur.hide()
	$InputHandler.paused = false
	get_tree().call_group("gameplay_timers", "set_paused", 0)


func check_valid_tile(position: Vector2i) -> bool:
	return 0 <= position.x and position.x < board_length and 0 <= position.y and position.y < board_height and get_cell_source_id(1, position) == -1

#Check if whole piece is valid
func check_piece(piece) -> bool:
	var data = piece.get_tiles()
	for tile in data:
		if !check_valid_tile(tile[0]):
			return false

	return true


func move(direction: Vector2i) -> bool:
	var new_piece = current_piece.duplicate()
	new_piece.move(direction)
	if check_piece(new_piece):
		current_piece.move(direction)
		last_spin_distance = -1
		return true
	return false


func rotate_clockwise():
	var kick_list = current_piece.clockwise_kicktable[current_piece.current_rotation]
	for kick in kick_list:
		var new_piece = current_piece.duplicate()
		new_piece.move(Vector2i(kick[0], -kick[1]))
		new_piece.rotate_clockwise()
		if check_piece(new_piece):
			current_piece = new_piece
			last_spin_distance = abs(kick[0]) + abs(-kick[1]) 
			break


func rotate_counterclockwise():
	var kick_list = current_piece.counterclockwise_kicktable[current_piece.current_rotation]
	for kick in kick_list:
		var new_piece = current_piece.duplicate()
		new_piece.move(Vector2i(kick[0], -kick[1]))
		new_piece.rotate_counterclockwise()
		if check_piece(new_piece):
			current_piece = new_piece
			last_spin_distance = abs(kick[0]) + abs(kick[1]) 
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
			last_spin_distance = abs(kick[0]) + abs(kick[1]) 
			break


func lock_piece():
	var piece_tiles = current_piece.get_tiles()
	for cell in piece_tiles:
		set_cell(1, cell[0], 0, Vector2i(0, 0), cell[1])
	clear_lines()
	current_piece.set_piece($PieceQueue.get_next_piece())
	check_game_over()


func max_move(direction: Vector2i):
	while move(direction):
		pass

func hard_drop():
	max_move(Vector2i.DOWN)
	lock_piece()
	last_spin_distance = -1

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

# Update board when piece is locked. called in lock_piece, before getting new piece in queue. 
# Emmit signal about move, spin, and last piece
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

	clear_lines_signal.emit(count_lines_cleared, check_spin(), current_piece.piece_name)
	
	clear_layer(layers.existing_tiles)

	board.reverse()

	for i in board.size():
		for j in board_length:
			set_cell(layers.existing_tiles, Vector2i(j, board_height - 1 - i), 0, Vector2i(0, 0), board[i][j])
	


func get_score():
	return $Score.score()


func check_game_over():
	if not check_piece(current_piece):
		Events.game_over.emit()


func clear_HUD():
	for i in 4:
		for j in 4:
			set_cell(layers.HUD, HOLDING_PIECE_POSITION + Vector2i(i, j))

	for i in 30:
		for j in 30:
			set_cell(layers.HUD, QUEUE_POSITION + Vector2i(i, j))


func draw_HUD_piece():
	clear_HUD()
	draw_holding_piece()
	draw_piece_queue()

# gravity drop
func _on_piece_drop_timer_timeout():
	move(Vector2i.DOWN)

# Check if move is spin.
# If spin move by more than 3, is auto a spin
# T spin are checked as usual. For other pieces except I, return true if exist a tile above
func check_spin() -> bool:
	if last_spin_distance >= 3:
		return true
	if current_piece.piece_name == "T":
		var count = 0
		var corner_positions = [Vector2i(0, 0), Vector2i(0, 2), Vector2i(2, 0), Vector2i(2, 2)]
		for i in corner_positions:
			if not check_valid_tile(current_piece.position + i):
				count += 1
		return count >= 3 and last_spin_distance != -1
	else:
		if current_piece.piece_name == "O" or current_piece.piece_name == "I":
			return false
		else:
			var count = 0
			for i in current_piece.grid_size:
				for j in current_piece.grid_size:
					var pos = current_piece.position + Vector2i(j, i)
					if current_piece.grid[i][j] == 0 or (i >= 1 and current_piece.grid[i-1][j] == 1):
						continue
					if not check_valid_tile(pos + Vector2i.UP):
						count += 1
			print(count)
			print(last_spin_distance)
			return count >= 1 and last_spin_distance != -1
	return false
			
	
