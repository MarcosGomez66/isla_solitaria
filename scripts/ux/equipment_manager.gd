extends Node

signal change_equip
var canbein_main: Array = ['tool', 'weapon', 'throwable']
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
		InvManager.add_item_to_inventory(slots[slot_name])
	slots[slot_name] = data
	InvManager.get_inventory().erase(data)
	InvManager.inventory_changed.emit()
	change_equip.emit()

func unequip(data: Stack):
	var slot_name = get_slot_name(data)
	if not slots.has(slot_name):
		return
		
	var item = slots[slot_name]
	if item == null:
		return
		
	InvManager.add_item_to_inventory(item)
	slots[slot_name] = null
	InvManager.inventory_changed.emit()
	change_equip.emit()

func get_slot_name(data: Stack) -> String:
	if data.item_data.type in canbein_main:
		return 'main'
	if data.item_data.subtype == 'armor':
		return 'armor'
	if data.item_data.subtype == 'backpack':
		return 'backpack'
	return ''
