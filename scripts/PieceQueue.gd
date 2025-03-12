extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	gen_queue()
	pass # Replace with function body.

var queue = []

func get_next_piece() -> String:
	if queue.size() < 7:
		gen_queue()
		
	return queue.pop_back()

func gen_queue():
	var temp = Data.piece_data.keys()
	temp.shuffle()
	queue.append_array(temp)
	temp.shuffle()
	queue.append_array(temp)

func get_top_queue(count: int) -> Array:
	var res = []
	for i in count:
		res.append(queue[-1-i])
	return res

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	
