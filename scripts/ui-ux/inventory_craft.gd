extends Control

@onready var inv_container = $Panel/InvScroll/InvContainer
@onready var ing_container = $Panel/IngScroll/IngContainer

@export var item_card_scene: PackedScene

#variables para el crafteo
var inventory: Array
var entry_items: Array = []
var max_items = 2
var max_stack = 5

var not_stackable = ['pole', 'pic', 'axe', 'knife', 'hammer']

#variables para la comprovacion

func _ready() -> void:
	visible = false
	inventory = get_inventory()
	update_inventory()
	define_recipes()
	
	add_item()
	craft_button_status()
	
	conectar_boton()
	
func update_inventory():
	#Aca empieza el codigo nuevo
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
	check_recipe()
	
	update_out_item()
	
# manejo de receta
@onready var craft_button = $Panel/DoneButton
@onready var craft_button_text = $Panel/ButtonText
@onready var out_item_container = $Panel/OutItem

@onready var tool_select_button = $Panel/ToolComponent/TextureButton
@onready var tool_panel = $Panel/ToolPanel
@onready var tool_container = $Panel/ToolPanel/FuelScroll/VBoxContainer
@onready var tool_acept_button = $Panel/ToolPanel/AceptButton
@onready var tool_cancel_button = $Panel/ToolPanel/CancelButton

@onready var craft_timer = $Panel/CraftTimer

var current_recipe = null
var output_item = null
var current_output_item = null
var is_crafting := false
var craft_time := 0.0
var fuel = 'missing'
var tool = 'missing'

enum craftState {
	NO_ING,
	BAD_ING,
	MISSING_FUEL,
	MISSING_TOOL,
	READY,
	CRAFTING
}
var recipes = []
# algunos metadatos que puedo usar = 'type', 'uses', 'fuel_req', 'tool_req', 'healing', 'damage', craft_time

# agregar items para pruebas
func add_item():
	inventory.append(
		{
			'name': 'Cuerda',
			'count': 5,
			'icon': preload("res://assets/inventory_icons/primary/cuerda_icon.png"),
			'description': 'Material basico para crear objetos improvisados',
			'meta': {
					'type': 'material',
					'fuel_req': 'none',
					'tool_req': 'none',
					'craft_time': 3
				}
		}
	)

#manejar las recetas desde un archivo .gd aparte	
func define_recipes():
	recipes = [
		{ #cuerda
			'in': [{'name':'Fibra vegetal', 'count':5}],
			'out': {
				'name': 'Cuerda',
				'count': 1,
				'icon': preload("res://assets/inventory_icons/primary/cuerda_icon.png"),
				'description': 'Material basico para fabricar objetos improvisados',
				'meta': {
					'type': 'material',
					'fuel_req': 'none',
					'tool_req': 'none',
					'craft_time': 3
				}
			}
		},
		{ #pico improvisado
			'in': [{'name': 'Madera', 'count': 1}, {'name': 'Piedra', 'count': 1}, {'name': 'Cuerda', 'count': 1}],
			'out': {
				'name': 'Pico improvisado',
				'count': 1,
				'icon': preload("res://assets/inventory_icons/primary/pico_improvisado_icon.png"),
				'description': 'Herramienta util para obtener minerales de peñascos',
				'meta': {
					'type': 'pickaxe',
					'fuel_req': 'none',
					'tool_req': 'none',
					'craft_time': 5
				}
			}
		},
		{ #hacha improvisada
			'in': [{'name': 'Madera', 'count': 1}, {'name': 'Piedra', 'count': 1}, {'name': 'Cuerda', 'count': 2}],
			'out': {
				'name': 'Hacha improvisada',
				'count': 1,
				'icon': preload("res://assets/inventory_icons/primary/hacha_improvisada_icon.png"),
				'description': 'Herramienta util para obtener madera de los arboles comunes',
				'meta': {
					'type': 'axe',
					'fuel_req': 'none',
					'tool_req': 'none',
					'craft_time': 5
				}
			}
		},
		{ #martillo improvisado
			'in': [{'name': 'Madera', 'count': 1}, {'name': 'Piedra', 'count': 1}, {'name': 'Cuerda', 'count': 3}],
			'out': {
				'name': 'Martillo improvisado',
				'count': 1,
				'icon': preload("res://assets/inventory_icons/primary/martillo_improvisado_icon.png"),
				'description': 'Herramienta util para golpear la madera o el metal',
				'meta': {
					'type': 'hammer',
					'fuel_req': 'none',
					'tool_req': 'none',
					'craft_time': 5
				}
			}
		},
		{ #cuchillo improvisado
			'in': [{'name': 'Piedra', 'count': 1}, {'name': 'Cuerda', 'count': 1}],
			'out': {
				'name': 'Cuchillo improvisado',
				'count': 1,
				'icon': preload("res://assets/inventory_icons/primary/cuchillo_improvisado_icon.png"),
				'description': 'Herramienta util para cortar piel y cuero',
				'meta': {
					'type': 'knife',
					'fuel_req': 'none',
					'tool_req': 'none',
					'craft_time': 5
				}
			}
		},
		{ #garrote
			'in': [{'name': 'Madera', 'count': 1}, {'name': 'Cuerda', 'count': 1}],
			'out': {
				'name': 'Garrote',
				'count': 1,
				'icon': preload("res://assets/inventory_icons/primary/garrote_icon.png"),
				'description': 'Arma provicional pero mejor que nada',
				'meta': {
					'type': 'pole',
					'fuel_req': 'none',
					'tool_req': 'none',
					'craft_time': 5
				}
			}
		},
	]

