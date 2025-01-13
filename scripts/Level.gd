extends Node

var score = 0
var combo = 0
var multiplier = 1.0
var current_level
var target_score
var charge: float


func _ready():
	process_multiplier()
	$ComboLabel.hide()
	set_level(1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if score > target_score:
		set_level(current_level + 1)


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


func process_multiplier():
	multiplier = combo + 1
	for item in $Inventory.items:
		item.item_instance.modify(self)

	$MultiplierLabel.set_text(str(multiplier) + " Mult")


func clear_lines(count: int):
	score += multiplier * count * count * 100 + 100

	process_combo(count)
	process_multiplier()

	$ChargeBar.target_charge += 0.1 * count
	$ScoreLabel.text = str(score)


func set_level(level):
	if level % 5 == 0:
		score = target_score
		Events.open_shop.emit()

	current_level = level
	$LevelLabel.text = "Level " + str(current_level)

	target_score = level * (level + 1) * 1000
	$TargetScoreLabel.text = "Score to beat:\n " + str(target_score)
