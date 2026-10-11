class_name Arrow
extends Node2D

var velocity: Vector2
var timer: Timer

func _ready() -> void:
	$Area2D.connect("area_entered", hit)

	timer = Timer.new()
	timer.autostart = true
	timer.one_shot = false
	timer.wait_time = 2.0

	timer.timeout.connect(queue_free)

	get_tree().current_scene.add_child.call_deferred(timer)

func hit(area: Area2D):
	if (area.get_parent() is Enemy):
		area.get_parent().hit(global_position)

		queue_free()

func _physics_process(_delta: float) -> void:
	global_position += velocity * _delta
