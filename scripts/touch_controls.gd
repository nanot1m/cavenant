extends CanvasLayer

# Touch control buttons
@onready var left_button: TouchScreenButton = $LeftButton
@onready var right_button: TouchScreenButton = $RightButton
@onready var jump_button: TouchScreenButton = $JumpButton
@onready var crouch_button: TouchScreenButton = $CrouchButton
@onready var hit_button: TouchScreenButton = $HitButton

# Track which direction buttons are pressed
var is_left_pressed: bool = false
var is_right_pressed: bool = false
var is_crouch_pressed: bool = false

# Track if jump/hit were just pressed this frame
var jump_just_pressed: bool = false
var hit_just_pressed: bool = false

func _ready() -> void:
	# Show touch controls only on mobile platforms
	# Hide on desktop for development/testing purposes
	if OS.has_feature("mobile") or OS.has_feature("web"):
		visible = true
	else:
		# For desktop testing, you can uncomment the line below to show controls
		# visible = true
		visible = false
	
	# Connect button signals
	if left_button:
		left_button.pressed.connect(_on_left_pressed)
		left_button.released.connect(_on_left_released)
	
	if right_button:
		right_button.pressed.connect(_on_right_pressed)
		right_button.released.connect(_on_right_released)
	
	if jump_button:
		jump_button.pressed.connect(_on_jump_pressed)
		jump_button.released.connect(_on_jump_released)
	
	if crouch_button:
		crouch_button.pressed.connect(_on_crouch_pressed)
		crouch_button.released.connect(_on_crouch_released)
	
	if hit_button:
		hit_button.pressed.connect(_on_hit_pressed)
		hit_button.released.connect(_on_hit_released)

func _process(_delta: float) -> void:
	# Simulate input actions based on touch button states
	if is_left_pressed:
		Input.action_press("move_left")
	else:
		Input.action_release("move_left")
	
	if is_right_pressed:
		Input.action_press("move_right")
	else:
		Input.action_release("move_right")
	
	if is_crouch_pressed:
		Input.action_press("crouch")
	else:
		Input.action_release("crouch")
	
	# Handle jump and hit with just_pressed behavior
	if jump_just_pressed:
		Input.action_press("jump")
		jump_just_pressed = false
	else:
		Input.action_release("jump")
	
	if hit_just_pressed:
		Input.action_press("hit")
		hit_just_pressed = false
	else:
		Input.action_release("hit")

# Left button handlers
func _on_left_pressed() -> void:
	is_left_pressed = true

func _on_left_released() -> void:
	is_left_pressed = false

# Right button handlers
func _on_right_pressed() -> void:
	is_right_pressed = true

func _on_right_released() -> void:
	is_right_pressed = false

# Jump button handlers (set flag for just_pressed behavior)
func _on_jump_pressed() -> void:
	jump_just_pressed = true

func _on_jump_released() -> void:
	pass  # Jump release is handled in _process

# Crouch button handlers
func _on_crouch_pressed() -> void:
	is_crouch_pressed = true

func _on_crouch_released() -> void:
	is_crouch_pressed = false

# Hit button handlers (set flag for just_pressed behavior)
func _on_hit_pressed() -> void:
	hit_just_pressed = true

func _on_hit_released() -> void:
	pass  # Hit release is handled in _process
