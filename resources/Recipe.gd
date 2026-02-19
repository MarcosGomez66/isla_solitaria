extends Resource
class_name Recipe

@export var ingredients: Array[InventoryItem]
@export var result: ItemData
@export var result_count: int
@export var fuel_req: String
@export var tool_req: String
@export var craft_time: float = 1.0
