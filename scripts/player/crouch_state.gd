extends "res://scripts/player/state.gd"

var state_type: StateMachine.State = StateMachine.State.CROUCH

func enter(_previous: StateMachine.State) -> void:
	var p: Player = player
	p.anim.play("crouch_idle")
	p.update_collision_bounds(p.CROUCH_SIZE, p.CROUCH_POS)

func physics_update(delta: float) -> void:
	var p: Player = player

	p.velocity.x = move_toward(p.velocity.x, 0, p.friction * delta)
	
	# gravity
	if not p.is_on_floor():
		p.states.change_state(StateMachine.State.JUMP)
		return

	# HIT
	if Input.is_action_just_pressed("hit"):
		p.states.change_state(StateMachine.State.HIT)
		return

	# SLIDE - only if there's not enough space above to stand up
	if not p.can_stand_up():
		if p.velocity.x == 0:
			p.velocity.x = p.speed * (1 if p.is_facing_right() else -1)
		p.states.change_state(StateMachine.State.SLIDE)

	# UNCROUCH
	if not Input.is_action_pressed("crouch"):
		# Enough space, stand up normally
		p.states.change_state(StateMachine.State.CROUCH_TRANSITION_UP)
