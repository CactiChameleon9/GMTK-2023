extends CharacterBody2D


@export var length: int = 400

var _points: Array[Vector2] = []

var time: float = 0


func _physics_process(delta): #TODO CLEAN UP
	time += delta
	var last_pos: Vector2 = position
	
	velocity += Vector2(1, cos(time*3)).rotated(rotation) * delta * 400
	velocity = velocity.limit_length(100)
	move_and_slide()
	
	if $Body.get_point_count() > length:
		$Body.remove_point(0)
	
	$Body.add_point(Vector2.ZERO)
	
	for i in $Body.get_point_count():
		$Body.set_point_position(i, $Body.get_point_position(i) - position + last_pos)
	$Body.rotation = -rotation
	
	$Tail.position = $Body.get_point_position(0)
