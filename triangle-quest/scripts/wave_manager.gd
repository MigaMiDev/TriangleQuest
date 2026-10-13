extends Node

@export var enemy_scene: PackedScene
@export var spawn_radius: float = 600.0

const QuizScript = preload("res://scripts/quiz.gd")

var wave: int = 0
var alive: int = 0
var to_spawn: int = 0
var wave_active: bool = false
var hud: Label

func _ready() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Label.new()
	hud.position = Vector2(16, 16)
	hud.add_theme_font_size_override("font_size", 24)
	layer.add_child(hud)

	await get_tree().create_timer(1.0).timeout
	start_wave()

func start_wave() -> void:
	wave += 1
	to_spawn = 3 + wave * 2
	wave_active = true
	_update_hud()

	var delay: float = maxf(0.2, 0.8 - wave * 0.05)
	while to_spawn > 0:
		_spawn_enemy()
		await get_tree().create_timer(delay).timeout

	_check_wave_end()

func _spawn_enemy() -> void:
	var player := get_tree().get_first_node_in_group("Player")
	if player == null or enemy_scene == null:
		return

	var enemy: Enemy = enemy_scene.instantiate()
	@warning_ignore("integer_division")
	enemy.health = 1 + (wave - 1) / 2
	enemy.died.connect(_on_enemy_died)
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = player.global_position + Vector2.RIGHT.rotated(randf() * TAU) * spawn_radius

	alive += 1
	to_spawn -= 1
	_update_hud()

func _on_enemy_died() -> void:
	alive -= 1
	_update_hud()
	_check_wave_end()

func _check_wave_end() -> void:
	if wave_active and to_spawn == 0 and alive == 0:
		wave_active = false
		_wave_complete()

func _wave_complete() -> void:
	hud.text = "¡Oleada %d completada!" % wave
	await get_tree().create_timer(1.0).timeout

	var quiz = QuizScript.new()
	get_tree().current_scene.add_child(quiz)
	var upgrade: String = await quiz.finished

	if upgrade != "":
		var player := get_tree().get_first_node_in_group("Player")
		if player:
			player.apply_upgrade(upgrade)

	start_wave()

func _update_hud() -> void:
	hud.text = "Oleada %d   |   Enemigos: %d" % [wave, alive + to_spawn]
