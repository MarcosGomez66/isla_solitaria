extends Node

#@onready var pause_menu = $CanvasLayer/PauseMenu
@onready var inventory_craft_ui = $CanvasLayer/InventoryCraftUI
@onready var equipment_ui = $CanvasLayer/EquipmentUI

func _ready() -> void:
	PopupManager.container = $World

func _input(event):
	if event.is_action_pressed("open_craft"):
		inventory_craft_ui.visible = !inventory_craft_ui.visible
		if equipment_ui.visible:
			equipment_ui.visible = false
	
	if event.is_action_pressed('open_equipment'):
		equipment_ui.visible = !equipment_ui.visible
		if inventory_craft_ui.visible:
			inventory_craft_ui.visible = false
