extends "res://scripts/player/state.gd"

var state_type: StateMachine.State = StateMachine.State.WALL_SLIDE

# Grace period as extra safety net
const WALL_GRACE_PERIOD = 0.1  # seconds
var wall_grace_timer: float = 0.0

func enter(_previous: StateMachine.State) -> void:
	player.update_collision_bounds(player.WALL_SLIDE_SIZE, player.WALL_SLIDE_POS)
	if (player.is_facing_right()):
		player.anim.position.x += 4
	else:
		player.anim.position.x -= 4
	# Reset grace timer when entering wall slide
	wall_grace_timer = WALL_GRACE_PERIOD
	player.anim.play("wall_slide")

func exit(_next_state: StateMachine.State) -> void:
	player.anim.position.x = 0

func physics_update(delta: float) -> void:
	# gravity
	if not player.is_on_floor():
		player.velocity.y = player.wall_slide_speed

	if player.is_on_floor():
		player.states.change_state(StateMachine.State.IDLE)
		return

	var is_facing_right: bool = player.is_facing_right()
	var input_x: float = Input.get_axis("move_left", "move_right")

	# Check if player is holding toward the wall
	var holding_toward_wall: bool = input_x == 0 or (is_facing_right and Input.is_action_pressed("move_right")) or (not is_facing_right and Input.is_action_pressed("move_left"))

	# Combine wall detection and input with grace period
	if player.is_wall_detected() and holding_toward_wall:
		wall_grace_timer = WALL_GRACE_PERIOD
	else:
		wall_grace_timer -= delta

	# Only exit if grace period has expired
	if wall_grace_timer <= 0:
		player.states.change_state(StateMachine.State.JUMP)
		player.velocity.x = move_toward(player.velocity.x, input_x * player.speed, player.acceleration * delta)
		return

	if Input.is_action_just_pressed("jump"):
		player.velocity.y = -player.jump_force
		# push off the wall
		if is_facing_right:
			player.velocity.x = -player.wall_jump_speed_x
		else:
			player.velocity.x = player.wall_jump_speed_x
		player.face_towards_dir(sign(player.velocity.x))
		player.states.change_state(StateMachine.State.JUMP)
		return
	
	if Input.is_action_just_pressed("crouch"):
		player.states.change_state(StateMachine.State.JUMP)
		return

	
