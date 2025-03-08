extends Node2D
class_name GameBoard

## GameBoard class. Items/Bosses should modify the gameboard directly if needed, preferrably using methods

signal clear_lines_signal(line_count: int, is_spin_move: bool, last_piece: String)

var current_piece: Piece = Piece.new()
var holding_piece: Piece = Piece.new()

const HOLDING_PIECE_POSITION = Vector2i(-5, 2)
const QUEUE_POSITION = Vector2i(12, 0)

var board_length = 10
var board_height = 22
var queue_sight = 5
var paused = false
var inventory = []
var ghost_piece_enabled = true
var last_spin_distance = -1
var already_hold = false
var maximum_height = 0

var layers

# Called when the node enters the scene tree for the first time.
func _process(delta):
	check_pause()
	if paused:
		return

	update_maximum_height()

	if ghost_piece_enabled:
		draw_ghost_piece()
	draw_current_piece()
	draw_HUD_piece()
	


func _ready():
	$PauseBlur.hide()
	reset_piece()
	
	layers = {
		background = $TileMapLayers/Background,
		existing_tiles = $TileMapLayers/ExistingTiles,
		ghost_piece = $TileMapLayers/GhostPiece,
		current_piece = $TileMapLayers/CurrentPiece,
		HUD = $TileMapLayers/HUD,
	}

## Interface item/boss ease of use
func set_cell(layer: TileMapLayer, coords: Vector2i, source_id: int = -1, atlas_coords: Vector2i = Vector2i(-1, -1), alternative_tile: int = 0):
	layer.set_cell(coords, source_id, atlas_coords, alternative_tile)

## Interface item/boss ease of use
func clear_layer(layer: TileMapLayer):
	layer.clear()

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
	return 0 <= position.x and position.x < board_length and -2 <= position.y and position.y < board_height and layers.existing_tiles.get_cell_source_id(position) == -1


#Check if whole piece is valid
func check_piece(piece) -> bool:
	var data = piece.get_tiles()
	for tile in data:
		if !check_valid_tile(tile[0]):
			return false

	return true


func move(direction: Vector2i, silent = true) -> bool:
	var new_piece = current_piece.duplicate()
	new_piece.move(direction)
	if check_piece(new_piece):
		if !silent:
			$MoveAudio.play()
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
			if check_spin():
				$SpinAudio.play()
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
			if check_spin():
				$SpinAudio.play();
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
			if check_spin():
				$SpinAudio.play();
			break


#reset variables associated with each piece
func reset_piece():
	$PieceDropTimer.stop()
	$PieceDropTimer.start()
	
	$AutoLockTimer.stop()
	$AutoLockTimer.start()
	maximum_height = 0
	
	already_hold = false
	
	last_spin_distance = -1
	
	
	current_piece.set_piece($PieceQueue.get_next_piece())


func lock_piece():
	draw_piece_on_layer(current_piece, layers.existing_tiles)
	clear_lines()
	reset_piece()
	check_game_over()


func max_move(direction: Vector2i, silent = true):
	while move(direction, silent):
		pass


func hard_drop():
	max_move(Vector2i.DOWN, false)
	lock_piece()
	last_spin_distance = -1


func draw_piece_on_layer(piece: Piece, layer: TileMapLayer):
	var piece_tiles = piece.get_tiles()
	for cell in piece_tiles:
		layer.set_cell(cell[0], 0, Vector2i(0, 0), cell[1])

func hold_piece():
	if already_hold == true:
		return
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
	already_hold = true


func draw_ghost_piece():
	layers.ghost_piece.clear()
	var old_piece = current_piece.duplicate()
	max_move(Vector2i.DOWN)
	draw_piece_on_layer(current_piece, layers.ghost_piece)
	current_piece = old_piece


func draw_current_piece():
	layers.current_piece.clear()
	draw_piece_on_layer(current_piece, layers.current_piece)


func draw_holding_piece():
	holding_piece.position = HOLDING_PIECE_POSITION
	draw_piece_on_layer(holding_piece, layers.HUD)


func draw_piece_queue():
	var current_position = QUEUE_POSITION
	var piece_queue = $PieceQueue.get_top_queue(queue_sight)
	for piece_name in piece_queue:
		var piece: Piece = Piece.new()
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
			row.append(layers.existing_tiles.get_cell_alternative_tile(Vector2i(j, i)))
		var full = true
		for color in row:
			if color == -1:
				full = false
		if not full:
			board.append(row)
		else:
			count_lines_cleared += 1

	clear_lines_signal.emit(count_lines_cleared, check_spin(), current_piece.piece_name)

	layers.existing_tiles.clear()

	board.reverse()

	for i in board.size():
		for j in board_length:
			layers.existing_tiles.set_cell(Vector2i(j, board_height - 1 - i), 0, Vector2i(0, 0), board[i][j])


func get_score():
	return $Score.score()


func check_game_over():
	if not check_piece(current_piece):
		Events.game_over.emit()


func clear_HUD():
	for i in 4:
		for j in 4:
			layers.HUD.set_cell(HOLDING_PIECE_POSITION + Vector2i(i, j))

	for i in 30:
		for j in 30:
			layers.HUD.set_cell(QUEUE_POSITION + Vector2i(i, j))


func draw_HUD_piece():
	clear_HUD()
	draw_holding_piece()
	draw_piece_queue()


# gravity drop
func _on_piece_drop_timer_timeout():
	move(Vector2i.DOWN)


# Check if 3 corners are filled
func check_t_spin() -> bool:
	var count = 0
	var corner_positions = [Vector2i(0, 0), Vector2i(0, 2), Vector2i(2, 0), Vector2i(2, 2)]
	for i in corner_positions:
		if not check_valid_tile(current_piece.position + i):
			count += 1
	return count >= 3 and last_spin_distance != -1


# Check if there is a tile above one of the piece tiles
func check_other_spin() -> bool:
	var count = 0
	for i in current_piece.grid_size:
		for j in current_piece.grid_size:
			var pos = current_piece.position + Vector2i(j, i)
			if current_piece.grid[i][j] == 0 or (i >= 1 and current_piece.grid[i - 1][j] == 1):
				continue
			if not check_valid_tile(pos + Vector2i.UP):
				count += 1
	return count >= 1 and last_spin_distance != -1


func check_spin() -> bool:
	if last_spin_distance >= 3:
		return true
	if current_piece.piece_name == "O" or current_piece.piece_name == "I":
		return false
	if current_piece.piece_name == "T":
		return check_t_spin()
	else:
		return check_other_spin()


func update_maximum_height():
	if current_piece.position.y > maximum_height:
		$AutoLockTimer.stop()
		$AutoLockTimer.start()
		maximum_height = current_piece.position.y
		print(maximum_height)

func auto_lock():
	hard_drop()
