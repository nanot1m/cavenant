extends "res://state.gd"

func enter(_previous):
	var p = player
	p.anim.play("slide")
	p.collision_shape.shape.size = p.SLIDE_SIZE
	p.collision_shape.position = p.SLIDE_POS

func physics_update(delta):
	var p = player
	
	p.velocity.x = move_toward(p.velocity.x, 0, p.FRICTION_SLIDE * delta)

# gravity
	if not p.is_on_floor():
		p.states.change_state(p.states.get_node("JumpState"))
		return

	# HIT
	if Input.is_action_just_pressed("hit"):
		p.states.change_state(p.states.get_node("HitState"))
		return
		
	if abs(p.velocity.x) <= p.SPEED_SLIDE_THRESHOLD:
		p.states.change_state(p.states.get_node("CrouchState"))
		return

	# UNCROUCH
	if not Input.is_action_pressed("crouch"):
		p.states.change_state(p.states.get_node("CrouchTransitionUpState"))
		return

	# JUMP attempt is ignored while crouching
