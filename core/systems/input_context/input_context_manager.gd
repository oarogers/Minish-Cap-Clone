class_name InputContextManager
extends Node

signal context_changed(previous_context: StringName, new_context: StringName)

const CONTEXT_GAMEPLAY: StringName = &"gameplay"
const CONTEXT_UI: StringName = &"ui"
const CONTEXT_CUTSCENE: StringName = &"cutscene"

@export var default_context: StringName = CONTEXT_GAMEPLAY

var _current_context: StringName = &""

func _ready() -> void:
	set_context(default_context)

func get_context() -> StringName:
	return _current_context

func set_context(new_context: StringName) -> void:
	if new_context == _current_context:
		return

	var previous_context: StringName = _current_context
	_current_context = new_context
	_apply_context_rules(_current_context)
	context_changed.emit(previous_context, _current_context)

func _apply_context_rules(context: StringName) -> void:
	# TODO: Expand this to enable/disable action maps per gameplay state.
	match context:
		CONTEXT_GAMEPLAY:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		CONTEXT_UI:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		CONTEXT_CUTSCENE:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		_:
			push_warning("InputContextManager received unknown context: %s" % [String(context)])
