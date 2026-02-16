extends Area2D

# datos que se van a pasar al invetario
@export var object_name := 'Piedra'
@export var object_icon = Texture2D
@export var object_description = 'Recurso basico de construccion, se puede recolectar directamente del suelo o extraerlo de peñascos con un pico'
@export var quantity = 1
var meta = {
	'type': 'resourse',
}

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	
func _on_body_entered(body):
	if body.is_in_group("player"):
		body.set_near_object(self)
		
func _on_body_exited(body):
	if body.is_in_group("player"):
		body.clear_near_object(self)
