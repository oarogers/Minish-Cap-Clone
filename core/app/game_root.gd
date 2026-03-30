class_name GameRoot
extends Node3D

@onready var scene_flow_manager: SceneFlowManager = $SceneFlowManager
@onready var input_context_manager: InputContextManager = $InputContextManager
@onready var player: PlayerController = $World/Player
@onready var overhead_camera_rig: OverheadCameraRig = $World/OverheadCameraRig

func _ready() -> void:
	scene_flow_manager.scene_changed.connect(_on_scene_changed)
	input_context_manager.context_changed.connect(_on_input_context_changed)

	if overhead_camera_rig.target_path.is_empty():
		overhead_camera_rig.target_path = overhead_camera_rig.get_path_to(player)

	# TODO: Replace with save/profile boot flow.
	scene_flow_manager.request_scene_change("overworld_start", "spawn_default")

func _on_scene_changed(scene_id: String, spawn_id: String) -> void:
	print("[GameRoot] Scene changed -> %s (spawn: %s)" % [scene_id, spawn_id])

func _on_input_context_changed(previous_context: StringName, new_context: StringName) -> void:
	print("[GameRoot] Input context changed: %s -> %s" % [String(previous_context), String(new_context)])
