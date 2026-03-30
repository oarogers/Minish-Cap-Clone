class_name SceneFlowManager
extends Node

signal scene_change_requested(scene_id: String, spawn_id: String)
signal scene_changed(scene_id: String, spawn_id: String)

var _current_scene_id: String = ""
var _current_spawn_id: String = ""

func request_scene_change(scene_id: String, spawn_id: String = "") -> void:
	if scene_id.is_empty():
		push_warning("SceneFlowManager.request_scene_change called with empty scene_id")
		return

	scene_change_requested.emit(scene_id, spawn_id)
	_apply_scene_change(scene_id, spawn_id)

func get_current_scene_id() -> String:
	return _current_scene_id

func get_current_spawn_id() -> String:
	return _current_spawn_id

func _apply_scene_change(scene_id: String, spawn_id: String) -> void:
	# TODO: Replace this placeholder with asynchronous room/scene loading,
	# transition effects, and save checkpoint integration.
	_current_scene_id = scene_id
	_current_spawn_id = spawn_id
	scene_changed.emit(_current_scene_id, _current_spawn_id)
