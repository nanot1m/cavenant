extends "res://scripts/player/state.gd"

var state_type: StateMachine.State = StateMachine.State.SLIDE

func enter(_previous: StateMachine.State) -> void:
	var p: Player = player
	p.anim.play("slide")
	p.update_collision_bounds(p.SLIDE_SIZE, p.SLIDE_POS)

func physics_update(delta: float) -> void:
	var p: Player = player

	p.velocity.x = move_toward(p.velocity.x, 0, p.slide_friction * delta)

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
			p.velocity.x = max(p.velocity.x, p.speed / 4)
		else:
			p.velocity.x = min(p.velocity.x, -p.speed / 4)
		return
	
	# JUMP
	if Input.is_action_just_pressed("jump") and p.is_on_floor():
		p.states.change_state(StateMachine.State.JUMP)
		return

	if abs(p.velocity.x) <= p.speed_for_slide_start:
		p.states.change_state(StateMachine.State.CROUCH)
		return
		

	# UNCROUCH - only if there's enough space above
	if not Input.is_action_pressed("crouch"):
		p.states.change_state(StateMachine.State.CROUCH_TRANSITION_UP)
		return

	# JUMP attempt is ignored while crouching
