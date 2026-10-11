extends Node2D

const enemy_tscn = preload("res://objects/enemy.tscn")

var timer: Timer

func _ready() -> void:
	timer = Timer.new()
	timer.autostart = true
	timer.one_shot = false
	timer.wait_time = 1.0

	timer.timeout.connect(spawn)

	get_tree().current_scene.add_child.call_deferred(timer)

func spawn():
	timer.wait_time = 2.0 + randi_range(0, 2)
	var slot: Node2D = get_child(randi_range(0, 1)).get_child(randi_range(0, 7))

	var enemy: Enemy = enemy_tscn.instantiate()
	enemy.global_position = slot.global_position
	get_tree().current_scene.add_child(enemy)
