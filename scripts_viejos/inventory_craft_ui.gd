extends Control

@onready var grid = $MarginContainer/Panel/VBoxContainer/CenterContainer/GridContainer
@onready var entry_slots = [
	$MarginContainer/Panel/VBoxContainer2/CenterContainer/VBoxContainer/GridContainer/Panel,
	$MarginContainer/Panel/VBoxContainer2/CenterContainer/VBoxContainer/GridContainer/Panel2,
	$MarginContainer/Panel/VBoxContainer2/CenterContainer/VBoxContainer/GridContainer/Panel3,
	$MarginContainer/Panel/VBoxContainer2/CenterContainer/VBoxContainer/GridContainer/Panel4
]
@onready var output_slot = $MarginContainer/Panel/VBoxContainer2/CenterContainer/VBoxContainer/CenterContainer/Panel5

var slot_button: Array[Panel] = []
var custom_size = Vector2(48, 48)
var entry_items = []
var output_item = {}
var max_entry_items = 4
var max_inventory_items = 25
var max_stack = 5
var recipes = []

func _ready() -> void:
	setup_inventory()
	define_recipes()
	
func setup_inventory():
	visible = false
	#se crea los 25 slots del inventario
	for i in range(25):
		var panel = Panel.new()
		panel.custom_minimum_size = custom_size
		var btn = TextureButton.new()
		btn.custom_minimum_size = custom_size
		btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		btn.texture_normal = null
		btn.pressed.connect(_on_inventory_slot_pressed.bind(i))
		var label = Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		label.custom_minimum_size = custom_size
		panel.add_child(btn)
		panel.add_child(label)
		grid.add_child(panel)
		slot_button.append(panel)
		
	#se bindea tambien los slots de entrada
	for i in range(4):
		entry_slots[i].get_child(0).pressed.connect(_on_entry_slot_pressed.bind(i))

func check_recipes():
	var btn = output_slot.get_child(0)
	btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	if not btn.pressed.is_connected(_on_output_slot_pressed):
		btn.pressed.connect(_on_output_slot_pressed.bind())
	var label = output_slot.get_child(1)
	#reinicia siempre el objeto de salida
	output_item = null
	#compara items de entrada con las recetas
	for recipe in recipes:
		var found = compare_ing(entry_items, recipe['in'])
		if found:
			output_item = recipe['out']
	#dibuja el item en pantalla
	if output_item:
		btn.texture_normal = output_item['icon']
		label.text = str(output_item['count'])
	else:
		btn.texture_normal = null
		label.text = ''
	
func compare_ing(entry: Array, recipe: Array):
	if entry.size() != recipe.size():
		return false
	for r in recipe:
		var found = false
		for e in entry:
			if e['name'] == r['name'] and e['count'] == r['count']:
				found = true
				break
		if not found:
			return false
	return true
		
func _on_inventory_slot_pressed(i):
	var inventory = get_inventory()
	if inventory and inventory.size() > i:
		#busca slots disponibles
		for slot in entry_items:
			if slot.name == inventory[i]['name'] and slot.count < max_stack:
				slot.count +=1
				inventory[i].count -=1
				if inventory[i].count < 1:
					inventory.remove_at(i)
				update_entry_item()
				update_inventory()
				return
		#comprueba si los slots estan todos ocupados
		if entry_items.size() >= max_entry_items:
			print('entrada llena')
			return
		#crea el slot si no hay
		var new_slot = {
			'name':inventory[i]['name'],
			'icon':inventory[i]['icon'],
			'count':1
		}
		entry_items.append(new_slot)
		inventory[i].count -=1
		if inventory[i].count < 1:
			inventory.remove_at(i)
		update_entry_item()
		update_inventory()

func _on_entry_slot_pressed(i):
	var inventory = get_inventory()
	if entry_items and entry_items.size() > i:
		#busca slots disponibles
		for slot in inventory:
			if slot.name == entry_items[i]['name'] and slot.count < max_stack:
				slot.count +=1
				entry_items[i].count -=1
				if entry_items[i].count < 1:
					entry_items.remove_at(i)
				update_entry_item()
				update_inventory()
				return
		#comprueba si los slots estan todos ocupados
		if inventory.size() >= max_inventory_items:
			print('entrada llena')
			return
		#crea el slot si no hay
		var new_slot = {
			'name':entry_items[i]['name'],
			'icon':entry_items[i]['icon'],
			'count':1
		}
		inventory.append(new_slot)
		entry_items[i].count -=1
		if entry_items[i].count < 1:
			entry_items.remove_at(i)
		update_entry_item()
		update_inventory()

func _on_output_slot_pressed():
	var inventory = get_inventory()
	if output_item:
		if inventory.size() >= max_inventory_items:
			print("inventario lleno")
			return
		#elimina los items que se consumen
		entry_items.clear()
		print(output_item)
		#busca slots disponibles
		for slot in inventory:
			if slot.name == output_item['name'] and slot.count < max_stack:
				slot.count += output_item['count']
				output_item = null
				update_entry_item()
				update_inventory()
				return
		#comprueba si los slots estan todos ocupados
		if inventory.size() >= max_inventory_items:
			print('entrada llena')
			return
		#crea el slot si no hay
		var new_slot = {
			'name':output_item['name'],
			'count':output_item['count'],
			'icon':output_item['icon']
		}
		inventory.append(new_slot)
		output_item = null
		update_entry_item()
		update_inventory()
		return

func define_recipes():
	recipes = [
		{
			'in': [{'name':'hoja', 'count': 3}],
			'out': {'name':'cuerda', 'count': 1, 'icon': preload("res://assets/sprites/cuerda.png")}
		},
		{
			'in': [{'name':'rama', 'count': 1}, {'name':'piedra', 'count': 1}, {'name':'cuerda', 'count': 2}],
			'out': {'name':'hacha', 'count': 1, 'icon': preload("res://assets/sprites/hacha.png")}
		},
		{
			'in': [{'name':'rama', 'count': 1}, {'name':'piedra', 'count': 1}, {'name':'cuerda', 'count': 1}],
			'out': {'name':'pico', 'count': 1, 'icon': preload("res://assets/sprites/pico.png")}
		}
	]

func get_inventory():
	var inventory = get_tree().root.get_node("Main/ysort/player").inventory
	return inventory
	
func update_inventory():
	var inventory = get_inventory()
	#actualiza el inventario cada vez que se agrega un item
	for i in range(slot_button.size()):
		var btn = slot_button[i].get_child(0)
		var label = slot_button[i].get_child(1)
		if i < inventory.size() and inventory[i] != null:
			btn.texture_normal = inventory[i]['icon']
			label.text = str(inventory[i]['count'])
		else:
			btn.texture_normal = null
			label.text = ''
	check_recipes()

func update_entry_item():
	for i in range(entry_slots.size()):
		var btn = entry_slots[i].get_child(0)
		var label = entry_slots[i].get_child(1)
		if i < entry_items.size() and entry_items[i] != null:
			btn.texture_normal = entry_items[i]['icon']
			label.text = str(entry_items[i]['count'])
		else:
			btn.texture_normal = null
			label.text = ''
	check_recipes()
	
