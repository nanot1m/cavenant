extends "res://scripts/player/state.gd"

var state_type = StateMachine.State.IDLE

func enter(_previous):
	var p = player
	p.anim.play("idle")
	p.update_collision_bounds(p.STAND_SIZE, p.STAND_POS)

func physics_update(delta):
	var p = player
	
	p.velocity.x = move_toward(p.velocity.x, 0, p.friction * delta)

	# HIT
	if Input.is_action_just_pressed("hit"):
		p.states.change_state(StateMachine.State.HIT)
		return

	# CROUCH
	if Input.is_action_pressed("crouch") and p.is_on_floor():
		p.states.change_state(StateMachine.State.CROUCH_TRANSITION_DOWN)
		return

	# RUN
	var input_x = Input.get_axis("move_left", "move_right")
	if abs(input_x) > 0:
		# Check if running into a wall
		var moving_right = input_x > 0
		var facing_right = p.is_facing_right()

		# Update facing direction based on input
		if moving_right != facing_right:
			p.face_towards_dir(int(input_x))

		# Only transition to run if not pushing against a wall
		if not p.is_wall_detected():
			p.states.change_state(StateMachine.State.RUN)
			return

	# JUMP
	if Input.is_action_just_pressed("jump") and p.can_jump():
		p.states.change_state(StateMachine.State.JUMP)
		return

	# gravity
	if not p.is_on_floor():
		print("Player is falling")
		p.states.change_state(StateMachine.State.JUMP)
