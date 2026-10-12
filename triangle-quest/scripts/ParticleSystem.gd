extends Node

func create_particle(particle_type: PackedScene, pos: Vector2, amount: int = 1, offset: int = 0):
	var particle: CPUParticles2D = particle_type.instantiate()
	particle.connect("finished", Callable(particle, "queue_free"), 0)
	add_particle(particle, pos, amount, offset)

func add_particle(particle: CPUParticles2D, pos: Vector2, amount: int = 1, offset: int = 0):
	for i in range(amount):
		pos = pos + Vector2(randi_range(-offset, offset), randi_range(-offset, offset))

		var cloned_particle = particle.duplicate()
		cloned_particle.global_position = pos

		var group_node: Node = null
		group_node = get_tree().current_scene

		group_node.add_child(cloned_particle)
		cloned_particle.connect("finished", Callable(cloned_particle, "queue_free"), 0)
		cloned_particle.emitting = true
