extends Node2D

var cost: int
var item_instance

@export var icon_size = 100.0

func set_item(item_name: String):
	var item_data = Data.item_data[item_name]
	$ItemIcon.set_texture(load(item_data["icon_path"]))
	$ItemIcon.scale_to_square(icon_size)
	
	cost = item_data["cost"]
	
	print(item_data["script_path"])
	item_instance = load(item_data["script_path"]).new()
	
	$CostLabel.text = str(cost) + "$"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
