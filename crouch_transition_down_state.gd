extends "res://state.gd"

func enter(_previous):
	var p = player
	p.anim.play("crouch_down")
	p.collision_shape.shape.size = p.CROUCH_SIZE
	p.collision_shape.position = p.CROUCH_POS

	p.anim.animation_finished.connect(_on_anim_done, CONNECT_ONE_SHOT)

func _on_anim_done():
	if abs(player.velocity.x) < player.SPEED_SLIDE_THRESHOLD:
		player.states.change_state(player.states.get_node("CrouchState"))
	else:
		player.states.change_state(player.states.get_node("SlideState"))
