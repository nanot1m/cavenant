extends Node

var current_state
var player

func init(_player):
	player = _player

	# initialize all states
	for child in get_children():
		if child is Node:
			child.player = player

	current_state = $IdleState
	current_state.enter(null)

func change_state(new_state):
	if current_state == new_state:
		return
	var prev = current_state
	current_state.exit(new_state)
	current_state = new_state
	current_state.enter(prev)

func physics_update(delta):
	if current_state:
		current_state.physics_update(delta)
