extends Node2D

var grid_cell = preload("res://grid.tscn")
var wall_scene = preload("res://wall.tscn")
var player_textures = [preload("res://Players/BLP.png"),preload("res://Players/RP.png"), preload("res://Players/GP.png"), preload("res://Players/YP.png")]
var board_size = 9
var grid_size = 64

var player_positions = [[4,1],[5,8],[3,3]]
var walls = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(17):
		var row = []
		for j in range(17):
			row.append(0)
		walls.append(row)
	walls[4][1] = 1
	walls[6][1] = 1
	walls[1][0] = 1
	walls[1][2] = 1
	print(walls)

	rebuild_board()

func rebuild_board():
	draw_board()
	draw_players()
	draw_walls()

func draw_board():
	for i in range(board_size):
		for j in range(board_size):
			var grid = grid_cell.instantiate()
			var x = (i + 1) * grid_size
			var y = (j + 1) * grid_size
			grid.position = Vector2(x, y)
			add_child(grid)

func draw_players():
	for i in range(len(player_positions)):
		var pos = player_positions[i]
		var player = Sprite2D.new()
		player.texture = player_textures[i]
		player.position = Vector2(grid_size * (pos[0] + 1), grid_size * (pos[1] + 1))
		player.scale = Vector2(0.17,0.15)
		add_child(player)

func draw_walls():
	var wallstemp = walls.duplicate()
	for i in range(len(wallstemp)):
		if i % 2 == 0:
			for j in range(1, len(wallstemp[i]), 2):
				if wallstemp[i][j] == 1:
					place_wall(ceil(j/2)+1,i/2,1)
		else:
			for j in range(0, len(wallstemp[i]), 2):
				if wallstemp[i][j] == 1:
					place_wall(j/2,ceil(i/2)+1,0)

func place_wall(x, y, direction):
	if type_string(typeof(x)) != "int" or type_string(typeof(y)) != "int" or type_string(typeof(direction)) != "int":
		print("Error: wall input is not of type integer")
		return
	
	var wall = wall_scene.instantiate()
	wall.rotation = deg_to_rad(90) if direction == 1 else 0
	
	if direction: wall.position = Vector2(grid_size * (x + 0.5) + 5, grid_size * (y + 0.5))
	else:		  wall.position = Vector2(grid_size * (x + 0.5), grid_size * (y + 0.5) - 5)
	
	add_child(wall)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if Input.is_action_just_pressed("ui_accept"):
		#place_wall(1,1,0)
		#place_wall(2,1,0)
	pass
