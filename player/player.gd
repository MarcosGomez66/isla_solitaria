extends CharacterBody2D

@export var speed := 230
@onready var sprite = $AnimatedSprite2D
@onready var interact_area = $InteractArea

const standar_speed: int = 230
# variables para el movimiento y las animaciones
var direction := Vector2.ZERO
var facing := 'down'
var anim = ''
var equipped := ''
# variables para la interaccion con recolectables
var interact_shape: Node2D
var nearby_object: Node = null
var interact_positions = {
	'right': Vector2(26.0, -36.0),
	'left': Vector2(-26.0, -36.0),
	'up': Vector2(0.0, -54.0),
	'down': Vector2(0.0, -17.0)
}

func _ready() -> void:
	interact_shape = interact_area.get_node('CollisionShape2D')
	EqManager.change_equip.connect(set_equipped_text)
	interact_area.connect('area_entered', _on_area_entered)
	interact_area.connect('area_exited', _on_area_exited)

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
	update_facing(direction)
	
func update_facing(dir: Vector2):
	if dir == Vector2.ZERO:
		return
	var new_facing = get_cardinal_direction(dir)
	if new_facing != facing:
		facing = new_facing
		update_interact_area()
	
func get_cardinal_direction(dir: Vector2) -> String:
	if abs(dir.y) > abs(dir.x):
		return 'down' if dir.y > 0 else 'up'
	else:
		return 'right' if dir.x > 0 else 'left'
		
func update_interact_area():
	interact_shape.position = interact_positions[facing]
		
func set_equipped_text():
	if EqManager.slots['main'] == null:
		equipped = ''
	else:
		equipped = EqManager.slots['main'].item_data.anim_id
	
func animation():
	if CraManager.is_crafting:
		speed = 0
		anim = 'crafting_with_hands'
	else:
		speed = standar_speed
		if direction == Vector2.ZERO:
			anim = equipped + 'idle_' + facing
		else:
			anim = equipped + 'walk_' + facing
	if sprite:
		if sprite.animation != anim:
			sprite.play(anim)

# metodos para la recoleccion de objetos
func _on_area_entered(area):
	if area.is_in_group('collectable'):
		set_near_object(area)
		
func _on_area_exited(area):
	if area.is_in_group('collectable'):
		clear_near_object(area)

func set_near_object(object_node):
	nearby_object = object_node
	
func clear_near_object(object_node):
	if nearby_object == object_node:
		nearby_object = null
		
func pick_item(object_node):
	var stack = Stack.new()
	stack.item_data = object_node.item_data
	stack.count = object_node.amount
	if InvManager.is_full(stack, InvManager.get_inventory(), InvManager.max_stack, InvManager.max_items):
		InvManager.show_full_message()
		return
	InvManager.add_item_to_inventory(stack)
	nearby_object = null
	object_node.queue_free()