func conectar_boton(): #ubicar mejor despues xd
	craft_button.pressed.connect(_on_craft_button_pressed)
	
func check_recipe(): #1
	current_recipe = null
	output_item = null
	fuel = 'missing'
	tool = 'missing'
	for recipe in recipes:
		var found = compare_ing(entry_items, recipe['in'])
		if found == true:
			current_recipe = recipe['in'].duplicate(true)
			output_item = recipe['out'].duplicate(true)
	#intento de manejo de combustible y herramienta requeridas
	if output_item:
		fuel = fuel_contoller()
		tool = tool_contoller()
	#intento de manejo de boton dinamico y dibujo
	craft_button_status()
	if output_item:
		update_out_item()
	else:
		for i in out_item_container.get_children():
			i.queue_free()
	
func compare_ing(entry: Array, recipe: Array): #2
	if entry.size() != recipe.size():
		return false
	for r in recipe:
		var found = false
		for e in entry:
			if e['name'] == r['name'] and e['count'] >= r['count']:
				found = true
				break
		if not found:
			return false
	return true

func fuel_contoller(): #3
	#por el momento solo retornar el estado
	if output_item['meta']['fuel_req'] == 'none':
		return 'done'
	return 'missing'
	
func tool_contoller(): #4
	if output_item['meta']['tool_req'] == 'none':
		return 'done'
	return 'missing'

func craft_button_status():
	match get_craft_state():
		craftState.NO_ING:
			craft_button.disabled = true
			craft_button_text.text = '↑↑↑ \n Añadir ingredientes'
		craftState.BAD_ING:
			craft_button.disabled = true
			craft_button_text.text = '↑↑↑ \n Ingredientes incorrectos'
		craftState.MISSING_FUEL:
			craft_button.disabled = true
			craft_button_text.text = '←←← \n Añadir combustible'
		craftState.MISSING_TOOL:
			craft_button.disabled = true
			craft_button_text.text = '→→→ \n Añadir herramienta'
		craftState.READY:
			craft_button.disabled = false
			craft_button_text.text = '↓↓↓ \n Todo listo'
		craftState.CRAFTING:
			var remaining = craft_timer.time_left
			craft_button_text.text = 'fabricando: %.1f s' % remaining
			if remaining == 0.0:
				_on_craftTimer_timeout()

func update_out_item(): #5
	if output_item:
		for i in out_item_container.get_children():
			i.queue_free()
		var card = item_card_scene.instantiate()
		out_item_container.add_child(card)
		card.set_item(output_item)
		var btn = card.get_child(2)
		btn.visible = false
	return

func _on_craft_button_pressed():
	if is_crafting:
		return
		
	is_crafting = true
	current_output_item = output_item
	consume_ingredients()
	craft_time = output_item['meta']['craft_time']
	craft_timer.start(craft_time)
	refresh_ui()

func consume_ingredients():
	for ing in current_recipe:
		for ing2 in entry_items:
			if ing['name'] == ing2['name']:
				ing2['count'] -= ing['count']
				if ing2['count'] <= 0:
					entry_items.erase(ing2)

func _process(delta: float) -> void:
	if is_crafting:
		craft_button_status()

func _on_craftTimer_timeout():
	is_crafting = false
	add_out_to_inventory()
	
func add_out_to_inventory():
	#buscar stack existente
	for slot in inventory:
		if slot['name'] == current_output_item['name'] and slot['count'] < max_stack and current_output_item['meta']['type'] not in not_stackable:
			slot['count'] += current_output_item['count']
			current_output_item = null
			refresh_ui()
			return
	#crear nuevo stack
	inventory.append(current_output_item)
	current_output_item = null
	refresh_ui()

func get_craft_state() -> craftState:
	if is_crafting:
		return craftState.CRAFTING
	if entry_items.is_empty():
		return craftState.NO_ING
	if not output_item:
		return craftState.BAD_ING
	if fuel_contoller() == 'missing':
		return craftState.MISSING_FUEL
	if tool_contoller() == 'missing':
		return craftState.MISSING_TOOL
	return craftState.READY
