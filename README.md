# Multiplayer Backend Game API

This project is an online multiplayer implementation of the game **Quoridor** using Godot. The backend is developed with Flask to handle multiple players, moves, and board interactions. Quoridor is a strategy board game where players aim to reach the opposite side of the board while strategically placing walls to block opponents.

## API Endpoints

### 1. Initialize the Game

**Endpoint**: `/init`

**Method**: GET

**Parameters**:
- `players` (int): Number of players (must be 2 or 4).
- `dim` (int): The dimension of the board (must be an odd number and greater than 5).

**Response**:
- Success: "Game Successfully Initialized"
- Failure: Error message specifying invalid input

### 2. Connect a Player

**Endpoint**: `/connect`

**Method**: GET

**Description**: Allows a player to join the game until the maximum number of players is reached.

**Response**:
- Success: Player number (1 to 4)
- Failure: "Game is full" if all player slots are filled

### 3. Get Game State

**Endpoint**: `/state`

**Method**: GET

**Description**: Retrieves the current game state, including player positions, board layout, and whose turn it is.

**Response**:
- JSON object representing the game state

### 4. Make a Move

**Endpoint**: `/move`

**Method**: GET

**Parameters**:
- `x` (int): X-coordinate of the new position
- `y` (int): Y-coordinate of the new position
- `player` (int): Player number making the move (1 to 4)

**Response**:
- Success: "Move successful"
- Failure: Error message specifying invalid input or move

### 5. Place a Wall

**Endpoint**: `/add_wall`

**Method**: GET

**Parameters**:
- `x1`, `y1` (int): Coordinates of the first wall segment
- `x2`, `y2` (int): Coordinates of the second wall segment

**Response**:
- Success: "Wall placed successfully"
- Failure: Error message specifying invalid input or wall placement

### 6. Get Valid Moves

**Endpoint**: `/valid_moves`

**Method**: GET

**Description**: Returns valid moves for the current player based on their position and the board state.

**Response**:
- JSON array of possible moves

### 7. Reset the Game

**Endpoint**: `/reset`

**Method**: GET

**Description**: Resets the game state to its initial configuration.

**Response**:
- "Game reset"

## How It Works

- The game maintains a state that includes the number of players, current player positions, and turn information.
- Players take turns to make moves or place walls on the board.
- The game can be reset at any time using the `/reset` endpoint.

## Notes

- The board is represented as a 2D array.
- Player positions and walls are updated based on player actions.
- Error handling is implemented for invalid inputs and moves.

## License

This project is open-source and available under the MIT License. Feel free to modify and adapt the code for your needs.
