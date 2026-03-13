extends Panel
class_name ItemCard

enum CardMode {
	INVENTORY,
	INGREDIENTS,
	STATUS,
	FUEL,
	TOOL,
	OUT
}

signal top_pressed(stack)
signal middle_pressed(stack)
signal bottom_pressed(stack)

var s_data: Stack
var mode: CardMode

@onready var icon = $Icon
@onready var count = $Icon/Count
@onready var title = $Info/Title
@onready var description = $Info/Description
@onready var buttons = $Buttons
@onready var top_btn = $Buttons/TopBtn
@onready var top_btn_label = $Buttons/TopBtn/Label
@onready var middle_btn = $Buttons/MiddleBtn
@onready var middle_btn_label = $Buttons/MiddleBtn/Label
@onready var bottom_btn = $Buttons/BottomBtn
@onready var bottom_btn_label = $Buttons/BottomBtn/Label

func set_item(data: Stack):
	s_data = data
	icon.texture = data.item_data.icon
	count.text = str(data.count)
	title.text = data.item_data.name
	description.text = data.item_data.description
	
func set_mode(new_mode: CardMode):
	mode = new_mode
	match mode:
		CardMode.INVENTORY:
			top_btn_label.text = 'Mover 1'
			middle_btn_label.text = 'Mover todo'
			bottom_btn_label.text = 'Eliminar'
		CardMode.INGREDIENTS:
			top_btn_label.text = 'Quitar 1'
			middle_btn_label.text = 'Quitar todo'
			bottom_btn_label.text = 'Eliminar'
		CardMode.STATUS:
			top_btn_label.text = 'Usar'
			middle_btn_label.text = 'Equipar'
			bottom_btn_label.text = 'Eliminar'
		CardMode.FUEL:
			top_btn_label.text = 'Agregar'
			middle_btn_label.text = 'Quitar'
			bottom_btn_label.text = 'Limpiar'
		CardMode.TOOL:
			top_btn_label.text = 'Agregar'
			middle_btn_label.text = 'Quitar'
			bottom_btn_label.text = 'Limpiar'
		CardMode.OUT:
			buttons.visible = false
			description.custom_minimum_size = Vector2(201, 36)

func _ready() -> void:
	top_btn.pressed.connect(_on_top_pressed)
	middle_btn.pressed.connect(_on_middle_pressed)
	bottom_btn.pressed.connect(_on_bottom_pressed)
	
func _on_top_pressed():
	top_pressed.emit(s_data)

func _on_middle_pressed():
	middle_pressed.emit(s_data)
	
func _on_bottom_pressed():
	bottom_pressed.emit(s_data)
