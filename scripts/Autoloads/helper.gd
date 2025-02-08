extends Node

# Scale a Sprite2D to a square of size

func scale_to_square(sprite: Sprite2D, size: float):
	var x = sprite.texture.get_width()
	var y = sprite.texture.get_height()
	
	sprite.scale.x = size/x
	sprite.scale.y = size/y
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
