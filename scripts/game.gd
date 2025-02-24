extends Control

var score = 0
var combo = 0
var multiplier = 1.0
var current_level = 0
var target_score = 0
var charge = 0.0
var charge_attack_cost = 1.0
var is_charged = true

var boss_list: Array = Data.boss_data.keys()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	boss_list.shuffle()
	process_multiplier()
	set_level(1)
	$Boss.hide()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("hack"):
		score += 1000
	
	detect_use_charge()
	if score >= target_score:
		set_level(current_level + 1)
	display()
	
	if $Boss.visible:
		$Boss.boss_instance.boss_process(self)
	
func pause():
	$TileMap.pause()
	
func unpause():
	$TileMap.unpause()
	

func process_combo(lines_cleared):
	if lines_cleared > 0:
		combo += 1
	else:
		combo = 0

func process_multiplier():
	multiplier = combo + 1
	for item in $Inventory.items:
		item.item_instance.modify(self)
	if is_charged:
		multiplier *= 2



func clear_lines(count: int, is_spin_move: bool, last_piece: String):
	score += multiplier * count * count * 100 + 100

	process_multiplier()
	process_combo(count)

	if is_charged:
		is_charged = false
		charge = 0

	charge += 0.1 * count
	charge = min(charge, 1.0)

func init_boss():
	$Boss.set_boss(boss_list.pick_random())
	$Boss.boss_instance.boss_start(self)
	$Boss.show()
	

func set_level(level):
	if level % 5 == 1 and level != 1:
		score = target_score
		Events.open_shop.emit()
		$Boss.boss_instance.boss_end(self)
		$Boss.hide()

	if level % 5 == 0:
		init_boss()

	current_level = level

	target_score = level * (level + 1) * 1000

func display():
	$Level.display(self)

func detect_use_charge():
	if Input.is_action_just_pressed("charge_attack"):
		print(charge)
		if charge >= 1.0:
			print("charged!")
			is_charged = true
			process_multiplier()
	
