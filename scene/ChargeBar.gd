extends Sprite2D

var full_rect: Rect2
var current_charge: float
var target_charge: float

const speed = 5
const eps = 0.001

func _ready():
	full_rect = get_region_rect()

func _process(delta):
	if target_charge - current_charge < eps:
		current_charge = target_charge
	else:
		current_charge += (target_charge - current_charge)*speed*delta
	
	var new_rect = full_rect
	new_rect.size.x *= min(current_charge, 1)
	set_region_rect(new_rect)
