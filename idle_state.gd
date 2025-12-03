extends "res://state.gd"

var state_type = StateMachine.State.IDLE

func enter(_previous):
	var p = player
	p.anim.play("idle")
	p.collision_shape.shape.size = p.STAND_SIZE
	p.collision_shape.position = p.STAND_POS

func physics_update(delta):
	var p = player
	
	p.velocity.x = move_toward(p.velocity.x, 0, p.FRICTION * delta)

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
		p.states.change_state(StateMachine.State.RUN)
		return

	# JUMP
	if Input.is_action_just_pressed("jump") and p.is_on_floor():
		p.states.change_state(StateMachine.State.JUMP)
		return

	# gravity
	if not p.is_on_floor():
		p.states.change_state(StateMachine.State.JUMP)
