extends Control

@onready var inv_container = $Panel/InvScroll/InvContainer
@onready var ing_container = $Panel/IngScroll/IngContainer

@export var item_card_scene: PackedScene

#variables para el crafteo
var inventory : Array
var entry_items = []
#var output_item = {}
var max_items = 2
var max_stack = 5

#variables para la comprovacion

func _ready() -> void:
	visible = false
	inventory = get_inventory()
	update_inventory()
	define_recipes()
	
	add_item()
	craft_button_status('', '', '')
	
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
	
	
# manejo de receta
@onready var craft_button = $Panel/DoneButton
@onready var craft_button_text = $Panel/ButtonText
@onready var out_item_container = $Panel/OutItem

@onready var tool_select_button = $Panel/ToolComponent/TextureButton
@onready var tool_panel = $Panel/ToolPanel
@onready var tool_container = $Panel/ToolPanel/FuelScroll/VBoxContainer
@onready var tool_acept_button = $Panel/ToolPanel/AceptButton
@onready var tool_cancel_button = $Panel/ToolPanel/CancelButton

var recipes = []
var metadatos = ['type', 'uses', 'fuel_req', 'tool_req', 'healing', 'damage'] #metadatos que pueden tener los items

# agregar cuerda para pruebas
func add_item():
	inventory.append(
		{
			'name': 'Cuerda',
			'count': 5,
			'icon': preload("res://assets/inventory_icons/cuerda_icon.png"),
			'description': 'Material basico para crear objetos improvisados',
			'meta': {
					'type': 'material',
					'fuel_req': 'none',
					'tool_req': 'none'
				}
		}
	)
	
func define_recipes():
	recipes = [
		{ #cuerda
			'in': [{'name':'Fibra vegetal', 'count':5}],
			'out': {
				'name': 'Cuerda',
				'count': 1,
				'icon': preload("res://assets/inventory_icons/cuerda_icon.png"),
				'description': 'Material basico para fabricar objetos improvisados',
				'meta': {
					'type': 'material',
					'fuel_req': 'none',
					'tool_req': 'none'
				}
			}
		},
		{ #hacha improvisada
			'in': [{'name': 'Madera', 'count': 1}, {'name': 'Piedra', 'count': 1}, {'name': 'Cuerda', 'count': 2}],
			'out': {
				'name': 'Hacha improvisada',
				'count': 1,
				'icon': preload("res://assets/inventory_icons/hacha_improvisada_icon.png"),
				'description': 'Herramienta util para obtener madera de los arboles comunes',
				'meta': {
					'type': 'axe',
					'fuel_req': 'none',
					'tool_req': 'none'
				}
			}
		},
		{ #pico improvisado
			'in': [{'name': 'Madera', 'count': 1}, {'name': 'Piedra', 'count': 1}, {'name': 'Cuerda', 'count': 1}],
			'out': {
				'name': 'Pico improvisado',
				'count': 1,
				'icon': preload("res://assets/inventory_icons/pico_improvisado_icon.png"),
				'description': 'Herramienta util para obtener minerales de peñascos',
				'meta': {
					'type': 'pickaxe',
					'fuel_req': 'none',
					'tool_req': 'none'
				}
			}
		},
		{ #cuchillo improvisado
			'in': [{'name': 'Piedra', 'count': 1}, {'name': 'Cuerda', 'count': 1}],
			'out': {
				'name': 'Cuchillo improvisado',
				'count': 1,
				'icon': preload("res://assets/inventory_icons/cuchillo_improvisado_icon.png"),
				'description': 'Herramienta util para cortar piel y cuero',
				'meta': {
					'type': 'knife',
					'fuel_req': 'none',
					'tool_req': 'none'
				}
			}
		},
	]

func check_recipe():
	var output_item = {}
	var fuel = 'missing'
	var tool = 'missing'
	for recipe in recipes:
		var found = compare_ing(entry_items, recipe['in'])
		if found == true:
			output_item = recipe
	#intento de manejo de combustible y herramienta requeridas
	if output_item:
		fuel = fuel_contoller(output_item['out'])
		tool = tool_contoller(output_item['out'])
	#intento de manejo de boton dinamico y dibujo
	craft_button_status(fuel, tool, output_item)
	if output_item:
		update_out_item(output_item['out'])
	else:
		for i in out_item_container.get_children():
			i.queue_free()
	
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

func fuel_contoller(out):
	#por el momento solo retornar el estado
	if out['meta']['fuel_req'] == 'none':
		return 'done'
	return 'missing'
	
func tool_contoller(out):
	if out['meta']['tool_req'] == 'none':
		return 'done'
	return 'missing'

func craft_button_status(fuel, tool, out):
	craft_button_text.text = '↑↑↑ \n Añadir ingredientes'
	craft_button.disabled = true
	if fuel != 'done' and tool != 'done' and entry_items:
		craft_button_text.text = '↑↑↑ \n Ingredientes incorrectos'
		craft_button.disabled = true
	if fuel != 'done' and tool != 'done' and out:
		craft_button_text.text = '←←← \n Añadir combustible'
		craft_button.disabled = true
	if fuel == 'done' and tool != 'done' and out:
		craft_button_text.text = '→→→ \n Añadir herramienta'
		craft_button.disabled = true
	if fuel == 'done' and tool == 'done' and out:
		craft_button_text.text = '↓↓↓ \n Todo listo'
		craft_button.disabled = false

func update_out_item(item):
	#print(item['name'])
	
	for i in out_item_container.get_children():
		i.queue_free()
	var card = item_card_scene.instantiate()
	out_item_container.add_child(card)
	card.set_item(item)
	#card.move_pressed.connect(_on_move_from_entry)
