extends Node2D

var grid_cell = preload("res://grid.tscn")
var wall_scene = preload("res://wall.tscn")
var wall_highlight_texture = preload("res://Walls/gwall.png")
var wall_invalid_texture = preload("res://Walls/rwall.png")
var player_textures = [preload("res://Players/BLP.png"),preload("res://Players/RP.png"), preload("res://Players/GP.png"), preload("res://Players/YP.png")]
var player_placement_texture = preload("res://Players/GRP.png")
var board_size = 9
var grid_size = 64

var place_direction = 0
var place_mode = null

var player_positions = [[4,1],[5,8],[3,3]]
var players = []
var walls = []
var turn = 0
var refresh_timer_active = false
var game_running = true

@onready var get_state = $HTTPGet
@onready var net = $HTTPRequest
@onready var wall_highlight = wall_scene.instantiate()
@onready var player_highlight = Sprite2D.new()
@onready var message_box = $Message

# Called when the node enters the scene tree for the first time.
func _ready():	
	await net.connect_to_server()
	
	if Global.id == 1:
		$Controls.text = $Controls.text + "\n\nYou are Blue."
	elif Global.id == 2:
		$Controls.text = $Controls.text + "\n\nYou are Red."
	
	player_highlight.z_index = 100
	player_highlight.texture = player_placement_texture
	player_highlight.scale = Vector2(0.17,0.15)
	player_highlight.visible = false
	add_child(player_highlight)
	
	wall_highlight.texture = wall_highlight_texture
	wall_highlight.scale.x = 1
	wall_highlight.visible = false
	add_child(wall_highlight)
	
	refresh()

func refresh():
	await get_state.refresh_state()
	while get_state.current_data == null:
		await get_state.refresh_state()
	walls = get_state.current_data["board"]
	player_positions = get_state.current_data["users"]
	print(player_positions)
	turn = get_state.current_data["turn"]
	print("Turn: ", turn)
	draw_board()
	refresh_players()
	draw_walls()

func draw_board():
	for i in range(board_size):
		for j in range(board_size):
			var grid = grid_cell.instantiate()
			var x = (i + 1) * grid_size
			var y = (j + 1) * grid_size
			grid.position = Vector2(x, y)
			add_child(grid)

func refresh_players():
	for player in players:
		remove_child(player)
	players = []
	for i in range(len(player_positions)):
		var pos = player_positions[i]
		var player = Sprite2D.new()
		player.texture = player_textures[i]
		player.position = Vector2(grid_size * (pos[0] + 1), grid_size * (pos[1] + 1))
		player.scale = Vector2(0.17,0.15)
		player.z_index = 100
		add_child(player)
		players.append(player)
		
func draw_players():
	for i in range(len(players)):
		var pos = player_positions[i]
		var player = players[i]
		player.texture = player_textures[i]
		player.position = Vector2(grid_size * (pos[0] + 1), grid_size * (pos[1] + 1))
		player.scale = Vector2(0.17,0.15)

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
	var wall = wall_scene.instantiate()
	wall.rotation = deg_to_rad(90) if direction == 1 else 0
	
	if direction: wall.position = Vector2(grid_size * (x + 0.5) + 5, grid_size * (y + 0.5))
	else:		  wall.position = Vector2(grid_size * (x + 0.5), grid_size * (y + 0.5) - 5)
	
	
	add_child(wall)

func get_mouse_grid(pos):
	var mouse_x = pos[0]
	var mouse_y = pos[1]
	var x = floor(mouse_x / grid_size - 0.5)
	var y = floor(mouse_y / grid_size - 0.5)
	return [x,y]

func get_wall_pos_from_grid_pos(x,y,direction):
	x = int(x)
	y = int(y)
	
	if direction:
		var wall_pos = [x*2-1 if x > 0 else 0,y*2,0,0]
		wall_pos[2] = wall_pos[0]
		wall_pos[3] = wall_pos[1] + 2
		return wall_pos
	else:
		var wall_pos = [x*2,y*2-1 if y > 0 else 0,0,0]
		wall_pos[3] = wall_pos[1]
		wall_pos[2] = wall_pos[0] + 2
		return wall_pos

