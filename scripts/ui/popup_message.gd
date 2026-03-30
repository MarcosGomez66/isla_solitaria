extends Label

var float_speed := 30
var lifetime := 1.5

var add_message = LabelSettings.new()
var delete_message = LabelSettings.new()

func _ready() -> void:
	define_label_settings()
	modulate.a = 1.0
	animate()

func animate():
	var tween = create_tween()
	tween.tween_property(self, 'position:y', position.y - 50, lifetime)
	tween.parallel().tween_property(self, 'modulate:a', 0.0, lifetime)
	tween.tween_callback(queue_free)

func define_label_settings():
	#add
	add_message.line_spacing = 0.0
	add_message.font_size = 16
	add_message.font_color = Color(254, 228, 179, 255)
	add_message.outline_size = 3
	add_message.outline_color = Color(0, 0, 0, 255)
	#delete
	delete_message.line_spacing = 0.0
	delete_message.font_size = 16
	delete_message.font_color = Color(254, 53, 33, 255)
	delete_message.outline_size = 3
	delete_message.outline_color = Color(0, 0, 0, 255)
