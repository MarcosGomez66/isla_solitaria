extends CharacterBody2D

@export var speed = 200
@onready var anim = $AnimatedSprite2D

var inventory: Array = []
var nearby_item: Node = null
var max_items := 25
var max_stack := 5
#signal inventory_updated(inventory)

func _physics_process(delta):
	var direction = Vector2.ZERO
	#movimientos
	if Input.is_action_pressed("ui_up"):
		direction.y -=1
	if Input.is_action_pressed("ui_down"):
		direction.y +=1
	if Input.is_action_pressed("ui_left"):
		direction.x -=1
	if Input.is_action_pressed("ui_right"):
		direction.x +=1
		
	direction = direction.normalized()
	velocity = direction * speed
	move_and_slide()
	
	#reproducir animacion segun direccion
	if direction == Vector2.ZERO:
		if anim.animation.begins_with("walk"):
			anim.animation = anim.animation.replace("walk", "idle")
	else:
		if abs(direction.y) > abs(direction.x):
			if direction.y > 0:
				anim.animation = "walk_down"
			else:
				anim.animation = "walk_up"
		else:
			if direction.x > 0:
				anim.animation = "walk_right"
			else:
				anim.animation = "walk_left"
		if not anim.is_playing():
			anim.play()
			
	#Recoger objeto
	if Input.is_action_just_pressed("pick") and nearby_item:
		pick_item(nearby_item)

func set_near_item(item_node):
	nearby_item = item_node
	
func clear_near_item(item_node):
	if nearby_item == item_node:
		nearby_item = null
		
func pick_item(item_node):
	var ui = get_tree().root.get_node("Main/CanvasLayer/inventory_craft_ui")
	#buscar slots disponibles hasta llenar
	for slot in inventory:
		if slot.name == item_node.item_name and slot.count < max_stack:
			#var space_left = max_stack - slot.count
			slot.count += 1
			if ui:
				ui.update_inventory()
			item_node.queue_free()
			nearby_item = null
			return
	#comprueba si los slots estan todos ocupados
	if inventory.size() >= max_items:
		print("inventario lleno")
		return
	#si no hay slots disponibles crea uno
	var new_slot = {
		"name":item_node.item_name,
		"icon":item_node.item_icon,
		"count":1
	}
	inventory.append(new_slot)
	
	#actualiza el ui
	if ui:
		ui.update_inventory()
		
	#se elimina el objeto
	item_node.queue_free()
	nearby_item = null
