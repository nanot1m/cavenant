extends "res://scripts/player/state.gd"

var state_type: StateMachine.State = StateMachine.State.JUMP

# Grace period to prevent immediately re-grabbing wall after jump
const JUMP_GRACE_PERIOD: float = 0.1  # seconds
var jump_grace_timer: float = 0.0

func enter(_previous: StateMachine.State) -> void:
	var p: Player = player

	p.update_collision_bounds(p.STAND_SIZE, p.STAND_POS)

	# Only apply jump force if actually on floor
	# Coyote time jumps are handled in physics_update
	if p.is_on_floor():
		p.velocity.y = -p.jump_force

	# Reset grace timer when entering jump state
	jump_grace_timer = JUMP_GRACE_PERIOD

func physics_update(delta: float) -> void:
	var p: Player = player

	p.velocity.y += p.GRAVITY * delta

	# Update jump grace timer
	jump_grace_timer -= delta

	# Coyote time jump - allow jumping if within coyote time window
	if Input.is_action_just_pressed("jump") and not p.is_on_floor() and p.time_since_on_floor <= p.coyote_time:
		p.velocity.y = -p.jump_force
		# Reset coyote timer after jumping to prevent multiple jumps from same coyote window
		p.time_since_on_floor = p.coyote_time + 1.0

	# Horizontal air control with realistic air friction
	var input_x: float = Input.get_axis("move_left", "move_right")

	# Always apply air friction (air resistance acts against movement)
	p.velocity.x = move_toward(p.velocity.x, 0, p.air_friction * delta)

	# Then apply player input acceleration on top
	if input_x != 0:
		p.velocity.x = move_toward(p.velocity.x, input_x * p.speed, p.acceleration * delta)
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
		var is_facing_right: bool = p.is_facing_right()
		if p.is_wall_detected() and not p.is_on_floor():
			if (is_facing_right and Input.is_action_pressed("move_right")) or (not is_facing_right and Input.is_action_pressed("move_left")):
				p.states.change_state(StateMachine.State.WALL_SLIDE)
				return
