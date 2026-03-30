extends Node

var popup_message: PackedScene = preload("res://scenes/ui-ux/popup_message.tscn")
var container: Node

func show_text(text: String, position: Vector2, color:= Color.WHITE):
	var instance = popup_message.instantiate()
	instance.text = text
	instance.modulate = color
	instance.position = position
	container.add_child(instance)
