extends "res://scripts/player/state.gd"

var state_type: StateMachine.State = StateMachine.State.HIT

func enter(_previous: StateMachine.State) -> void:
	var p: Player = player
	p.anim.play("hit")
	p.update_collision_bounds(p.STAND_SIZE, p.STAND_POS)
	p.anim.animation_finished.connect(_on_anim_done, CONNECT_ONE_SHOT)

func physics_update(delta: float) -> void:
	var p: Player = player

	# natural friction slowdown
	p.velocity.x = move_toward(p.velocity.x, 0, p.friction * delta)

	# gravity
	if not p.is_on_floor():
		p.velocity.y += p.GRAVITY * delta

func _on_anim_done() -> void:
	player.states.change_state(StateMachine.State.IDLE)
