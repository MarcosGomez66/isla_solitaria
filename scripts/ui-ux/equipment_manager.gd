extends Node
class_name EquipmentManager

var main_space: Array[Stack]
var armor: Array[Stack]
var backpack: Array[Stack]
var additional1: Array[Stack]
var additional2: Array[Stack]

var canbein_main: Array = ['tool', 'weapon', 'throwable']

func check_spaces(data: Stack):
	if data.item_data.type in canbein_main:
		set_equip(data, main_space)
		return
	if data.item_data.subtype == 'armor':
		set_equip(data, armor)
		return
	if data.item_data.subtype == 'backpack':
		set_equip(data, backpack)
		return

func set_equip(data: Stack, space: Array[Stack]):
	if space.is_empty():
		Inv_manager.move_one_item(data, Inv_manager.get_inventory(), space, 1, 1)
		return
	replace_equip(data, space)
	
func replace_equip(data: Stack, space: Array[Stack]):
	Inv_manager.move_one_item(space[0], space, Inv_manager.get_inventory(), Inv_manager.max_stack, Inv_manager.max_items)
	set_equip(data, space)

func check_quit(data: Stack):
	if data.item_data.type in canbein_main:
		quit_equip(data, main_space)
		return
	if data.item_data.subtype == 'armor':
		quit_equip(data, armor)
		return
	if data.item_data.subtype == 'backpack':
		quit_equip(data, backpack)
		return
	
func quit_equip(data: Stack, space: Array[Stack]):
	Inv_manager.move_one_item(data, space, Inv_manager.get_inventory(), Inv_manager.max_stack, Inv_manager.max_items)
		
#segundo intento
var slots = {
	'main': null,
	'armor': null,
	'backpack': null,
	'additional1': null,
	'additional2': null
}
		
func equip(data: Stack):
	var slot_name = get_slot_name(data)
	if slot_name == '' or not slots.has(slot_name):
		return
		
	if slots[slot_name] != null:
		Inv_manager.add_item_to_inventory(slots[slot_name].item_data, slots[slot_name].count)
	slots[slot_name] = data
	Inv_manager.get_inventory().erase(data)
	Inv_manager.inventory_changed.emit()

func unequip(data: Stack):
	var slot_name = get_slot_name(data)
	if not slots.has(slot_name):
		return
		
	var item = slots[slot_name]
	if item == null:
		return
		
	Inv_manager.add_item_to_inventory(item.item_data, item.count)
	slots[slot_name] = null
	Inv_manager.inventory_changed.emit()

func get_slot_name(data: Stack) -> String:
	if data.item_data.type in canbein_main:
		return 'main'
	if data.item_data.subtype == 'armor':
		return 'armor'
	if data.item_data.subtype == 'backpack':
		return 'backpack'
	return ''
