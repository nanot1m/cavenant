extends "res://state.gd"

func enter(_previous):
	var p = player
	p.anim.play("crouch_idle")
	p.collision_shape.shape.size = p.CROUCH_SIZE
	p.collision_shape.position = p.CROUCH_POS

func physics_update(delta):
	var p = player
	
	p.velocity.x = move_toward(p.velocity.x, 0, p.FRICTION * delta)

	# HIT
	if Input.is_action_just_pressed("hit"):
		p.states.change_state(p.states.get_node("HitState"))
		return

	# UNCROUCH
	if not Input.is_action_pressed("crouch"):
		p.states.change_state(p.states.get_node("CrouchTransitionUpState"))
		return

	# JUMP attempt is ignored while crouching
