extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.

@onready var node_3d = $Node3D
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func _input(event):

	# Camera rotation via mouse movement
	if event is InputEventMouseMotion :
		rotate_y(deg_to_rad(-event.relative.x * 0.1))
		node_3d.rotate_x(deg_to_rad(event.relative.y* 0.1))
	if Input.is_action_just_pressed("esc"):
		get_tree().quit()

func _physics_process(delta):

	if !is_on_floor():
		velocity.y -= 7 * delta
	else:
		velocity.y = 0;
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = 300 * delta
	var input_dir = Input.get_vector("d", "a","s", "w") * delta
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y) ).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		

	move_and_slide()
