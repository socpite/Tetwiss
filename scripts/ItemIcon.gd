extends Sprite2D

func scale_to_square(size):
	var x = texture.get_width()
	var y = texture.get_height()
	
	scale.x = size/x
	scale.y = size/y
	
	print(x)
	print(y)
	
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
