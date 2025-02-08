extends Node2D

var cost: int
var item_instance
var item_name: String
var multiplier = 0

@export var icon_size = 100.0

func set_item(_item_name: String):
	item_name = _item_name
	var item_data = Data.item_data[item_name]
	$ItemIcon.set_texture(load(item_data["icon_path"]))
	Helper.scale_to_square($ItemIcon, icon_size)
	
	cost = item_data["cost"]
	
	item_instance = load(item_data["script_path"]).new()
	$CostLabel.text = str(cost) + "$"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_buy_button_pressed():
	Events.buy.emit(self)
