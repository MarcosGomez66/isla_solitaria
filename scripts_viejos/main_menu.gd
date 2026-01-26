extends Control

func _ready() -> void:
	$VBoxContainer/Button.connect("pressed", Callable(self, "_new_game"))
	$VBoxContainer/Button2.connect("pressed", Callable(self, "_load_game"))
	$VBoxContainer/Button3.connect("pressed", Callable(self, "_options"))
	$VBoxContainer/Button4.connect("pressed", Callable(self, "_quit"))
	
func _new_game():
	get_tree().change_scene_to_file("res://main.tscn")
	
func _load_game():
	print("accede a load game")
	
func _options():
	pass
	
func _quit():
	get_tree().quit()
