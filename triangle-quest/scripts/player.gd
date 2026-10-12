extends CharacterBody2D

const arrow_tscn = preload("res://objects/arrow.tscn")

const SPEED = 17000.0
const SPEED_LIMIT: Vector2 = Vector2(300, 300)
const DASH_COOLDOWN = 3
var dash_timer: float = 0.0

var attack_timer: float = 0.0

var dir: Vector2 = Vector2.ZERO
var old_rot: float = 0.0
var rot: float = 0.0

func _ready() -> void:
	$Rotatable/Area2D.connect("area_entered", hit)
	add_to_group("Player")

func hit(area: Area2D):
	if (area.get_parent() is Enemy):
		area.get_parent().hit(global_position)

func _process(_delta: float) -> void:
	var aim: float = global_position.angle_to_point(get_global_mouse_position())
	$Rotatable.rotation = lerp_angle($Rotatable.rotation, aim, 0.3)
	if (attack_timer > 0.0): attack_timer -= _delta

func _physics_process(_delta: float) -> void:
	old_rot = rot
	if (!$Rotatable/Area2D/CollisionShape2D.disabled && attack_timer <= 0.0):
		$Rotatable/Area2D/CollisionShape2D.set_deferred("disabled", true)
	if (attack_timer <= 0.0 && Input.is_action_just_pressed("Attack")):
		$Rotatable/Area2D/CollisionShape2D.set_deferred("disabled", false)
		attack_timer = 0.2
	if (attack_timer <= 0.0 && Input.is_action_just_pressed("Util")):
		shoot_arrow()

	var input_x = Input.get_axis("Left", "Right")
	var input_y = Input.get_axis("Up", "Down")

	#dir = Vector2(input_x, input_y)

	#if (dir != Vector2.ZERO && dash_timer <= 0.0):
	#	velocity += (dir.normalized() * SPEED) * _delta
	#	velocity.x = clamp(velocity.x, -SPEED_LIMIT.x, SPEED_LIMIT.x)
	#	velocity.y = clamp(velocity.y, -SPEED_LIMIT.y, SPEED_LIMIT.y)
	#if dir.x == 0.0: velocity.x = lerp(velocity.x, 0.0, 0.1 if dash_timer <= 0.0 else 0.05)
	#if dir.y == 0.0: velocity.y = lerp(velocity.y, 0.0, 0.1 if dash_timer <= 0.0 else 0.05)

	var target_rot: float = lerpf(old_rot, rot, 0.00)
	velocity += (Vector2.RIGHT.rotated(target_rot) * 500) * _delta

	if (dash_timer > 0.0): dash_timer -= _delta
	elif (Input.is_action_just_pressed("Dash")):
		if (dir == Vector2.ZERO): dir = global_position.direction_to(get_global_mouse_position())
		velocity = dir * 700
		dash_timer = 0.2

	rot = $Rotatable.rotation

	move_and_slide()

func shoot_arrow():
	velocity = -global_position.direction_to(get_global_mouse_position()) * 250

	var arrow: Arrow = arrow_tscn.instantiate()
	arrow.rotation = $Rotatable.rotation
	arrow.velocity = global_position.direction_to(get_global_mouse_position()) * 2000
	arrow.global_position = global_position
	get_tree().current_scene.add_child(arrow)
