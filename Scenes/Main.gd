extends Node2D

var _time: float = 0

var _normal_snake_eq = func(x: float): return (x**3 / 1000 - x**2 / 3.9 + x * 15)/30 + 1
var _fast_snake_eq = func(x: float): x-=50; x/=1.5; return (x**3 / 1000 - x**2 / 3.9 + x * 15)/50 + 1
var _bendy_snake_eq = func(x: float): return (1/1000*x**3 - 1/3.9*x**2 + 15*x)/30 - 100

var _snake_infos: Dictionary = {
	"NormalSnake" = [_normal_snake_eq, 0, load("res://Nodes/SnakeTypes/NormalSnake.tscn")],
	"FasterSnake" = [_fast_snake_eq, 0, load("res://Nodes/SnakeTypes/FasterSnake.tscn")],
	"BendySnake"  = [_bendy_snake_eq, 0, load("res://Nodes/SnakeTypes/FasterSnake.tscn")]}

@onready var _snake_spawner: Path2D = $%SnakeSpawner
@onready var _snake_spawner_childs: int = _snake_spawner.get_child_count()


func _process(delta: float):
	_time += delta
	
	# Set the time label
	$%TimeLabel.text = str(int(_time))


func _physics_process(delta):
	
	# Spawn any missing snakes
	for key in _snake_infos:
		var snake_type = _snake_infos[key]
		print(snake_type[0].call(_time))
		while snake_type[0].call(_time) >= snake_type[1]:
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
	
	# Update the target locations to be the character's position
	for child in _snake_spawner.get_children():
		if child.is_in_group("snake"):
			child.target_location = $Character.position


func _on_snake_detector_body_exited(body): #TODO fix
	body = body.get_parent()
	
	# Body must be a snake
	if not body.is_in_group("snake"):
		return
	
	# Reduce the amount of the given types of snake
	for key in _snake_infos:
		if body.is_in_group(key):
			_snake_infos[key][1] -= 1
	
	# Delete the snake
	body.queue_free()
