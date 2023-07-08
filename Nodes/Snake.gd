extends Node2D


@export_range(0, TAU, TAU/128, "or_less", "or_greater") var move_rotation: float
@export var length: int = 250

@export var cos_frequency: float = 4.5
@export var acceleration: float = 400
@export var max_speed: float = 150

var rotation_velocity: float = 0
@export var rotation_acceleration: float = 2
@export var rotation_max_speed: float = 0.1
@export var rotation_variation: float = 0.05

@export var target_location: Vector2

@onready var _kill_area: Area2D = $%KillArea
@onready var _kill_area_childs: int = _kill_area.get_child_count()

var _time: float = 0


func _physics_process(delta: float):
	_time += delta
	
	_turn_toward_goal(delta)
	_move_head(delta)
	_update_body()
	_update_tail_position()
	_update_head_position()
	_add_collisions()

func _turn_toward_goal(delta):
	var change = target_location - $Head.global_position
	var target_angle = atan2(change.y, change.x)
	var direction = 1 if angle_difference(target_angle, move_rotation) < 0 else -1
	
	rotation_velocity += delta * rotation_acceleration * direction
	rotation_velocity = clamp(rotation_velocity, -rotation_max_speed, rotation_max_speed)
	move_rotation += rotation_velocity * delta

func _move_head(delta):
	# Update the Head's velocity
	$Head.velocity += Vector2(1, cos(_time * cos_frequency)
						).rotated(move_rotation) * delta * acceleration
	$Head.velocity = $Head.velocity.limit_length(max_speed)
	$Head.move_and_slide()

func _update_body():
	# Add a current position of the head to the points
	$Body.add_point($Head.position)
	
	# Remove the last point if too long
	if $Body.get_point_count() > length:
		$Body.remove_point(0)
		var to_remove: CollisionShape2D = _kill_area.get_child(_kill_area_childs)
		if is_instance_valid(to_remove):
			_kill_area.remove_child(to_remove)
			to_remove.queue_free()

func _update_tail_position():
	# Update the tail position
	$Tail.position = $Body.get_point_position(0)
	
	# Update the tail rotation
	if $Body.get_point_count() > 1: # Need 2 points to calculate gradient
		var change = $Body.get_point_position(1) - $Body.get_point_position(0)
		$Tail.rotation = atan2(change.y, change.x)

func _update_head_position():
	if $Body.get_point_count() <= 1:
		return # Need 2 points to calculate gradient
	
	var change: Vector2
	# Head rotation - lerp between move_rotation and gradient
	change = ($Body.get_point_position($Body.get_point_count() - 1)
			- $Body.get_point_position($Body.get_point_count() - 2))
	
	change = change.slerp(Vector2.RIGHT.rotated(move_rotation), 0.7)
	$Head.rotation = atan2(change.y, change.x)

func _add_collisions():
	if $Body.get_point_count() <= 1:
		return # Need 2 points to calculate gradient
	
	# Add the collision for the new point
	var new_shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	
	var point1: Vector2 = $Body.get_point_position($Body.get_point_count() - 1)
	var point2: Vector2 = $Body.get_point_position($Body.get_point_count() - 2)
	var change = point1 - point2
	
	new_shape.position = (point1 + point2) / 2
	new_shape.rotation = atan2(change.y, change.x)
	rect.extents = Vector2(change.length() / 2, $Body.width/2)
	
	new_shape.shape = rect
	
	_kill_area.add_child(new_shape)
	
	# Move the head collision so that it stays with the head
	$%HeadCollision.position += $Head.position - point2
	$%HeadCollision.rotation = $Head.rotation + PI/2


func _on_kill_area_entered(body: Node):
	if body.has_method("die"):
		body.die()


# https://www.gmlscripts.com/script/angle_difference
func angle_difference(angle1: float, angle2: float) -> float:
	return fmod((fmod(angle1 - angle2, TAU) + 2*TAU),  TAU) - PI
