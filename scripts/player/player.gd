class_name Player
extends CharacterBody2D

@export var speed: float = 250.0
@export var acceleration: float = 1200.0
@export var jump_force: float = 350.0
@export var wall_slide_speed: float = 80.0
@export var friction: float = 2000.0
@export var slide_friction: float = 500.0
@export var air_friction: float = 200.0  # Air resistance for Mario-like physics
@export var speed_for_slide_start: float = 40.0
@export var coyote_time: float = 0.15
@export var wall_jump_speed_x: float = 200

const GRAVITY: float = 900.0

# Coyote time tracking
var time_since_on_floor: float = 0.0

# Floor snapping - helps prevent getting stuck on tile edges
var snap_length: float = 8.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var states: StateMachine = $StateMachine

const PLAYER_HEIGHT: float = 30
const PLAYER_CROUCH_HEIGHT: float = 22
const PLAYER_WIDTH: float = 16

# HITBOXES
const STAND_SIZE: Vector2 = Vector2(PLAYER_WIDTH / 2, PLAYER_HEIGHT)
const RUN_SIZE: Vector2 = Vector2(PLAYER_WIDTH / 2, PLAYER_HEIGHT)
const CROUCH_SIZE: Vector2 = Vector2(PLAYER_WIDTH / 2, PLAYER_CROUCH_HEIGHT)
const SLIDE_SIZE: Vector2 = Vector2(PLAYER_WIDTH, PLAYER_CROUCH_HEIGHT)
const JUMP_SIZE: Vector2 = Vector2(PLAYER_WIDTH / 2, PLAYER_HEIGHT)
const WALL_SLIDE_SIZE: Vector2 = Vector2(PLAYER_WIDTH / 2, PLAYER_HEIGHT)

const STAND_POS: Vector2 = Vector2(0, 0)
const RUN_POS: Vector2 = Vector2(0, 0)
const CROUCH_POS: Vector2 = Vector2(0, (PLAYER_HEIGHT - PLAYER_CROUCH_HEIGHT) / 2)
const SLIDE_POS: Vector2 = Vector2(0, (PLAYER_HEIGHT - PLAYER_CROUCH_HEIGHT) / 2)
const JUMP_POS: Vector2 = Vector2(0, 0)
const WALL_SLIDE_POS: Vector2 = Vector2(0, 0)

func _ready():
	# Enable floor snapping to prevent getting stuck on tile edges
	floor_snap_length = snap_length
	floor_stop_on_slope = true
	floor_max_angle = deg_to_rad(46)  # Maximum angle considered as floor

	states.init(self)

func _physics_process(delta):
	# Update coyote time tracking
	if is_on_floor():
		time_since_on_floor = 0.0
	else:
		time_since_on_floor += delta

	# Disable floor snapping when moving horizontally or in air to prevent edge catching
	# Only snap when moving slowly on ground
	if is_on_floor() and abs(velocity.x) < speed * 0.5:
		floor_snap_length = snap_length
	else:
		floor_snap_length = 0.0

	states.physics_update(delta)
	move_and_slide()

func is_facing_right() -> bool:
	return anim.scale.x > 0

func face_towards_dir(direction_x: int):
	if direction_x != 0:
		anim.scale.x = -1 if direction_x < 0 else 1

func can_jump() -> bool:
	return is_on_floor() or time_since_on_floor <= coyote_time

# More reliable wall detection using raycasts
func is_wall_detected() -> bool:
	var space_state = get_world_2d().direct_space_state
	var direction = 1 if is_facing_right() else -1
	var ray_distance = 12.0 # pixels to check

	# Cast multiple rays at different heights to reliably detect walls
	# Avoid the bottom rays that might catch platform edges
	var ray_offsets = [-PLAYER_HEIGHT / 3, 0.0, PLAYER_HEIGHT / 3] # vertical offsets

	for offset in ray_offsets:
		var query = PhysicsRayQueryParameters2D.create(
			global_position + Vector2(0, offset),
			global_position + Vector2(direction * ray_distance, offset)
		)
		query.exclude = [self]
		query.collision_mask = 1 # Adjust if your walls use a different collision layer

		var result = space_state.intersect_ray(query)
		if result:
			# Check if the collision normal is mostly horizontal (actual wall)
			# Ignore collisions with mostly vertical normals (platform edges)
			var normal = result.normal
			if abs(normal.x) > 0.7:  # Wall must be fairly vertical
				return true

	return false

func update_collision_bounds(bounds: Vector2, pos: Vector2):
	collision_shape.shape.radius = bounds[0]
	collision_shape.shape.height = bounds[1]
	collision_shape.position = pos

# Check if there's enough space above to stand up
func can_stand_up() -> bool:
	var space_state = get_world_2d().direct_space_state

	# Calculate the height difference between crouch and stand
	var height_diff = STAND_SIZE.y - CROUCH_SIZE.y
	var check_distance = height_diff / 2 # Add small buffer

	# Cast rays upward to detect ceiling
	var ray_offsets = [-PLAYER_WIDTH / 2, 0.0, PLAYER_WIDTH / 2] # horizontal offsets to check multiple points

	for offset in ray_offsets:
		var query = PhysicsRayQueryParameters2D.create(
			global_position + Vector2(offset, -CROUCH_SIZE.y / 2),
			global_position + Vector2(offset, -CROUCH_SIZE.y / 2 - check_distance)
		)
		query.exclude = [self]
		query.collision_mask = 1 # Adjust if your platforms use a different collision layer

		var result = space_state.intersect_ray(query)
		if result:
			return false # Ceiling detected, can't stand up

	return true # No ceiling detected, safe to stand up
