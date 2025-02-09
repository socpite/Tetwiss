extends Node2D

@export var icon_size = 200.0

var boss_name: String
var boss_instance

func set_boss(_boss_name):
	boss_name = _boss_name
	var boss_data = Data.boss_data[boss_name]
	$BossIcon.set_texture(load(boss_data["icon_path"]))
	Helper.scale_to_square($BossIcon, icon_size)
	
	boss_instance = load(boss_data["script_path"]).new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_boss("The Fluff")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
