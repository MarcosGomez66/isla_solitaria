extends Label

var float_speed := 30
var lifetime := 1.5

func _ready() -> void:
	modulate.a = 1.0
	animate()

func animate():
	var tween = create_tween()
	tween.tween_property(self, 'position:y', position.y - 50, lifetime)
	tween.parallel().tween_property(self, 'modulate:a', 0.0, lifetime)
	tween.tween_callback(queue_free)
