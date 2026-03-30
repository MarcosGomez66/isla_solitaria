extends Area2D

@export var target_scene: String
@export var spawn_id: String

func _ready() -> void:
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.is_in_group('player'):
		GameManager.call_deferred('change_map', target_scene, spawn_id)
	
