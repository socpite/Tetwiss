extends Node2D

var item_scene = preload("res://scene/item.tscn")

var money = 5
var items = []

# Called when the node enters the scene tree for the first time.

func _ready():
	Events.buy.connect(buy_item)
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$MoneyLabel.set_text(str(money) + "$")


func buy_item(item):
	print(money)
	if money < item.cost:
		return

	money -= item.cost
	var new_item = item_scene.instantiate()
	new_item.set_item(item.item_name)
	items.append(new_item)
	item.queue_free()
