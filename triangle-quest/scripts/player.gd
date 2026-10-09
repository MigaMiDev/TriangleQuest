extends CharacterBody2D


const SPEED = 17000.0
const SPEED_LIMIT: Vector2 = Vector2(300, 300)
const DASH_COOLDOWN = 3
var dash_timer: float = 0.0

var attack_timer: float = 0.0

var dir: Vector2 = Vector2.ZERO

func _process(_delta: float) -> void:
	if (dir != Vector2.ZERO): $Rotatable.rotation = lerp_angle($Rotatable.rotation, dir.normalized().angle(), 0.1)
	if (attack_timer > 0.0): attack_timer -= _delta
	$Rotatable/ColorRect.visible = attack_timer > 0.0

func _physics_process(_delta: float) -> void:
	if (attack_timer <= 0.0 && Input.is_action_just_pressed("Attack")): attack_timer = 0.2

	var input_x = Input.get_axis("Left", "Right")
	var input_y = Input.get_axis("Up", "Down")

	dir = Vector2(input_x, input_y)

	if (dir != Vector2.ZERO):
		velocity += (dir.normalized() * SPEED) * _delta
		if dash_timer <= 0.0:
			velocity.x = clamp(velocity.x, -SPEED_LIMIT.x, SPEED_LIMIT.x)
			velocity.y = clamp(velocity.y, -SPEED_LIMIT.y, SPEED_LIMIT.y)
	if dir.x == 0.0: velocity.x = lerp(velocity.x, 0.0, 0.1)
	if dir.y == 0.0: velocity.y = lerp(velocity.y, 0.0, 0.1)

	if (dash_timer > 0.0): dash_timer -= _delta
	elif (Input.is_action_just_pressed("Dash")):
		velocity += velocity
		dash_timer = 0.1

	move_and_slide()
