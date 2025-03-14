extends Node

const LEFT = 0 
const RIGHT = 1

var DAS = 0.133
var ARR = 0
var SDR = 0
var last_input = -1

var in_arr_left = false
var in_arr_right = false
var paused = false

signal move(direction: Vector2i, silent: bool)
signal max_move(direction: Vector2i, silent: bool)

signal rotate_clockwise
signal rotate_counterclockwise
signal hard_drop
signal hold_piece
signal rotate_180
signal charge_attack


# Called when the node enters the scene tree for the first time.
func _ready():
	
	$DASLeftTimer.wait_time = DAS
	$DASRightTimer.wait_time = DAS
	
	if ARR != 0:
		$ARRLeftTimer.wait_time = ARR
		$ARRRightTimer.wait_time = ARR
	
	$DASLeftTimer.one_shot = 1
	$DASRightTimer.one_shot = 1
	
	if SDR != 0:
		$SDRTimer.wait_time = SDR
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if paused:
		return
	
	left_right_handler()
	soft_drop_handler()
	single_action_handler()
	
func single_action_handler():
	if Input.is_action_just_pressed("rotate clockwise"):
		rotate_clockwise.emit()
	if Input.is_action_just_pressed("rotate counterclockwise"):
		rotate_counterclockwise.emit()
	if Input.is_action_just_pressed("hard drop"):
		hard_drop.emit()
	if Input.is_action_just_pressed("hold piece"):
		hold_piece.emit()
	if Input.is_action_just_pressed("rotate 180"):
		rotate_180.emit()
	if Input.is_action_just_pressed("charge_attack"):
		emit_signal("charge_attack")

func left_right_handler():
	if Input.is_action_just_pressed("left"):
		move.emit(Vector2i.LEFT, false)
		last_input = LEFT
		$DASLeftTimer.start()
	
	if Input.is_action_just_pressed("right"):
		move.emit(Vector2i.RIGHT, false)
		last_input = RIGHT
		$DASRightTimer.start()
		
	if Input.is_action_just_released("left"):
		$DASLeftTimer.stop()
		$ARRLeftTimer.stop()
		in_arr_left = false
	
	if Input.is_action_just_released("right"):
		$DASRightTimer.stop()
		$ARRRightTimer.stop()
		in_arr_right = false
	
	if ARR == 0:
		left_right_arr0_move()

func _on_das_left_timer_timeout():
	in_arr_left = true
	if ARR != 0:
		$ARRLeftTimer.start()

func _on_das_right_timer_timeout():
	in_arr_right = true
	if ARR != 0:
		$ARRRightTimer.start()

func left_right_arr0_move():
	if in_arr_left and (last_input == LEFT or not Input.is_action_pressed("right")):
		max_move.emit(Vector2i.LEFT, false)
	if in_arr_right and (last_input == RIGHT or not Input.is_action_pressed("left")):
		max_move.emit(Vector2i.RIGHT, false)

func _on_arr_left_timer_timeout():
	if last_input == LEFT or not Input.is_action_pressed("right"):
		move.emit(Vector2i.LEFT, false)
		
func _on_arr_right_timer_timeout():
	if last_input == RIGHT or not Input.is_action_pressed("left"):
		move.emit(Vector2i.RIGHT, false)
	
func soft_drop_handler():
	if SDR == 0:
		if Input.is_action_pressed("soft drop"):
			max_move.emit(Vector2i.DOWN, false)
	else:
		if Input.is_action_just_pressed("soft drop"):
			$SDRTimer.start()
		if Input.is_action_just_released("soft drop"):
			$SDRTimer.stop()
	
func _on_sdr_timer_timeout():
	move.emit(Vector2i.DOWN, false)
	
