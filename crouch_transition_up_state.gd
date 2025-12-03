extends "res://state.gd"

func enter(_previous):
	var p = player
	p.anim.play("crouch_up")
	p.anim.animation_finished.connect(_on_anim_done, CONNECT_ONE_SHOT)

func _on_anim_done():
	player.states.change_state(player.states.get_node("IdleState"))
