extends "res://scripts/player/state.gd"

var state_type = StateMachine.State.RUN

func enter(_previous):
	var p = player
	p.anim.play("run")
	p.update_collision_bounds(p.RUN_SIZE, p.RUN_POS)

func physics_update(delta):
	var p = player

	var input_x = Input.get_axis("move_left", "move_right")

	# Flip
	if input_x != 0:
		p.anim.scale[0] = -1 if input_x < 0 else 1

	# Movement
	p.velocity.x = move_toward(p.velocity.x, input_x * p.speed, p.acceleration * delta)

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
