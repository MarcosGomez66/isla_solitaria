extends Resource
class_name Stack

@export var item_data: ItemData
@export var count: int

#func _init(data: ItemData, amount: int) -> void:
	#item_data = data
	#count = amount
