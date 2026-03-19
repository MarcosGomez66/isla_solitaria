extends Control

@onready var inv_container = $Panel/InvScroll/InvContainer
@onready var main_space_con = $Panel/Space1
@onready var armor_space_con = $Panel/Space2
@onready var backpack_space_con = $Panel/Space3

@export var item_card_scene: PackedScene

func _ready() -> void:
	visible = false
	Inv_manager.inventory_changed.connect(redraw)
	
func draw_inventory():
	# se elimina los objetos para no duplicar
	for ch in inv_container.get_children():
		ch.queue_free()
		
	for i in Inv_manager.get_inventory():
		var card = item_card_scene.instantiate()
		inv_container.add_child(card)
		card.set_item(i)
		card.set_mode(ItemCard.CardMode.EQUIPMENT_INV)
		card.top_pressed.connect(Eq_manager.check_space)
		#card.middle_pressed.connect(Eq_manager.move_stack_to_ingredients)

func draw_spaces(container, to: Array[Stack]):
	if to.is_empty():
		return
		
	for ch in container.get_children():
		ch.queue_free()
	
	for i in to:
		var card = item_card_scene.instantiate()
		container.add_child(card)
		card.set_item(i)
		card.set_mode(ItemCard.CardMode.EQUIPMENT)
		card.top_pressed.connect(Eq_manager.check_quit)
	
func draw_main_space():
	draw_spaces(main_space_con, Eq_manager.main_space)
	
func draw_armor_space():
	draw_spaces(armor_space_con, Eq_manager.armor)
	
func draw_backpack_space():
	draw_spaces(backpack_space_con, Eq_manager.backpack)

func redraw():
	draw_inventory()
	draw_main_space()
	draw_armor_space()
	draw_backpack_space()
