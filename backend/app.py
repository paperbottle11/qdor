from flask import Flask, request, jsonify

app = Flask(__name__)

state = {
    "players": 2,
    "users": [],
    "turn": 1,
    "board": [[0]*17 for i in range(17)]
}

@app.route('/init')
def hello_world():
    try:
        players = int(request.args.get('players'))
        dim = int(request.args.get('dim'))
    except:
        return "Invalid input"
    if players == 2 or players == 4:
        state["players"] = players
    else:
        return "Invalid number of players, must be 2 or 4."
    if dim%2 == 1 and dim >= 5:
        board = [[0]*(dim*2-1)]*(dim*2-1)
        board[0][dim//2+1] = 1
        board[dim][dim//2+1] = 2
        if players == 4:
            board[dim//2+1][0] = 3
            board[dim//2+1][dim] = 4
        state["board"] = board
    else:
        return "Invalid board dimensions, must be odd and greater than 5."
    return 'Game Successfully Initialized'

@app.route('/connect')
def connect():
    if len(state["users"]) == state["players"]:
        return "Game is full"
    else:
        if len(state["users"]) == 0:
            state["users"].append((len(state["board"])//4, 0))
        elif len(state["users"]) == 1:
            state["users"].append((len(state["board"])//4, len(state["board"])//2-1))
        elif len(state["users"]) == 2:
            state["users"].append((0, len(state["board"])//4))
        elif len(state["users"]) == 3:
            state["users"].append((len(state["board"])//2-1, len(state["board"])//4))
    return str(len(state["users"]))

@app.route("/state")
def get_state():
    return jsonify(state)

@app.route("/move")
def move():
    try:
        x = int(request.args.get('x'))
        y = int(request.args.get('y'))
        player = int(request.args.get('player'))
    except:
        return "Invalid input"
    try:
        state["users"][player-1] = (x, y)
        state["turn"] = state["turn"] % 4 + 1
    except:
        return "Invalid move"
    return "Move successful"

@app.route("/add_wall")
def wall():
    try:
        x1 = int(request.args.get('x1'))
        y1 = int(request.args.get('y1'))
        x2 = int(request.args.get('x2'))
        y2 = int(request.args.get('y2'))
    except:
        return "Invalid input"
    try:
        state["board"][y1][x1] = 1
        state["board"][y2][x2] = 1
        state["turn"] = state["turn"] % 4 + 1
    except:
        return "Invalid wall placement"
    return "Wall placed successfully"

@app.route("/valid_moves")
def valid_moves():
    moves = [(0, 1), (0, -1), (1, 0), (-1, 0)]
    possible_moves = []
    board = state["board"]
    x,y = state["player"][state["turn"]-1]
    for dx, dy in moves:
        nx, ny = x+dx, y+dy
        if nx < 0 or nx >= len(board) or ny < 0 or ny >= len(board):
            continue
        if not board[(ny+y)//2][(nx+x)//2] == 1 and (nx,ny) not in state["player"]:
            possible_moves.append((dx, dy))
    return jsonify(possible_moves)

@app.route("/reset")
def reset():
    global state
    state = {
        "players": 2,
        "users": [],
        "turn": 1,
        "board": [[0]*17 for i in range(17)]
    }
    return "Game reset"

if __name__ == '__main__':
    app.run(debug=True)
