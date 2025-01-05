extends  Node

var piece_data = JSON.parse_string(FileAccess.open("res://assets/piece_data.json", FileAccess.READ).get_as_text())

func query(piece_name: String, data_name: String):
	return piece_data[piece_name][data_name]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
