extends CharacterBody2D

@export var speed := 200

# variables para el movimiento y las animaciones
var direction := Vector2.ZERO
var facing := "down"

# variables para la interaccion con recolectables
var nearby_object: Node = null

# todo lo que se realiza continuamente va en el physics process
func _physics_process(delta):
	movement(delta)
	animation()
	
	if Input.is_action_just_pressed("interact"):
		if nearby_object:
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
	Inv_manager.add_item_to_inventory(object_node.item_data, object_node.quantity)
	nearby_object = null
	object_node.queue_free()
	
