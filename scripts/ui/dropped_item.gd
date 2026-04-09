extends Area2D

@onready var icon = $Icon
@onready var count = $Icon/Count
@onready var bg = $BG

var item_data: ItemData
var amount: int

var float_speed := 2.0
var float_height := 10.0

var base_y := -24
var time := 0.0

func _ready() -> void:
	icon.texture = item_data.icon
	count.text = str(amount)
	
func _process(delta: float) -> void:
	animate(delta)
	
func animate(delta):
	time += delta * float_speed
	icon.offset.y = base_y + sin(time) * float_height
	bg.offset.y = base_y + sin(time) * float_height
	count.position.y = base_y + sin(time) * float_height
