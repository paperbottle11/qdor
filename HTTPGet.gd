extends HTTPRequest

var current_data = {}

func _ready():
	self.request_completed.connect(_on_request_completed)

#"https://arnavkarekar.pythonanywhere.com/state"
func refresh_state():
	request("https://arnavkarekar.pythonanywhere.com/state")
	await get_tree().create_timer(1).timeout

func _on_request_completed(result, response_code, headers, body):
	current_data = JSON.parse_string(body.get_string_from_utf8())
	#print(current_data)
