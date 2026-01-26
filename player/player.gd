extends CharacterBody2D

@export var speed := 200

# variables para el movimiento y las animaciones
var direction := Vector2.ZERO
var facing := "down"

# variables para la interaccion con recolectables
var nearby_object: Node = null

# varibles para el inventario
var inventory: Array = []
var max_object = 10
var max_stack = 5

# todo lo que se realiza continuamente va en el physics process
func _physics_process(delta):
	movement(delta)
	animation()
	
	if Input.is_action_just_pressed("interact"):
		pick_item(nearby_object)

func movement(delta):
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()
	
	if direction.x > 0:
		facing = 'right'
	elif direction.x < 0:
		facing = 'left'
	elif direction.y < 0:
		facing = 'up'
	elif direction.y > 0:
		facing = 'down'
		
func animation():
	var anim = ''
	if direction == Vector2.ZERO:
		anim = 'idle_' + facing
	else:
		anim = 'walk_' + facing
	if $AnimatedSprite2D.animation != anim:
		$AnimatedSprite2D.play(anim)

# metodos para la recoleccion de objetos
func set_near_object(object_node):
	nearby_object = object_node
	
func clear_near_object(object_node):
	if nearby_object == object_node:
		nearby_object = null
		
func pick_item(object_node):
	var ui = get_tree().root.get_node('testscene/CanvasLayer/Control')
	# buscar slots ocupados disponibles hasta llenar
	if object_node:
		for slot in inventory:
			if slot.name == object_node.object_name and slot.count < max_stack:
				slot.count += object_node.quantity
				if slot.count > max_stack:
					var dif = slot.count - max_stack
					slot.count = max_stack
					if inventory.size() >= max_object:
						return
					var new_slot = {
						'name': object_node.object_name,
						'icon': object_node.object_icon,
						'description': object_node.object_description,
						'count': dif
					}
					inventory.append(new_slot)
				# actualiza el ui
				if ui:
					ui.update_inventory()
				object_node.queue_free()
				nearby_object = null
				return
		# busca si hay espacio en el inventario
		if inventory.size() >= max_object:
			return
		# si hay espacio crea un nuevo slot
		var new_slot = {
			'name': object_node.object_name,
			'icon': object_node.object_icon,
			'description': object_node.object_description,
			'count': object_node.quantity
		}
		inventory.append(new_slot)
		# actualiza el ui
		if ui:
			ui.update_inventory()
		object_node.queue_free()
		nearby_object = null
