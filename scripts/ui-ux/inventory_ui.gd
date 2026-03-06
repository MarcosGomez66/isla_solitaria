extends Control

@onready var inv_container = $Panel/InvScroll/InvContainer
@onready var ing_container = $Panel/IngScroll/IngContainer

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
		card.move_pressed.connect(Inv_manager.move_to_ingredients)

func draw_ingredients():
	for ch in ing_container.get_children():
		ch.queue_free()
		
	for i in Inv_manager.get_ingredients():
		var card = item_card_scene.instantiate()
		ing_container.add_child(card)
		card.set_item(i)
		card.move_pressed.connect(Inv_manager.move_to_inventory)

func redraw():
	draw_inventory()
	draw_ingredients()
