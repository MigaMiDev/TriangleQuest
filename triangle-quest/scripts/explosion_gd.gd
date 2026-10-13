class_name ExplosionFx
extends Node2D

var radius: float = 80.0

func _ready() -> void:
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.25)
	t.tween_callback(queue_free)

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color(1, 0.5, 0.1, 0.5))
