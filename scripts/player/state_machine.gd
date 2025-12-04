class_name StateMachine
extends Node

enum State {
	IDLE,
	RUN,
	JUMP,
	CROUCH,
	CROUCH_TRANSITION_DOWN,
	CROUCH_TRANSITION_UP,
	SLIDE,
	HIT,
	WALL_SLIDE
}

var current_state: StateNode
var player: Player
var states: Dictionary = {}

func init(_player: Player) -> void:
	player = _player

	# initialize all states and automatically register them
	for child in get_children():
		if child is Node:
			child.player = player
			if "state_type" in child:
				states[child.state_type] = child

	current_state = states[State.IDLE]
	current_state.enter(-1)

func change_state(new_state_enum: State) -> void:
	var new_state: StateNode = states[new_state_enum]
	if current_state == new_state:
		return
	var prev := current_state
	current_state.exit(new_state.state_type)
	current_state = new_state
	current_state.enter(prev.state_type)

func physics_update(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)
