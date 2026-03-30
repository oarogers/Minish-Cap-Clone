class_name PlayerController
extends CharacterBody3D

signal moved(world_velocity: Vector3)
signal action_pressed(action_name: StringName)
signal state_changed(previous_state: StringName, new_state: StringName)
signal equipment_changed(sword_drawn: bool, shield_drawn: bool)

const DEFAULT_GRAVITY: float = 18.0
const STATE_MOVE: StringName = &"move"
const STATE_ROLL: StringName = &"roll"
const STATE_ATTACK: StringName = &"attack"
const STATE_SHIELD: StringName = &"shield"

@export var move_speed: float = 5.5
@export var acceleration: float = 16.0
@export var deceleration: float = 20.0
@export var jump_velocity: float = 6.5
@export var gravity: float = DEFAULT_GRAVITY
@export var roll_speed_multiplier: float = 2.4
@export var roll_duration_seconds: float = 0.35
@export var attack_duration_seconds: float = 0.28

var _current_state: StringName = STATE_MOVE
var _state_timer_seconds: float = 0.0
var _last_move_dir: Vector3 = Vector3.FORWARD
var _is_sword_drawn: bool = true
var _is_shield_drawn: bool = true

func _physics_process(delta: float) -> void:
	_update_state_timer(delta)
	_handle_input()

	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var desired_velocity: Vector3 = Vector3(input_vector.x, 0.0, input_vector.y)

	if desired_velocity.length() > 0.01:
		_last_move_dir = desired_velocity.normalized()

	_apply_state_movement(delta, desired_velocity)
	_apply_gravity_and_jump(delta)
	move_and_slide()
	moved.emit(Vector3(velocity.x, 0.0, velocity.z))

func get_state() -> StringName:
	return _current_state

func is_sword_drawn() -> bool:
	return _is_sword_drawn

func is_shield_drawn() -> bool:
	return _is_shield_drawn

func _handle_input() -> void:
	if Input.is_action_just_pressed("sheath_toggle"):
		_toggle_sheathe()
		action_pressed.emit(&"sheath_toggle")

	if _current_state == STATE_ROLL or _current_state == STATE_ATTACK:
		return

	if Input.is_action_just_pressed("roll"):
		_change_state(STATE_ROLL, roll_duration_seconds)
		action_pressed.emit(&"roll")
		return

	if Input.is_action_just_pressed("attack") and _is_sword_drawn:
		_change_state(STATE_ATTACK, attack_duration_seconds)
		action_pressed.emit(&"attack")
		return

	if Input.is_action_pressed("shield") and _is_shield_drawn:
		if _current_state != STATE_SHIELD:
			_change_state(STATE_SHIELD, 0.0)
			action_pressed.emit(&"shield_start")
	elif _current_state == STATE_SHIELD:
		_change_state(STATE_MOVE, 0.0)
		action_pressed.emit(&"shield_end")

func _apply_state_movement(delta: float, desired_velocity: Vector3) -> void:
	var target_speed: float = move_speed
	if _current_state == STATE_ROLL:
		target_speed *= roll_speed_multiplier
		desired_velocity = _last_move_dir
	elif _current_state == STATE_SHIELD:
		target_speed *= 0.45
	elif _current_state == STATE_ATTACK:
		target_speed *= 0.35

	var desired_horizontal: Vector3 = desired_velocity * target_speed
	var current_horizontal: Vector3 = Vector3(velocity.x, 0.0, velocity.z)
	var blend: float = acceleration if desired_horizontal.length() > 0.01 else deceleration
	current_horizontal = current_horizontal.lerp(desired_horizontal, min(blend * delta, 1.0))

	velocity.x = current_horizontal.x
	velocity.z = current_horizontal.z

func _apply_gravity_and_jump(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed("jump") and _current_state == STATE_MOVE:
		velocity.y = jump_velocity

func _toggle_sheathe() -> void:
	var will_draw: bool = not _is_sword_drawn and not _is_shield_drawn
	_is_sword_drawn = will_draw
	_is_shield_drawn = will_draw

	if not will_draw and _current_state == STATE_SHIELD:
		_change_state(STATE_MOVE, 0.0)

	equipment_changed.emit(_is_sword_drawn, _is_shield_drawn)

func _update_state_timer(delta: float) -> void:
	if _state_timer_seconds <= 0.0:
		return

	_state_timer_seconds -= delta
	if _state_timer_seconds <= 0.0 and (_current_state == STATE_ROLL or _current_state == STATE_ATTACK):
		_change_state(STATE_MOVE, 0.0)

func _change_state(next_state: StringName, duration_seconds: float) -> void:
	if _current_state == next_state:
		_state_timer_seconds = duration_seconds
		return

	var previous_state: StringName = _current_state
	_current_state = next_state
	_state_timer_seconds = duration_seconds
	state_changed.emit(previous_state, _current_state)
