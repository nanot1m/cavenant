class_name Player
extends CharacterBody2D

const SPEED = 200.0
const ACCEL = 1200.0
const FRICTION = 2000.0
const FRICTION_SLIDE = 500.0
const GRAVITY = 900.0
const JUMP_FORCE = 350.0
const SPEED_SLIDE_THRESHOLD = 40.0
const SPEED_WALL_SLIDE = 80.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var states: StateMachine = $StateMachine

# HITBOXES
const STAND_SIZE  = Vector2(20, 32)
const RUN_SIZE    = Vector2(20, 32)
const CROUCH_SIZE = Vector2(20, 22)
const SLIDE_SIZE  = Vector2(32, 22)
const JUMP_SIZE   = Vector2(20, 32)
const WALL_SLIDE_SIZE = Vector2(20, 32)

const STAND_POS   = Vector2(0, 0)
const RUN_POS     = Vector2(0, 0)
const CROUCH_POS  = Vector2(0, 5)
const SLIDE_POS   = Vector2(0, 5)
const JUMP_POS    = Vector2(0, 0)
const WALL_SLIDE_POS = Vector2(0, 0)

func _ready():
	states.init(self)

func _physics_process(delta):
	states.physics_update(delta)
	move_and_slide()  # always called here

func is_facing_right() -> bool:
	return anim.scale.x > 0

func face_towards_dir(direction_x: int):
	if direction_x != 0:
		anim.scale.x = -1 if direction_x < 0 else 1

# More reliable wall detection using raycasts
func is_wall_detected() -> bool:
	var space_state = get_world_2d().direct_space_state
	var direction = 1 if is_facing_right() else -1
	var ray_distance = 12.0  # pixels to check

	# Cast multiple rays at different heights to reliably detect walls
	var ray_offsets = [-16.0, -12.0, -6.0, 0.0, 6.0, 12.0, 16.0]  # vertical offsets

	for offset in ray_offsets:
		var query = PhysicsRayQueryParameters2D.create(
			global_position + Vector2(0, offset),
			global_position + Vector2(direction * ray_distance, offset)
		)
		query.exclude = [self]
		query.collision_mask = 1  # Adjust if your walls use a different collision layer

		var result = space_state.intersect_ray(query)
		if result:
			return true

	return false

# Check if there's enough space above to stand up
func can_stand_up() -> bool:
	var space_state = get_world_2d().direct_space_state

	# Calculate the height difference between crouch and stand
	var height_diff = STAND_SIZE.y - CROUCH_SIZE.y
	var check_distance = height_diff + 2.0  # Add small buffer

	# Cast rays upward to detect ceiling
	var ray_offsets = [-8.0, 0.0, 8.0]  # horizontal offsets to check multiple points

	for offset in ray_offsets:
		var query = PhysicsRayQueryParameters2D.create(
			global_position + Vector2(offset, -CROUCH_SIZE.y / 2),
			global_position + Vector2(offset, -CROUCH_SIZE.y / 2 - check_distance)
		)
		query.exclude = [self]
		query.collision_mask = 1  # Adjust if your platforms use a different collision layer

		var result = space_state.intersect_ray(query)
		if result:
			return false  # Ceiling detected, can't stand up

	return true  # No ceiling detected, safe to stand up
