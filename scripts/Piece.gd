extends Node

@export var grid: Array
@export var grid_size: int
@export var position: Vector2i
@export var piece_id = 0
@export var piece_name: String
@export var current_rotation: int
@export var clockwise_kicktable: Array
@export var counterclockwise_kicktable: Array
@export var spawn_position = Vector2i(4, 0)
@export var _180_kicktable: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_piece(_piece_name: String):
	piece_name = _piece_name
	piece_id = Data.piece_data[piece_name]["piece_id"]
	
	position = Vector2i(4, 0)
	
	grid = Data.piece_data[piece_name]["grid"]
	grid_size = Data.piece_data[piece_name]["grid_size"]
	
	current_rotation = 0
	
	clockwise_kicktable = Data.piece_data[piece_name]["clockwise_kicktable"]
	counterclockwise_kicktable = Data.piece_data[piece_name]["counterclockwise_kicktable"]
	_180_kicktable = Data.piece_data[piece_name]["180_kicktable"]
	
func set_random_piece():
	set_piece(Data.piece_data.keys().pick_random())

func reset_to_default():
	current_rotation = 0
	grid = Data.piece_data[piece_name]["grid"]
	position = spawn_position

func rotate_counterclockwise():
	current_rotation += 3
	current_rotation %= 4
	var new_piece = self.duplicate()
	for i in new_piece.grid_size:
		for j in new_piece.grid_size:
			new_piece.grid[i][j] = grid[j][grid_size - i - 1]
			
	grid = new_piece.grid

func rotate_clockwise():
	for i in 3:
		rotate_counterclockwise()

# Draw data in the form of pairs (position, color(which is piece_id))
func get_tiles() -> Array:
	var draw_data = []
	for i in grid_size:
		for j in grid_size:
			if grid[i][j]:
				draw_data.append([Vector2i(j, i) + position, piece_id])
	
	return draw_data
	
func clone():
	return self.duplicate()

func move(direction):
	position += direction

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
