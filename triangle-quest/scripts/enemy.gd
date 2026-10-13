class_name Enemy
extends Node2D

signal died

var velocity: Vector2 = Vector2.ZERO

var health: int = 5
var max_health: int = 5
var stun_timer: float = 0.0

func _ready() -> void:
	max_health = health
	add_to_group("Enemies")

func hit(origin: Vector2, damage: int = 1):
	if health <= 0:
		return # already dead (avoids counting a death twice)

	velocity = (global_position - origin).normalized() * 700
	health -= damage
	stun_timer = 0.6

	if health <= 0:
		died.emit()
		queue_free()
		return

	var ratio := float(health) / max_health
	$Polygon2D.color = Color.RED.lerp(Color.WHITE, 1.0 - ratio)

func _process(delta: float) -> void:
	$Polygon2D.rotation = atan2(-velocity.y, -velocity.x)

func _physics_process(_delta: float) -> void:
	if (stun_timer <= 0.0):
		if (get_tree().get_first_node_in_group("Player") != null):
			velocity = ((global_position - get_tree().get_first_node_in_group("Player").global_position).normalized() * -9000) * _delta
	else:
		stun_timer -= _delta
		velocity = lerp(velocity, Vector2.ZERO, 0.1)

	global_position += velocity * _delta
