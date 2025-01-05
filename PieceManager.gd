extends Node

@export var piece_scene: PackedScene
@onready var current_piece = piece_scene.instantiate()

# Called when the node enters the scene tree for the first time.
func _ready():
	current_piece.set_piece("J")
	print(current_piece.grid)
	pass # Replace with function body.
	
# Draw data in the form of pairs (position, color(which is piece_id))
func get_current_piece_draw_data() -> Array:
	var draw_data = []	
	draw_data += current_piece.get_draw_data()
	
	return draw_data

# check if a position is in the board and empty
func move(direction):
	current_piece = current_piece.move(direction)

func rotate_clockwise():
	current_piece = current_piece.rotate_clockwise()
	
func rotate_counterclockwise():
	current_piece = current_piece.rotate_counterclockwise()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("rotate clockwise"):
		current_piece = current_piece.rotate_clockwise()
	if Input.is_action_just_pressed("rotate counterclockwise"):
		current_piece = current_piece.rotate_counterclockwise()
	pass
