extends Node

var score = 0
var combo = 0
var multiplier = 1.0
var current_level
var target_score
var charge: float


func _ready():
	$ComboLabel.hide()


func _process(delta):
	pass


func display_combo():
	$ComboLabel.text = str(combo) + "x Combo"
	if combo > 1:
		$ComboLabel.show()
	else:
		$ComboLabel.hide()

func display(game):
	$ScoreLabel.text = str(game.score)
	$LevelLabel.text = "Level " + str(game.current_level)
	$TargetScoreLabel.text = "Score to beat:\n " + str(game.target_score)
	display_combo()
	$ChargeBar.target_charge = str(game.charge)
	$MultiplierLabel.text = str(game.multiplier) + "x Mult"
	
