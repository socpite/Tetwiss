extends Label

var score = 0

func clear_lines(count: int):
	score += count
	text = str(score)

func _ready():
	pass # Replace with function body.

func _process(delta):
	pass
