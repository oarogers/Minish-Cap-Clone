class_name OverheadCameraRig
extends Node3D

@export var target_path: NodePath
@export var follow_lerp_speed: float = 8.0
@export var camera_height: float = 15.0
@export var camera_distance: float = 1.0
@export var min_bounds: Vector2 = Vector2(-24.0, -24.0)
@export var max_bounds: Vector2 = Vector2(24.0, 24.0)

var _target: Node3D

func _ready() -> void:
	_target = get_node_or_null(target_path) as Node3D
	if _target == null:
		push_warning("OverheadCameraRig has no target. Set target_path to the player.")

func _physics_process(delta: float) -> void:
	if _target == null:
		return

	var target_origin: Vector3 = _target.global_position
	target_origin.x = clamp(target_origin.x, min_bounds.x, max_bounds.x)
	target_origin.z = clamp(target_origin.z, min_bounds.y, max_bounds.y)

	var desired_position: Vector3 = Vector3(
		target_origin.x,
		target_origin.y + camera_height,
		target_origin.z + camera_distance
	)

	global_position = global_position.lerp(desired_position, min(delta * follow_lerp_speed, 1.0))
