extends Node
#class_name InventoryManager

signal inventory_changed

#variables para inventory manager
var _inventory: Array[Stack] = []
var max_stack = 20
var max_items = 10

var _ingredients: Array[Stack] = []

func _ready() -> void:
	items_de_prueba()
	inventory_changed.emit()

func items_de_prueba():
	var pico = ItemData.new()
	pico.name = 'Pico improvisado'
	pico.icon = preload('res://assets/inventory_icons/hands/pico_improvisado_icon.png')
	pico.description = 'Herramienta improvisada para extraer minerales de las menas'
	pico.stackable = false
	pico.type = 'tool'
	pico.subtype = 'pic'
	var stack1 = Stack.new()
	stack1.item_data = pico
	stack1.count = 1
	_inventory.append(stack1)
	
	var mochila = ItemData.new()
	mochila.name = 'Mochila'
	mochila.icon = preload('res://assets/inventory_icons/place_holder_48x48.png')
	mochila.description = 'Aumenta el espacio del inventario a 15'
	mochila.stackable = false
	mochila.type = 'equipment'
	mochila.subtype = 'backpack'
	var stack2 = Stack.new()
	stack2.item_data = mochila
	stack2.count = 1
	_inventory.append(stack2)
	
	var prenda_cuero = ItemData.new()
	prenda_cuero.name = 'Prenda de cuero'
	prenda_cuero.icon = preload('res://assets/inventory_icons/place_holder_48x48.png')
	prenda_cuero.description = 'Reduce un 20% el daño recibido'
	prenda_cuero.stackable = false
	prenda_cuero.type = 'equipment'
	prenda_cuero.subtype = 'armor'
	var stack3 = Stack.new()
	stack3.item_data = prenda_cuero
	stack3.count = 1
	_inventory.append(stack3)

func get_inventory():
	return _inventory
	
func get_ingredients():
	return _ingredients

func add_item_to_inventory(data: Stack):
	while data.count > 0:
		#var stack_found = false
		for stack in _inventory:
			if stack.item_data == data.item_data and stack.count < max_stack and data.item_data.stackable:
				var space = max_stack - stack.count
				var add = min(space, data.count)
				stack.count += add
				data.count -= add
				#stack_found = true
				break
		if data.count <= 0:
			break
		if _inventory.size() >= max_items:
			break
		var new_amount = min(max_stack, data.count)
		var stack = Stack.new()
		stack.item_data = data.item_data
		stack.count = new_amount
		_inventory.append(stack)
		#intento de mostrar el mensaje
		#PopupManager.show_text(stack.item_data.name+' +1', Player.position)
		data.count -= new_amount
	inventory_changed.emit()

#movimientos a craft_manager
func move_to_ingredients(data: Stack):
	move_one_item(data, _inventory, _ingredients, 500, 100)
	
func move_to_inventory(data: Stack):
	move_one_item(data, _ingredients, _inventory, max_stack, max_items)

func move_one_item(data: Stack, from: Array, to: Array, max_s: int, max_i: int):
	for stack in to:
		if stack.item_data == data.item_data and stack.count < max_s and data.item_data.stackable:
			stack.count += 1
			data.count -= 1
			if data.count <= 0:
				from.erase(data)
			inventory_changed.emit()
			return
	
	if to.size() >= max_i:
		return
	var stack = Stack.new()
	stack.item_data = data.item_data
	stack.count = 1
	to.append(stack)
	data.count -= 1
	if data.count <= 0:
		from.erase(data)
	inventory_changed.emit()

func move_stack_to_ingredients(data: Stack):
	move_stack(data, _inventory, _ingredients, 500)
	
func move_stack_to_inventory(data: Stack):
	move_stack(data, _ingredients, _inventory, max_stack)

func move_stack(data: Stack, from: Array, to: Array, max_s: int):
	while data.count > 0:
		for stack in to:
			if stack.item_data == data.item_data and stack.count < max_s and data.item_data.stackable:
				var space = max_s - stack.count
				var add = min(space, data.count)
				stack.count += add
				data.count -= add
				if data.count <= 0:
					from.erase(data)
				break
		if data.count <= 0:
			break
		if to.size() >= max_items:
			break
		var new_count = min(max_s, data.count)
		var stack = Stack.new()
		stack.item_data = data.item_data
		stack.count = new_count
		to.append(stack)
		data.count -= new_count
		if data.count <= 0:
			from.erase(data)
	inventory_changed.emit()

func update_inventory_space() -> String:
	return '%d/%s' % [_inventory.size(), max_items]

#nuevas pruebas
func clear_ingrediens():
	for i in _ingredients:
		move_stack(i, _ingredients, _inventory, max_stack)

func sort_by_prio(prio: Array):
	var copy = _inventory.duplicate()
	copy.sort_custom(func(a, b):
		var a_prio = 0 if prio.has(a.item_data.type) else 1
		var b_prio = 0 if prio.has(b.item_data.type) else 1
		
		if a_prio == b_prio:
			return a.item_data.type < b.item_data.type
		return a_prio < b_prio
	)
	return copy
