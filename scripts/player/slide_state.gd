extends "res://scripts/player/state.gd"

var state_type = StateMachine.State.SLIDE

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
		p.states.change_state(StateMachine.State.JUMP)
		return

	# HIT
	if Input.is_action_just_pressed("hit"):
		p.states.change_state(StateMachine.State.HIT)
		return
		
	if not p.can_stand_up():
		if p.velocity.x > 0:
			p.velocity.x = max(p.velocity.x, p.SPEED / 4)
		else:
			p.velocity.x = min(p.velocity.x, -p.SPEED / 4)
		return

	if abs(p.velocity.x) <= p.SPEED_SLIDE_THRESHOLD:
		p.states.change_state(StateMachine.State.CROUCH)
		return

	# UNCROUCH - only if there's enough space above
	if not Input.is_action_pressed("crouch"):
		p.states.change_state(StateMachine.State.CROUCH_TRANSITION_UP)
		return

	# JUMP attempt is ignored while crouching
