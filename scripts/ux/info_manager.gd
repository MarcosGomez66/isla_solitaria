extends Node

var info_message: PackedScene = preload("res://scenes/ui-ux/info_message.tscn")
var container: Node

func show_text(text: String, position: Vector2, color:= Color.BEIGE):
	var instance = info_message.instantiate()
	instance.text = text
	instance.modulate = color
	instance.global_position = position
	container.add_child(instance)
