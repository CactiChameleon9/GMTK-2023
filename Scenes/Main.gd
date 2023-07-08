extends Node2D

var _time: float = 0

var _normal_snake_eq = func(x: float): return (1/1000*x**3 - 1/3.9*x**2 + 15*x)/20 + 1
var _fast_snake_eq = func(x: float): return (1/1000*x**3 - 1/3.9*x**2 + 15*x)/20 - 100
var _bendy_snake_eq = func(x: float): return (1/1000*x**3 - 1/3.9*x**2 + 15*x)/20 - 100

var _snake_numbers: Array[Array] = \
		[[_normal_snake_eq, 0, load("res://Nodes/Snake.tscn")],
		[_fast_snake_eq, 0, load("res://Nodes/SnakeTypes/FasterSnake.tscn")],
		[_bendy_snake_eq, 0, load("res://Nodes/SnakeTypes/FasterSnake.tscn")]]

@onready var _snake_spawner: Path2D = $%SnakeSpawner
@onready var _snake_spawner_childs: int = _snake_spawner.get_child_count()


func _process(delta: float):
	_time += delta
	
	# Set the time label
	$%TimeLabel.text = str(int(_time))


func _physics_process(delta):
	
	# Spawn any missing snakes
	for snake_type in _snake_numbers:
		while snake_type[0].call(_time) > snake_type[1]:
			# Randomise spawn position
			var spawn_pos: PathFollow2D = _snake_spawner.get_node("SpawnPosition")
			spawn_pos.progress_ratio = randf()
			
			# Spawn a snake
			var snake = snake_type[2].instantiate()
			_snake_spawner.add_child(snake) 
			
			# Set the snake's position
			snake.position = spawn_pos.position
			
			# Set the snake's rotation 
			var change: Vector2 = $Character.position - spawn_pos.position
			snake.move_rotation = atan2(change.y, change.x)
			
			# Increase the snake count
			snake_type[1] += 1
	
	# Update the target locations to be the player's position
	for child in _snake_spawner.get_children():
		if child.is_in_group("snake"):
			child.target_location = child.global_position


func _on_snake_detector_body_exited(body): #TODO reduce snake type
	print("hello ", body)
	if body.is_in_group("snake"):
		body.queue_free()
