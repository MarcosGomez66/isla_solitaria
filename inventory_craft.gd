extends Control

@onready var inv_container = $Panel/InvScroll/InvContainer
@onready var ing_container = $Panel/IngScroll/IngContainer
@export var item_card_scene: PackedScene

#variables para el crafteo
var inventory : Array
var entry_items = []
var ouput_item = {}
var max_items = 2
var max_stack = 5

func _ready() -> void:
	inventory = get_inventory()
	update_inventory()
	
func update_inventory():
	#Aca empieza el codigo nuevo
	#visible = false
	for c in inv_container.get_children():
		c.queue_free()
		
	for i in inventory:
		#instancia y setea cada carta de objeto
		var card = item_card_scene.instantiate()
		inv_container.add_child(card)
		card.set_item(i)
		#conecta las señales
		card.move_pressed.connect(_on_move_from_inventory)

func update_entry_items():
	for c in ing_container.get_children():
		c.queue_free()
		
	for i in entry_items:
		var card = item_card_scene.instantiate()
		ing_container.add_child(card)
		card.set_item(i)
		card.move_pressed.connect(_on_move_from_entry)
	
func get_inventory():
	# reemplazar la ruta despues
	var inv = get_tree().root.get_node('testscene/CharacterBody2D').inventory
	return inv

func _on_move_from_inventory(item_data: Dictionary):
	move_one_item(item_data, inventory, entry_items, 100)
	
func _on_move_from_entry(item_data: Dictionary):
	move_one_item(item_data, entry_items, inventory, max_stack)

func move_one_item(item_data : Dictionary, from : Array, to : Array, max_s: int):
	#buscar stack existente
	for slot in to:
		if slot['name'] == item_data['name'] and slot['count'] < max_s:
			slot['count'] +=1
			item_data['count'] -=1
			if item_data['count'] <= 0:
				from.erase(item_data)
			refresh_ui()
			return
	
	#crear nuevo stack
	to.append({
		'name': item_data['name'],
		'icon': item_data['icon'],
		'description': item_data['description'],
		'count': 1
	})
	item_data['count'] -=1
	if item_data['count'] <= 0:
		from.erase(item_data)
	refresh_ui()
				
func refresh_ui():
	update_inventory()
	update_entry_items()
