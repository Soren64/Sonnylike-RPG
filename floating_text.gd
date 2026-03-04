# floating_text.gd
extends Node2D

@export var float_distance := 40.0
@export var duration := 1.0
@onready var label := $Label

func setup(text: String, color: Color):
	label.text = text
	label.modulate = color
	
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(0, -float_distance), duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "modulate:a", 0.0, duration)
	tween.finished.connect(queue_free)
