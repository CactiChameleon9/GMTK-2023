extends CharacterBody2D

signal live_changed(lives: int)

@export var lives: int = 5

@onready var _character_sprite = $Apple
var _character_bounce_length: float = 45

@onready var _shadow_sprite = $Shadow
var _shadow_size_change: float = 0.2

var _walking: bool = false
var _bouncing: bool = false
var _tweener: Tween

var _acceleration: float = 4500
var _max_speed: float = 400
var _resistance: float = 3000


func _ready():
	live_changed.emit(lives)


func _physics_process(delta):
	# Get the move direction
	_do_movement(delta)
	_do_bouncing()


func _do_movement(delta):
	var move_direction := Vector2(Input.get_action_strength("ui_right")
								- Input.get_action_strength("ui_left"),
								Input.get_action_strength("ui_down")
								- Input.get_action_strength("ui_up"))
	move_direction = move_direction.limit_length()
	
	# Move in direction (or resist if no movement input given)
	if move_direction.is_zero_approx():
		_walking = false
		velocity -= velocity.normalized() * delta * _resistance
		if velocity.length() < _resistance * delta:
			velocity = Vector2.ZERO
	else:
		_walking = true
		velocity += move_direction * delta * _acceleration
	
	# Limit the velocity to max
	velocity = velocity.limit_length(_max_speed)
	
	# Actually move
	move_and_slide()


func _do_bouncing():
	# Create the tween if not existing
	if is_instance_valid(_tweener):
		_bouncing = _tweener.is_running()
	
	# Exit if already tweening/stationary
	if _bouncing or not _walking:
		return
	
	# Bounce Up
	_tweener = create_tween().set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	_tweener.set_ease(Tween.EASE_OUT)
	
	_tweener.tween_property(_character_sprite, "position:y",
							-_character_bounce_length, 0.25).as_relative()
	_tweener.tween_property(_character_sprite, "scale:y",
							-_shadow_size_change/6, 0.25).as_relative()
	_tweener.tween_property(_shadow_sprite, "scale", Vector2.ONE *
							-_shadow_size_change, 0.25).as_relative()
	
	# Bounce Down
	await _tweener.finished
	_tweener = create_tween().set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	_tweener.set_ease(Tween.EASE_IN)
	
	_tweener.tween_property(_character_sprite, "position:y",
							_character_bounce_length, 0.25).as_relative()
	_tweener.tween_property(_character_sprite, "scale:y",
							_shadow_size_change/6, 0.25).as_relative()
	_tweener.tween_property(_shadow_sprite, "scale", Vector2.ONE *
							_shadow_size_change, 0.25).as_relative()


func die():
	lives -= 1
	live_changed.emit(lives)
