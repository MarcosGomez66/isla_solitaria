extends Control

func _ready() -> void:
	visible = false
	$Panel/VBoxContainer/Button.connect("pressed", Callable(self, "_continue"))
	$Panel/VBoxContainer/Button2.connect("pressed", Callable(self, "_options"))
	$Panel/VBoxContainer/Button3.connect("pressed", Callable(self, "_exit"))
	
func _continue():
	visible = false
	get_tree().paused = false
	
func _options():
	print("accede a opciones")
	pass
	
func _exit():
	get_tree().paused = false
	get_tree().quit()
