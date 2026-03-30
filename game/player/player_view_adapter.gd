class_name PlayerViewAdapter
extends Node3D

@export var controller_path: NodePath
@export var visual_root_path: NodePath = NodePath("Visual")
@export var turn_speed: float = 12.0

var _controller: PlayerController
var _visual_root: Node3D
var _sword_drawn_mount: Node3D
var _sword_sheathed_mount: Node3D
var _shield_drawn_mount: Node3D
var _shield_sheathed_mount: Node3D

func _ready() -> void:
	_controller = get_node_or_null(controller_path) as PlayerController
	_visual_root = get_node_or_null(visual_root_path) as Node3D

	if _controller == null or _visual_root == null:
		push_warning("PlayerViewAdapter missing controller or visual root")
		return

	_sword_drawn_mount = _visual_root.get_node_or_null("SwordDrawn") as Node3D
	_sword_sheathed_mount = _visual_root.get_node_or_null("SwordSheathed") as Node3D
	_shield_drawn_mount = _visual_root.get_node_or_null("ShieldDrawn") as Node3D
	_shield_sheathed_mount = _visual_root.get_node_or_null("ShieldSheathed") as Node3D

	_controller.moved.connect(_on_controller_moved)
	_controller.action_pressed.connect(_on_action_pressed)
	_controller.state_changed.connect(_on_state_changed)
	_controller.equipment_changed.connect(_on_equipment_changed)

	_on_equipment_changed(_controller.is_sword_drawn(), _controller.is_shield_drawn())

func _physics_process(delta: float) -> void:
	if _controller == null or _visual_root == null:
		return

	match _controller.get_state():
		PlayerController.STATE_ROLL:
			_visual_root.rotation_degrees.x = lerp(_visual_root.rotation_degrees.x, -30.0, min(delta * 16.0, 1.0))
		PlayerController.STATE_ATTACK:
			_visual_root.rotation_degrees.x = lerp(_visual_root.rotation_degrees.x, -12.0, min(delta * 16.0, 1.0))
		PlayerController.STATE_SHIELD:
			_visual_root.rotation_degrees.x = lerp(_visual_root.rotation_degrees.x, -4.0, min(delta * 8.0, 1.0))
		_:
			_visual_root.rotation_degrees.x = lerp(_visual_root.rotation_degrees.x, 0.0, min(delta * 10.0, 1.0))

func _on_controller_moved(world_velocity: Vector3) -> void:
	if _visual_root == null:
		return
	if world_velocity.length() < 0.01:
		return

	var desired_yaw: float = atan2(world_velocity.x, world_velocity.z)
	_visual_root.rotation.y = lerp_angle(_visual_root.rotation.y, desired_yaw, min(get_physics_process_delta_time() * turn_speed, 1.0))

func _on_action_pressed(action_name: StringName) -> void:
	if _visual_root == null:
		return
	if action_name == &"attack":
		_visual_root.scale = Vector3(1.08, 0.92, 1.08)
		_visual_root.scale = Vector3.ONE

func _on_state_changed(_previous_state: StringName, _new_state: StringName) -> void:
	# Reserved for animation player state transitions.
	pass

func _on_equipment_changed(sword_drawn: bool, shield_drawn: bool) -> void:
	if _sword_drawn_mount != null:
		_sword_drawn_mount.visible = sword_drawn
	if _sword_sheathed_mount != null:
		_sword_sheathed_mount.visible = not sword_drawn

	if _shield_drawn_mount != null:
		_shield_drawn_mount.visible = shield_drawn
	if _shield_sheathed_mount != null:
		_shield_sheathed_mount.visible = not shield_drawn
