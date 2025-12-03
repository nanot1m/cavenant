extends "res://state.gd"

func enter(_previous):
	var p = player
	p.anim.play("run")
	p.collision_shape.shape.size = p.RUN_SIZE
	p.collision_shape.position = p.RUN_POS

func physics_update(delta):
	var p = player

	var input_x = Input.get_axis("move_left", "move_right")

	# Flip
	if input_x != 0:
		p.anim.scale[0] = -1 if input_x < 0 else 1

	# Movement
	p.velocity.x = move_toward(p.velocity.x, input_x * p.SPEED, p.ACCEL * delta)

	# HIT
	if Input.is_action_just_pressed("hit"):
		p.states.change_state(p.states.get_node("HitState"))
		return

	# STOP
	if input_x == 0:
		p.states.change_state(p.states.get_node("IdleState"))
		return

	# CROUCH
	if Input.is_action_pressed("crouch") and p.is_on_floor():
		print("Player VelX ", abs(p.velocity.x))
		p.states.change_state(p.states.get_node("CrouchTransitionDownState"))
		return

	# JUMP
	if Input.is_action_just_pressed("jump") and p.is_on_floor():
		p.states.change_state(p.states.get_node("JumpState"))
		return

	# FALL
	if not p.is_on_floor():
		p.states.change_state(p.states.get_node("JumpState"))
