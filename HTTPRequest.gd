extends HTTPRequest

var return_data

func _ready():
	self.request_completed.connect(_on_request_completed)

#"https://arnavkarekar.pythonanywhere.com/state"
func connect_to_server():
	request("https://arnavkarekar.pythonanywhere.com/connect")
	await get_tree().create_timer(1).timeout
	if return_data != "Game is full":
		Global.id = int(return_data)

func move(x,y):
	request("https://arnavkarekar.pythonanywhere.com/move?x=%d&y=%d&player=%d" % [x, y, Global.id])

func add_wall(x1,y1,x2,y2):
	request("https://arnavkarekar.pythonanywhere.com/add_wall?x1=%d&y1=%d&x2=%d&y2=%d" % [x1, y1, x2, y2])

func _on_request_completed(result, response_code, headers, body):
	return_data = body.get_string_from_utf8()
