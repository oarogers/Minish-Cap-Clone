class_name GameRoot
extends Node3D

@onready var scene_flow_manager: SceneFlowManager = $SceneFlowManager
@onready var player: PlayerController = $World/Player
@onready var overhead_camera_rig: OverheadCameraRig = $World/OverheadCameraRig

func _ready() -> void:
	scene_flow_manager.scene_changed.connect(_on_scene_changed)

	if overhead_camera_rig.target_path.is_empty():
		overhead_camera_rig.target_path = overhead_camera_rig.get_path_to(player)

	if OS.is_debug_build():
		# Keep the cursor available so Steam Deck users can reach the window controls.
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# TODO: Replace with save/profile boot flow.
	scene_flow_manager.request_scene_change("overworld_start", "spawn_default")

func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return

	# Toggle mouse capture in debug only; this does NOT close the application.
	if event is InputEventKey and event.pressed and event.keycode == KEY_F1:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED

func _on_scene_changed(scene_id: String, spawn_id: String) -> void:
	print("[GameRoot] Scene changed -> %s (spawn: %s)" % [scene_id, spawn_id])
