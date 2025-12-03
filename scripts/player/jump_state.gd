extends "res://scripts/player/state.gd"

var state_type = StateMachine.State.JUMP

# Grace period to prevent immediately re-grabbing wall after jump
const JUMP_GRACE_PERIOD = 0.1  # seconds
var jump_grace_timer = 0.0

func enter(_previous):
	var p = player

	if p.is_on_floor():
		p.velocity.y = -p.JUMP_FORCE

	# Reset grace timer when entering jump state
	jump_grace_timer = JUMP_GRACE_PERIOD

func physics_update(delta):
	var p = player

	p.velocity.y += p.GRAVITY * delta

	# Update jump grace timer
	jump_grace_timer -= delta

	# Horizontal drift
	var input_x = Input.get_axis("move_left", "move_right")
	p.velocity.x = move_toward(p.velocity.x, input_x * p.SPEED, p.ACCEL * delta)
	p.face_towards_dir(input_x)

	# HIT
	if Input.is_action_just_pressed("hit"):
		p.states.change_state(StateMachine.State.HIT)
		return

	# Animation selection
	if p.velocity.y < -40:
		p.anim.play("jump_up")
	elif abs(p.velocity.y) < 40:
		p.anim.play("jump_idle")
	else:
		p.anim.play("jump_down")

	# LAND
	if p.is_on_floor():
		if Input.is_action_pressed("crouch"):
			p.states.change_state(StateMachine.State.CROUCH_TRANSITION_DOWN)
		else:
			p.states.change_state(StateMachine.State.IDLE)

	# WALL SLIDE - only after grace period expires
	if jump_grace_timer <= 0:
		var is_facing_right = p.is_facing_right()
		if p.is_wall_detected() and not p.is_on_floor():
			if (is_facing_right and Input.is_action_pressed("move_right")) or (not is_facing_right and Input.is_action_pressed("move_left")):
				p.states.change_state(StateMachine.State.WALL_SLIDE)
				return
