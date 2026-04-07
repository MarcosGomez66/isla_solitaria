extends Node

var popup_message: PackedScene = preload("res://scenes/ui-ux/popup_message.tscn")
var container: Node

func show_text(text: String, position: Vector2, color:= Color(1.0, 0.89, 0.941, 1.0)):
	var instance = popup_message.instantiate()
	instance.text = text
	instance.modulate = color
	instance.global_position = position
	container.add_child(instance)
