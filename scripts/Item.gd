extends Node2D

var cost: int

@export var icon_size = 100.0

func set_item(item_name: String):
	var item_data = Data.item_data[item_name]
	$ItemIcon.set_texture(load(item_data["icon_path"]))
	$ItemIcon.scale_to_square(icon_size)
	
	cost = item_data["cost"]
	
	print(item_data["script_path"])

# Called when the node enters the scene tree for the first time.
func _ready():
	set_item("The first cat meme")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
