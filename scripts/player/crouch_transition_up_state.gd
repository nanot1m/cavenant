extends "res://scripts/player/state.gd"

var state_type = StateMachine.State.CROUCH_TRANSITION_UP

func enter(_previous):
	var p = player
	p.anim.play("crouch_up")
	p.anim.animation_finished.connect(_on_anim_done, CONNECT_ONE_SHOT)

func _on_anim_done():
	# Double-check there's space before fully standing up
	if player.can_stand_up():
		player.states.change_state(StateMachine.State.IDLE)
	else:
		# Not enough space, go back to crouch
		player.states.change_state(StateMachine.State.CROUCH)
