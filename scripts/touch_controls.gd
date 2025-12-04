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

# Track previous frame states to avoid unnecessary releases
var jump_was_pressed: bool = false
var hit_was_pressed: bool = false

# Track which actions we've activated (to avoid interfering with keyboard)
var touch_active_move_left: bool = false
var touch_active_move_right: bool = false
var touch_active_crouch: bool = false
var touch_active_jump: bool = false
var touch_active_hit: bool = false

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

	# Position and scale buttons based on screen size
	_setup_button_positions()

	# Reposition buttons when viewport size changes (e.g., screen rotation)
	get_viewport().size_changed.connect(_on_viewport_size_changed)

func _on_viewport_size_changed() -> void:
	_setup_button_positions()

func _setup_button_positions() -> void:
	# Get the viewport size
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size

	# Calculate scale factor based on screen height (reference: 648px height)
	# Clamp to a maximum scale to prevent oversized buttons on tall screens
	var scale_factor: float = clamp(viewport_size.y / 648.0, 0.5, 1.5)

	# Define margins from screen edges
	var margin_x: float = 80.0 * scale_factor
	var margin_y: float = 80.0 * scale_factor
	var button_spacing: float = 120.0 * scale_factor

	# Position left/right movement buttons (bottom-left)
	if left_button:
		left_button.position = Vector2(margin_x, viewport_size.y - margin_y)
		left_button.scale = Vector2(scale_factor, scale_factor)

	if right_button:
		right_button.position = Vector2(margin_x + button_spacing, viewport_size.y - margin_y)
		right_button.scale = Vector2(scale_factor, scale_factor)

	# Position action buttons (bottom-right)
	if jump_button:
		jump_button.position = Vector2(viewport_size.x - margin_x, viewport_size.y - margin_y)
		jump_button.scale = Vector2(scale_factor, scale_factor)

	if crouch_button:
		crouch_button.position = Vector2(viewport_size.x - margin_x - button_spacing, viewport_size.y - margin_y)
		crouch_button.scale = Vector2(scale_factor, scale_factor)

	if hit_button:
		hit_button.position = Vector2(viewport_size.x - margin_x, viewport_size.y - margin_y - button_spacing)
		hit_button.scale = Vector2(scale_factor, scale_factor)

func _process(_delta: float) -> void:
	# Handle move_left: only press/release if we're controlling it
	if is_left_pressed and not touch_active_move_left:
		Input.action_press("move_left")
		touch_active_move_left = true
	elif not is_left_pressed and touch_active_move_left:
		Input.action_release("move_left")
		touch_active_move_left = false

	# Handle move_right: only press/release if we're controlling it
	if is_right_pressed and not touch_active_move_right:
		Input.action_press("move_right")
		touch_active_move_right = true
	elif not is_right_pressed and touch_active_move_right:
		Input.action_release("move_right")
		touch_active_move_right = false

	# Handle crouch: only press/release if we're controlling it
	if is_crouch_pressed and not touch_active_crouch:
		Input.action_press("crouch")
		touch_active_crouch = true
	elif not is_crouch_pressed and touch_active_crouch:
		Input.action_release("crouch")
		touch_active_crouch = false

	# Handle jump with just_pressed behavior
	if jump_just_pressed:
		Input.action_press("jump")
		jump_just_pressed = false
		jump_was_pressed = true
		touch_active_jump = true
	elif jump_was_pressed and touch_active_jump:
		Input.action_release("jump")
		jump_was_pressed = false
		touch_active_jump = false

	# Handle hit with just_pressed behavior
	if hit_just_pressed:
		Input.action_press("hit")
		hit_just_pressed = false
		hit_was_pressed = true
		touch_active_hit = true
	elif hit_was_pressed and touch_active_hit:
		Input.action_release("hit")
		hit_was_pressed = false
		touch_active_hit = false

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
