extends Camera2D

var camera_owner: Player
var tween: Tween

@export var offset_from_owner: Vector2 = Vector2(10.0, 10.0)
@export var tween_duration: float = 0.3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera_owner = get_parent()

func _get_target_pos() -> Vector2:
	if not camera_owner:
		return offset_from_owner
	var dir: int =  1 if camera_owner.is_facing_right() else -1
	var extra_offset_x: float = camera_owner.get_velocity().x / 15
	return Vector2(offset_from_owner.x * dir + extra_offset_x, -offset_from_owner.y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var target_pos: Vector2 = _get_target_pos()

	# Only create new tween if target position changed significantly
	if offset.distance_to(target_pos) > 0.1:
		if tween and tween.is_running():
			tween.kill()

		tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_QUAD)
		tween.tween_property(self, "offset", target_pos, tween_duration)
