class_name Player

extends CharacterBody2D

const SPEED = 50.0
const JUMP_VELOCITY = 4.5

# Set by the authority, synchronized on spawn.
@export var id: int = 1 :
	set(value):
		id = value
		# Give authority over the player input to the appropriate peer.
		$PlayerInput.set_multiplayer_authority(id)

# Player synchronized input.
@onready var input: PlayerInput = $PlayerInput
@onready var camera: Camera2D = $Camera2D

func _ready():
	# Set the camera as current if we are this player.
	if id == multiplayer.get_unique_id():
		camera.make_current()
	
	# Only process on server.
	# EDIT: Let the client simulate player movement too to compesate network input latency.
	# set_physics_process(multiplayer.is_server())

func _physics_process(_delta):
	# Handle jump.
	if input.jumping and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Reset jump state.
	input.jumping = false
	
	# Handle movement.
	var direction: Vector2 = input.direction
	if direction:
		velocity.x = direction.x * SPEED
		velocity.y = direction.y * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	move_and_slide()
