extends AudioStreamPlayer

@export var pitch_increment = 0.1
@export var max_pitch = 2.0
@export var start_pitch = 0.8

var need_pitch_reset = false

func _ready() -> void:
	pitch_scale = start_pitch

func play_sound(line_count: int, is_spin_move: bool, last_piece: String) -> void:
	if line_count == 0:
		need_pitch_reset = true
		return

	if need_pitch_reset:
		pitch_scale = start_pitch
		need_pitch_reset = false
	play()
	pitch_scale += pitch_increment
	pitch_scale = min(pitch_scale, max_pitch)


func _on_finished() -> void:
	if need_pitch_reset:
		pitch_scale = start_pitch
