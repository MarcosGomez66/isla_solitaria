extends Node

var dropped_item = preload('res://scenes/ui-ux/dropped_item.tscn')
var container: Node

func drop_item(data: ItemData, amount: int, position: Vector2):
	var item = dropped_item.instantiate()
	item.item_data = data
	item.amount = amount
	item.global_position = position
	container.add_child(item)
	
