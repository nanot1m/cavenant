extends "res://scripts/player/state.gd"

var state_type = StateMachine.State.JUMP

func enter(_previous):
	var p = player

	if p.is_on_floor():
		p.velocity.y = -p.JUMP_FORCE

func physics_update(delta):
	var p = player

	p.velocity.y += p.GRAVITY * delta

	# Horizontal drift
	var input_x = Input.get_axis("move_left", "move_right")
	p.velocity.x = move_toward(p.velocity.x, input_x * p.SPEED, p.ACCEL * delta)

	# HIT
	if Input.is_action_just_pressed("hit"):
		p.states.change_state(StateMachine.State.HIT)
		return

	# Animation selection
	if p.velocity.y < -40:
		p.anim.play("jump_up")
	elif abs(p.velocity.y) < 40:
		p.anim.play("jump_idle")
	else:
		p.anim.play("jump_down")

	# LAND
	if p.is_on_floor():
		if Input.is_action_pressed("crouch"):
			p.states.change_state(StateMachine.State.CROUCH_TRANSITION_DOWN)
		else:
			p.states.change_state(StateMachine.State.IDLE)
