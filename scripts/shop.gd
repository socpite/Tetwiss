extends Node2D

var item_scene = preload("res://scene/item.tscn")

func gen_items(count):
	var item_list = Data.item_data.keys()
	var position = $FirstDummyItem.position
	var gap = ($LastDummyItem.position.x - $FirstDummyItem.position.x)/(count-1)
	
	for _i in count:
		var new_item = item_scene.instantiate()
		new_item.set_item(item_list.pick_random())
		new_item.set_position(position)
		
		add_child(new_item)
		
		position.x += gap

# Called when the node enters the scene tree for the first time.
func _ready():
	$FirstDummyItem.hide()
	$LastDummyItem.hide()	
	gen_items(5)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
