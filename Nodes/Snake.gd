extends Node2D


@export_range(0, TAU, TAU/128, "or_less", "or_greater") var move_rotation: float
@export var length: int = 300

@export var cos_frequency: float = 3
@export var acceleration: float = 400
@export var max_speed: float = 100

@onready var _head_child_count: int = $Head.get_child_count()

var _time: float = 0


func _physics_process(delta):
	_time += delta
	
	# Update the Head's velocity
	$Head.velocity += Vector2(1, cos(_time * cos_frequency)
						).rotated(move_rotation) * delta * acceleration
	$Head.velocity = $Head.velocity.limit_length(max_speed)
	$Head.move_and_slide()
	
	# Add a current position of the head to the points
	$Body.add_point($Head.position)
	
	# Remove the last point if too long
	if $Body.get_point_count() > length:
		$Body.remove_point(0)
		var to_remove: CollisionShape2D = $Head.get_child(_head_child_count)
		if is_instance_valid(to_remove):
			$Head.remove_child(to_remove)
			to_remove.queue_free()
	
	# Update the tail position
	$Tail.position = $Body.get_point_position(0)
	
	# Update the Head and Tail's rotation + collisions
	if $Body.get_point_count() <= 1: # Need 2 points to calculate gradient
		return
	
	var change: Vector2
	# Head rotation - lerp between move_rotation and gradient
	change = ($Body.get_point_position($Body.get_point_count() - 1)
			- $Body.get_point_position($Body.get_point_count() - 2))
	
	change = change.slerp(Vector2.RIGHT.rotated(move_rotation), 0.7)
	$Head.rotation = atan2(change.y, change.x)

	# Tail rotation
	change = $Body.get_point_position(1) - $Body.get_point_position(0)
	$Tail.rotation = atan2(change.y, change.x)
	
	# Add the collision for the new point
	var rect = RectangleShape2D.new()
	var new_shape = CollisionShape2D.new()
	new_shape.top_level = true
	
	var point1: Vector2 = $Body.get_point_position($Body.get_point_count() - 1)
	var point2: Vector2 = $Body.get_point_position($Body.get_point_count() - 2)
	change = point1 - point2
	
	new_shape.position = (point1 + point2) / 2 + global_position
	new_shape.rotation = atan2(change.y, change.x)
	rect.extents = Vector2(change.length() / 2, $Body.width/2)
	
	new_shape.shape = rect
	
	$Head.add_child(new_shape)
