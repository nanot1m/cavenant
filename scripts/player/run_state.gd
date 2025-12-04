extends "res://scripts/player/state.gd"

var state_type = StateMachine.State.RUN

func enter(_previous):
	player.anim.play("run")
	player.anim.speed_scale = 1.0
	player.update_collision_bounds(player.RUN_SIZE, player.RUN_POS)
	
func exit(_next_state: int):
	player.anim.speed_scale = 1.0

func physics_update(delta):
	var p = player

	var input_x = Input.get_axis("move_left", "move_right")

	# Always apply ground friction first (realistic physics)
	p.velocity.x = move_toward(p.velocity.x, 0, p.friction * delta)

	# Then apply player input acceleration
	if input_x != 0:
		p.velocity.x = move_toward(p.velocity.x, input_x * p.speed, p.acceleration * delta)
		p.face_towards_dir(input_x)

	p.anim.speed_scale = max(1.0, abs(p.velocity.x) / 200)

	# HIT
	if Input.is_action_just_pressed("hit"):
		p.states.change_state(StateMachine.State.HIT)
		return

	# STOP - when no input OR running into a wall
	if input_x == 0:
		p.states.change_state(StateMachine.State.IDLE)
		return

	# Check if running into a wall
	if p.is_wall_detected():
		p.states.change_state(StateMachine.State.IDLE)
		return

	# CROUCH
	if Input.is_action_pressed("crouch") and p.is_on_floor():
		p.states.change_state(StateMachine.State.CROUCH_TRANSITION_DOWN)
		return

	# JUMP
	if Input.is_action_pressed("jump") and p.can_jump():
		p.states.change_state(StateMachine.State.JUMP)
		return

	# FALL
	if not p.is_on_floor():
		p.states.change_state(StateMachine.State.JUMP)
