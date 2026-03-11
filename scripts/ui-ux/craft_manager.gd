extends Node

signal update_button
signal start_timer

var _current_recipe = null
var is_crafting := false
var craft_time := 0.0
var fuel = 'missing'
var tool = 'missing'

var hand_recipes: Array

enum craftState {
	NO_ING,
	BAD_ING,
	MISSING_FUEL,
	MISSING_TOOL,
	READY,
	CRAFTING
}

func get_current_recipe():
	return _current_recipe
	
func _ready() -> void:
	load_recipes()
	Inv_manager.inventory_changed.connect(check_ingredients)
	
func _process(delta: float) -> void:
	if is_crafting:
		update_button.emit()

func load_recipes():
	var dir = DirAccess.open("res://resources/recipes")
	if dir == null:
		push_error('recipe folder not found')
		
	for file in dir.get_files():
		if file.ends_with('.tres'):
			#print(file)
			var recipe = load("res://resources/recipes/" + file)
			print(recipe.result.item_data.name)
			hand_recipes.append(recipe)
			
func check_ingredients():
	_current_recipe = null
	fuel = 'missing'
	tool = 'missing'
	var best_recipe = null
	var best_score = -1
	for recipe in hand_recipes:
		if compare_ing(Inv_manager.get_ingredients(), recipe.ingredients):
			var score = 0
			for i in recipe.ingredients:
				score += i.count
			if score > best_score:
				best_score = score
				best_recipe = recipe
	if best_recipe:
		_current_recipe = best_recipe.duplicate(true)
		fuel = fuel_controller()
		tool = tool_controller()
	update_button.emit()
		
func compare_ing(entry: Array[Stack], recipe: Array[Stack]) -> bool:
	for r in recipe:
		var found = false
		for e in entry:
			if e.item_data.name == r.item_data.name and e.count >= r.count:
				found = true
				break
		if not found:
			return false
	return true

func fuel_controller():
	# por el momento solo retornar done
	if _current_recipe.fuel_req == 'none':
		return 'done'
	return 'missing'

func tool_controller():
	if _current_recipe.tool_req == 'none':
		return 'done'
	return 'missing'

func get_craft_status():
	if is_crafting:
		return craftState.CRAFTING
	if Inv_manager.get_ingredients().is_empty():
		return craftState.NO_ING
	if not _current_recipe:
		return craftState.BAD_ING
	if fuel_controller() == 'missing':
		return craftState.MISSING_FUEL
	if tool_controller() == 'missing':
		return craftState.MISSING_TOOL
	return craftState.READY

func on_done_buton_pressed():
	if is_crafting:
		return
	is_crafting = true
	consume_ingredients()
	craft_time = _current_recipe.craft_time
	start_timer.emit()
	
func consume_ingredients():
	var to_remove = []
	for ing in _current_recipe.ingredients:
		for ing2 in Inv_manager.get_ingredients():
			if ing.item_data == ing2.item_data:
				ing2.count -= ing.count
				if ing2.count <= 0:
					to_remove.append(ing2)
	for r in to_remove:
		Inv_manager.get_ingredients().erase(r)
	
func on_craftTimer_out():
	is_crafting = false
	Inv_manager.add_item_to_inventory(_current_recipe.result.item_data, _current_recipe.result.count)
	_current_recipe = null
	check_ingredients()
	
