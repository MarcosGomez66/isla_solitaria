extends Node2D

#@onready var pause_menu = $CanvasLayer/PauseMenu
@onready var inventory_craft = $CanvasLayer/Control

func _input(event):
	"""if event.is_action_pressed("Pause"):
		if get_tree().paused:
			get_tree().paused = false
			#pause_menu.visible = false
		else:
			get_tree().paused = true
			#pause_menu.visible = true"""
	
	if event.is_action_pressed("craft"):
		inventory_craft.visible = !inventory_craft.visible
