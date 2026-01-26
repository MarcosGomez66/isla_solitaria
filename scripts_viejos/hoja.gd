extends Area2D

@export var item_name := "hoja"
@export var item_icon = Texture2D

#signal collected(item_data)

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	
func _on_body_entered(body):
	if body.is_in_group("player"):
		body.set_near_item(self)
		
func _on_body_exited(body):
	if body.is_in_group("player"):
		body.clear_near_item(self)