func refresh_clock(interval):
	refresh_timer_active = true
	await get_tree().create_timer(interval).timeout
	refresh()
	refresh_timer_active = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if len(player_positions) != 2:
		game_running = false
		message_box.text = "Awaiting opponent"
		if not refresh_timer_active: refresh_clock(2)
	else:
		if not game_running: refresh()
		game_running = true
		
	if not game_running: return
	if refresh_timer_active: return
	if turn == Global.id:
		message_box.text = "It's your turn!"
		var mouse_pos = get_viewport().get_mouse_position()
		var grid_pos = get_mouse_grid(mouse_pos)
		if Input.is_action_just_pressed("player_mode"):
			place_mode = "player"
			wall_highlight.visible = false
			player_highlight.visible = true
		elif Input.is_action_just_pressed("wall_mode"):
			place_mode = "wall"
			wall_highlight.visible = true
			player_highlight.visible = false
		
		if place_mode == "player":
			player_highlight.position = Vector2(grid_size * (grid_pos[0] + 1), grid_size * (grid_pos[1] + 1))
			player_highlight.visible = not (grid_pos[0] < 0 or grid_pos[0] > 8 or grid_pos[1] < 0 or grid_pos[1] > 8)
			var player_pos = player_positions[Global.id-1]
			if not player_highlight.visible or abs(player_pos[0] - grid_pos[0]) + abs(player_pos[1] - grid_pos[1]) > 1:
				return
			if Input.is_action_just_pressed("left_mouse"):
				if grid_pos[0] - player_pos[0] > 0:
					# right
					if walls[player_pos[1]*2][player_pos[0]*2+1] == 1:
						return
				elif grid_pos[0] - player_pos[0] < 0:
					# left
					if walls[player_pos[1]*2][player_pos[0]*2-1] == 1:
						return
				elif grid_pos[1] - player_pos[1] > 0:
					# down
					if walls[player_pos[1]*2+1][player_pos[0]*2] == 1:
						return
				elif grid_pos[1] - player_pos[1] < 0:
					# up
					if walls[player_pos[1]*2-1][player_pos[0]*2] == 1:
						return
				if grid_pos in player_positions: return
				players[Global.id-1].position = Vector2(grid_size * (grid_pos[0] + 1), grid_size * (grid_pos[1] + 1))
				place_mode = null
				player_highlight.visible = false
				net.move(grid_pos[0],grid_pos[1])
				turn = 2 if turn == 1 else 1
				refresh()
				
		if place_mode == "wall":
			if Input.is_action_just_pressed("rotate_placement"):
				place_direction = (place_direction + 1) % 2
			
			wall_highlight.rotation = deg_to_rad(90) if place_direction else 0
			if place_direction: wall_highlight.position = Vector2(grid_size * (grid_pos[0] + 0.5) + 5, grid_size * (grid_pos[1] + 0.5))
			else: wall_highlight.position = Vector2(grid_size * (grid_pos[0] + 0.5), grid_size * (grid_pos[1] + 0.5) - 5)
			
			if place_direction and (grid_pos[0] < 1 or grid_pos[0] > 8 or grid_pos[1] < 0 or grid_pos[1] > 7):
				wall_highlight.texture = wall_invalid_texture
				return
			elif not place_direction and (grid_pos[0] < 0 or grid_pos[0] > 7 or grid_pos[1] < 1 or grid_pos[1] > 8):
				wall_highlight.texture = wall_invalid_texture
				return
			else:
				wall_highlight.texture = wall_highlight_texture
			
			if Input.is_action_just_pressed("left_mouse"):
				place_wall(grid_pos[0], grid_pos[1], place_direction)
				if place_direction: place_wall(grid_pos[0], grid_pos[1] + 1, place_direction)
				else: place_wall(grid_pos[0] + 1, grid_pos[1], place_direction)
				
				var wall_pos = get_wall_pos_from_grid_pos(grid_pos[0], grid_pos[1], place_direction)
				wall_highlight.visible = false
				place_mode = null
				net.add_wall(wall_pos[0],wall_pos[1],wall_pos[2],wall_pos[3])
				turn = 2 if turn == 1 else 1
				refresh()
	else:
		message_box.text = "It's the opponent's turn!"
		if not refresh_timer_active: refresh_clock(2)
		
	if len(player_positions) == 2:
		if Global.id == 1:
			if player_positions[0][1] == 8:
				message_box.text = "You won!"
				game_running = false
			elif player_positions[1][1] == 0:
				message_box.text = "You lost!"
				game_running = false
		if Global.id == 2:
			if player_positions[1][1] == 0:
				message_box.text = "You won!"
				game_running = false
			elif player_positions[0][1] == 8:
				message_box.text = "You lost!"
				game_running = false


func _on_button_pressed():
	net.request("https://arnavkarekar.pythonanywhere.com/reset")
