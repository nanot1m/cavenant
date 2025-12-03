extends "res://state.gd"

var state_type = StateMachine.State.HIT

func enter(_previous):
	var p = player
	p.anim.play("hit")
	p.collision_shape.shape.size = p.STAND_SIZE
	p.collision_shape.position = p.STAND_POS

	p.anim.animation_finished.connect(_on_anim_done, CONNECT_ONE_SHOT)

func physics_update(delta):
	var p = player

	# natural friction slowdown
	p.velocity.x = move_toward(p.velocity.x, 0, p.FRICTION * delta)

	# gravity
	if not p.is_on_floor():
		p.velocity.y += p.GRAVITY * delta

func _on_anim_done():
	player.states.change_state(StateMachine.State.IDLE)
