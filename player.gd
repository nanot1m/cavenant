extends CharacterBody2D

const SPEED = 200.0
const ACCEL = 1200.0
const FRICTION = 2000.0
const GRAVITY = 900.0
const JUMP_FORCE = 350.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var states = $StateMachine

# HITBOXES
const STAND_SIZE  = Vector2(22, 35)
const RUN_SIZE    = Vector2(35, 35)
const CROUCH_SIZE = Vector2(22, 23)
const JUMP_SIZE   = Vector2(22, 35)

const STAND_POS   = Vector2(0, 0)
const RUN_POS     = Vector2(0, 0)
const CROUCH_POS  = Vector2(0, 6)
const JUMP_POS    = Vector2(0, 0)

func _ready():
	states.init(self)

func _physics_process(delta):
	states.physics_update(delta)
	move_and_slide()  # always called here
