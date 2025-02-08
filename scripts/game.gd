extends Control

var score = 0
var combo = 0
var multiplier = 1.0
var current_level = 0
var target_score = 0
var charge = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_multiplier()
	set_level(1) # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if score > target_score:
		set_level(current_level + 1)
	display()
	
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



func clear_lines(count: int):
	score += multiplier * count * count * 100 + 100

	process_combo(count)
	process_multiplier()

	charge += 0.1 * count


func set_level(level):
	if level % 5 == 0:
		score = target_score
		Events.open_shop.emit()

	current_level = level

	target_score = level * (level + 1) * 1000

func display():
	$Level.display(self)
	
