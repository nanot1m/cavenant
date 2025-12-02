extends CharacterBody2D


const SPEED = 600.0
const JUMP_VELOCITY = -500.0

enum {IDLE, RUNNING, CROUCHED, JUMP_UP, JUMP_IDLE, JUMP_DOWN}
var state = null

@onready var animation_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	change_state(IDLE)
	
func change_state(new_state):
	if state == new_state: return
	print("Change state from ", state, " to ", new_state)
	
	if new_state == CROUCHED:
		state = new_state
		animation_sprite.play("crouch_down")
		collision_shape.shape.size = Vector2(22, 23)
		collision_shape.position = Vector2(0, 6)
		await animation_sprite.animation_finished
	else: if state == CROUCHED:
		state = new_state
		animation_sprite.play("crouch_up")
		await animation_sprite.animation_finished
	
	state = new_state
	collision_shape.position = Vector2(0, 0)
	match state:
		IDLE:
			animation_sprite.play("idle")
			collision_shape.shape.size = Vector2(22, 35)
		RUNNING:
			animation_sprite.play("run")
			collision_shape.shape.size = Vector2(35, 35)
		CROUCHED:
			animation_sprite.play("crouch_idle")
			collision_shape.shape.size = Vector2(22, 23)
			collision_shape.position = Vector2(0, 6)
		JUMP_IDLE:
			animation_sprite.play("jump_idle")
			collision_shape.shape.size = Vector2(22, 35)
		JUMP_DOWN:
			animation_sprite.play("jump_down")
			collision_shape.shape.size = Vector2(22, 35)
		JUMP_UP:
			animation_sprite.play("jump_up")
			collision_shape.shape.size = Vector2(22, 35)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_pressed("crouch") and is_on_floor():
		change_state(CROUCHED)
		velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		var direction := Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x = direction * SPEED
			animation_sprite.scale[0] = 1 if direction > 0 else -1
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		if is_on_floor():
			if velocity.x == 0:
				change_state(IDLE)
			else:
				change_state(RUNNING)
		else:
			if abs(velocity.y) < 100:
				change_state(JUMP_IDLE)
			else: if velocity.y < 0:
				change_state(JUMP_UP)
			else:
				change_state(JUMP_DOWN)

	move_and_slide()
