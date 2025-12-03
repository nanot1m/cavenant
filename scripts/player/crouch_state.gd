extends "res://scripts/player/state.gd"

var state_type = StateMachine.State.CROUCH

func enter(_previous):
	var p = player
	p.anim.play("crouch_idle")
	p.collision_shape.shape.size = p.CROUCH_SIZE
	p.collision_shape.position = p.CROUCH_POS

func physics_update(delta):
	var p = player
	
	p.velocity.x = move_toward(p.velocity.x, 0, p.FRICTION * delta)
	
	# gravity
	if not p.is_on_floor():
		p.states.change_state(StateMachine.State.JUMP)
		return

	# HIT
	if Input.is_action_just_pressed("hit"):
		p.states.change_state(StateMachine.State.HIT)
		return

	# UNCROUCH
	if not Input.is_action_pressed("crouch"):
		p.states.change_state(StateMachine.State.CROUCH_TRANSITION_UP)
