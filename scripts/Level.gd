extends Node

var score = 0
var combo = 0
var multiplier = 1
var current_level
var target_score
var charge: float


func display_combo():
	$ComboLabel.text = str(combo) + "x Combo"
	if combo > 1:
		$ComboLabel.show()
	else:
		$ComboLabel.hide()


func process_combo(lines_cleared):
	if lines_cleared > 0:
		combo += 1
	else:
		combo = 0
	display_combo()


func clear_lines(count: int):
	score += multiplier * count * count * 100 + 100
	process_combo(count)
	multiplier = combo + 1
	$ChargeBar.target_charge += 0.1 * count

	$ScoreLabel.text = str(score)


func set_level(level):
	current_level = level
	$LevelLabel.text = "Level " + str(current_level)

	target_score = level * (level + 1) * 1000
	$TargetScoreLabel.text = "Score to beat:\n " + str(target_score)


func _ready():
	$ComboLabel.hide()
	set_level(1)
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if score > target_score:
		set_level(current_level + 1)
