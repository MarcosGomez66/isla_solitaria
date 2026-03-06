extends Panel
class_name ItemCard

signal use_pressed(item_data)
signal move_pressed(item_data)
signal del_pressed(item_data)

var i_data: Stack

@onready var icon = $Icon
@onready var count = $Icon/Count
@onready var title = $Info/Title
@onready var description = $Info/Description
@onready var use_btn = $Buttons/UseBtn
@onready var move_btn = $Buttons/MoveBtn
@onready var del_btn = $Buttons/DelBtn

func set_item(data: Stack):
	i_data = data
	icon.texture = data.item_data.icon
	count.text = str(data.count)
	title.text = data.item_data.name
	description.text = data.item_data.description
	
func _ready() -> void:
	use_btn.pressed.connect(_on_use)
	move_btn.pressed.connect(_on_move)
	del_btn.pressed.connect(_on_del)
	
func _on_use():
	use_pressed.emit(i_data)

func _on_move():
	move_pressed.emit(i_data)
	
func _on_del():
	del_pressed.emit(i_data)
