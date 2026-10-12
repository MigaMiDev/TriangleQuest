class_name Enemy
extends Node2D

const kill_p_tscn = preload("res://particles/kill_particles.tscn")

var velocity: Vector2 = Vector2.ZERO

var health: int = 5
var stun_timer: float = 0.0

func hit(origin: Vector2):
	velocity = (global_position - origin).normalized() * 700
	health -= 1
	stun_timer = 0.6

	match health:
		4: $ColorRect.color = Color.RED
		3: $ColorRect.color = Color.ORANGE_RED
		2: $ColorRect.color = Color.PALE_VIOLET_RED
		1: $ColorRect.color = Color.WHITE
		0: kill()

func kill():
	ParticleSystem.create_particle(ParticleTypes.KILL_EFFECT, global_position)
	queue_free()
	

func _physics_process(_delta: float) -> void:
	if (stun_timer <= 0.0):
		if (get_tree().get_first_node_in_group("Player") != null):
			velocity = ((global_position - get_tree().get_first_node_in_group("Player").global_position).normalized() * -5000) * _delta
	else:
		stun_timer -= _delta
		velocity = lerp(velocity, Vector2.ZERO, 0.1)

	global_position += velocity * _delta
