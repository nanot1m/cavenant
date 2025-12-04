extends "res://scripts/player/state.gd"

var state_type = StateMachine.State.CROUCH_TRANSITION_DOWN

func enter(_previous):
	var p = player
	p.anim.play("crouch_down")
	p.update_collision_bounds(p.CROUCH_SIZE, p.CROUCH_POS)
	p.anim.animation_finished.connect(_on_anim_done, CONNECT_ONE_SHOT)

func _on_anim_done():
	if abs(player.velocity.x) < player.speed_for_slide_start:
		player.states.change_state(StateMachine.State.CROUCH)
	else:
		player.states.change_state(StateMachine.State.SLIDE)
