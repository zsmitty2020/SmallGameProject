extends CharacterBody3D

#Player Speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 7.5
var speed

#Other Consts
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.002 #Scale 0-100

#Head Bobbing
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var bob_time = 0.0

#Camera FOV
var BASE_FOV = 75	#Changeable from the player's options
const FOV_CHANGE = 1.25

@onready var head = $head
@onready var camera = $head/Camera3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(80))

	if Input.is_action_just_pressed("esc"):
		quit_game()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	#Handle Sprint
	if Input.is_action_pressed("shift"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("a", "d", "w", "s")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	#Head Bobbing
	bob_time += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = headbob(bob_time)
	
	#FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	move_and_slide()

func headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = sin(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func quit_game():
	get_tree().quit()
