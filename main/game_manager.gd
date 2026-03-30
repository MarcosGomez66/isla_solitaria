extends Node

var player
var current_map

func _ready() -> void:
	start_game()

func start_game():
	load_map('res://maps/mapa_costa_prueba.tscn')
	
func load_map(path: String):
	#borrar el mapa anterior
	if current_map:
		current_map.queue_free()
		
	var map_scene = load(path)
	current_map = map_scene.instantiate()
	get_tree().root.get_node('Test/World').add_child(current_map)
	spawn_player()
	
func spawn_player():
	if player == null:
		player = preload('res://player/player.tscn').instantiate()
		get_tree().root.get_node('Test/Entities').add_child(player)
		
	#buscar un spawn
	var spawn = current_map.get_node('SpawnPoints/SpawnNorth')
	player.global_position = spawn.global_position

func change_map(path: String, spawn_name: String):
	if current_map:
		current_map.queue_free()
		
	var map_scene = load(path)
	current_map = map_scene.instantiate()
	get_tree().root.get_node('Test/World').add_child(current_map)
	var spawn = current_map.get_node(spawn_name)
	player.global_position = spawn.global_position
