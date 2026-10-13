class_name Arrow
extends Node2D

var velocity: Vector2
var timer: Timer
var damage: int = 1
var explosion_radius: float = 0.0

func _ready() -> void:
	$Area2D.connect("area_entered", hit)

	timer = Timer.new()
	timer.autostart = true
	timer.one_shot = false
	timer.wait_time = 2.0

	timer.timeout.connect(queue_free)

	get_tree().current_scene.add_child.call_deferred(timer)

func hit(area: Area2D):
	var target = area.get_parent()
	if (target is Enemy):
		target.hit(global_position, damage)
		if explosion_radius > 0.0:
			_explode(target)
		queue_free()

func _explode(already_hit: Node) -> void:
	for e in get_tree().get_nodes_in_group("Enemies"):
		if e != already_hit and global_position.distance_to(e.global_position) <= explosion_radius:
			e.hit(global_position, damage)

	var fx := ExplosionFx.new()
	fx.radius = explosion_radius
	fx.global_position = global_position
	get_tree().current_scene.add_child(fx)

func _physics_process(_delta: float) -> void:
	global_position += velocity * _delta
