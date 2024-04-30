extends Node2D

var grid_cell = preload("res://grid.tscn")
var wall_scene = preload("res://wall.tscn")
var board_size = 9
var grid_size = 64

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(board_size):
		for j in range(board_size):
			var grid = grid_cell.instantiate()
			var x = (i + 1) * grid_size
			var y = (j + 1) * grid_size
			grid.position = Vector2(x, y)
			add_child(grid)

func place_wall(x, y, direction):
	var wall = wall_scene.instantiate()
	if direction == 0:
		wall.position = Vector2(grid_size * (x + 0.5), grid_size * (y + 0.5) - 5)
	else:
		wall.position = Vector2(grid_size * (x + 0.5) + 5, grid_size * (y + 0.5))
	wall.rotation = deg_to_rad(90) if direction == 1 else 0
	add_child(wall)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		place_wall(1,1,0)
