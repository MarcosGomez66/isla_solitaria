extends Control

@onready var inv_container = $Panel/InvScroll/InvContainer
@onready var ing_container = $Panel/IngScroll/IngContainer

@onready var done_button = $Panel/DoneButton
@onready var done_button_info = $Panel/ButtonText
@onready var out_item_container = $Panel/OutItem
@onready var craft_timer = $Panel/CraftTimer

@onready var inventory_space_label = $Panel/SpaceLabel

@export var item_card_scene: PackedScene

func _ready() -> void:
	visible = false
	InvManager.inventory_changed.connect(redraw)
	CraManager.update_button.connect(done_button_status)
	CraManager.start_timer.connect(start_timer)
	done_button.pressed.connect(CraManager.on_done_buton_pressed)
	craft_timer.timeout.connect(CraManager.on_craftTimer_out)
	redraw()

func _process(delta: float) -> void:
	if visible == false:
		InvManager.clear_ingrediens()

func draw_inventory():
	# se elimina los objetos para no duplicar
	for ch in inv_container.get_children():
		ch.queue_free()
		
	var inv_sort = InvManager.sort_by_prio(['resource'])
	
	for i in inv_sort:
		var card = item_card_scene.instantiate()
		inv_container.add_child(card)
		card.set_item(i)
		card.set_mode(ItemCard.CardMode.INVENTORY)
		card.top_pressed.connect(InvManager.move_to_ingredients)
		card.middle_pressed.connect(InvManager.move_stack_to_ingredients)

func draw_ingredients():
	for ch in ing_container.get_children():
		ch.queue_free()
		
	for i in InvManager.get_ingredients():
		var card = item_card_scene.instantiate()
		ing_container.add_child(card)
		card.set_item(i)
		card.set_mode(ItemCard.CardMode.INGREDIENTS)
		card.top_pressed.connect(InvManager.move_to_inventory)
		card.middle_pressed.connect(InvManager.move_stack_to_inventory)
		
func draw_output_item():
	for i in out_item_container.get_children():
		i.queue_free()
	if CraManager.get_current_recipe():
		var card = item_card_scene.instantiate()
		out_item_container.add_child(card)
		card.set_item(CraManager.get_current_recipe().result)
		card.set_mode(ItemCard.CardMode.OUT)
	
func done_button_status():
	match CraManager.get_craft_status():
		CraManager.craftState.NO_ING:
			done_button.disabled = true
			done_button_info.text = '↑↑↑ \n Añadir ingredientes'
		CraManager.craftState.BAD_ING:
			done_button.disabled = true
			done_button_info.text = '↑↑↑ \n Ingredientes incorrectos'
		CraManager.craftState.MISSING_FUEL:
			done_button.disabled = true
			done_button_info.text = '←←← \n Añadir combustible'
		CraManager.craftState.MISSING_TOOL:
			done_button.disabled = true
			done_button_info.text = '→→→ \n Añadir herramienta'
		CraManager.craftState.READY:
			done_button.disabled = false
			done_button_info.text = '↓↓↓ \n Todo listo'
		CraManager.craftState.CRAFTING:
			var remaining = craft_timer.time_left
			done_button_info.text = 'fabricando: %.1f s' % remaining

func start_timer():
	craft_timer.start(CraManager.craft_time)
	
func redraw():
	draw_inventory()
	draw_ingredients()
	draw_output_item()
	inventory_space_label.text = InvManager.update_inventory_space()
