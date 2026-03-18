extends Node
class_name InventoryManager

signal inventory_changed

var _inventory: Array[Stack] = []
var _ingredients: Array[Stack] = []
var max_stack = 5
var max_items = 10

func get_inventory():
	return _inventory
	
func get_ingredients():
	return _ingredients

func add_item_to_inventory(data: ItemData, amount: int):
	while amount > 0:
		#var stack_found = false
		for stack in _inventory:
			if stack.item_data == data and stack.count < max_stack and data.stackable:
				var space = max_stack - stack.count
				var add = min(space, amount)
				stack.count += add
				amount -= add
				#stack_found = true
				break
		if amount <= 0:
			break
		if _inventory.size() >= max_items:
			break
		var new_amount = min(max_stack, amount)
		var stack = Stack.new()
		stack.item_data = data
		stack.count = new_amount
		_inventory.append(stack)
		amount -= new_amount
	inventory_changed.emit()

func move_to_ingredients(data: Stack):
	move_one_item(data, _inventory, _ingredients, 500)
	
func move_to_inventory(data: Stack):
	move_one_item(data, _ingredients, _inventory, max_stack)

func move_one_item(data: Stack, from: Array, to: Array, max_s: int):
	for stack in to:
		if stack.item_data == data.item_data and stack.count < max_s and data.item_data.stackable:
			stack.count += 1
			data.count -= 1
			if data.count <= 0:
				from.erase(data)
			inventory_changed.emit()
			return
	
	if to.size() >= max_items:
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
