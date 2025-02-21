extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var count_names = ["", "Single", "Double", "Triple", "Quad"]

func _on_tile_map_clear_lines_signal(line_count: int, is_spin_move: bool, last_piece: String) -> void:
	if line_count == 0 and not is_spin_move:
		return
	$FadeTimer.start()
	show()
	if not is_spin_move:
		text = count_names[line_count]
	else:
		text = last_piece + "-spin\n" + count_names[line_count]

func _on_fade_timer_timeout() -> void:
	hide() # Replace with function body.
