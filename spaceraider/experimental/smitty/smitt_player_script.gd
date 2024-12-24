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
const BASE_FOV = 75	#Changeable from the player's options
var fov
const FOV_CHANGE = -1.25
#Player Condition Variables
const MAX_HEALTH = 100.0	# from 0-100 to quickly understand, divide by 100 to get a percentage for UI
const MAX_OXYGEN = 100.0
var health
var oxygen
var oxygenLoseSpeed = 0.25

@onready var head = $head
@onready var camera = $head/Camera3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	health = MAX_HEALTH
	oxygen = MAX_OXYGEN

#All input fucntions. User inputs check the best matched function
# to consume the input in the order: _input() -> _shortcut_input() ->  _unhandled_key_input() -> _unhandled_input()

#USE THIS FOR NON-SHORTCUT RELATED KEYBOARD INPUTS
# (shortcuts are Godot's way of handling keyboard events that directly mess with UI elements)
func _unhandled_key_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("esc"):
		quit_game()
	
	else:
		debug_input(event)
			
#USE THIS FOR MOUSE AND JOYSTICK RELATED INPUTS
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(80))

#Function for debug input handling, made into it's own function for ease of reading _unhandled_key_input()
func debug_input(_event):	#Essentially just numkeys
	if Input.is_action_just_pressed("debug_damage10"):
		damage_player(10)
	elif Input.is_action_just_pressed("debug_damage25"):
		damage_player(25)
	elif Input.is_action_just_pressed("debug_heal10"):
		heal_player(10)
	elif Input.is_action_just_pressed("debug_heal25"):
		heal_player(25)
	elif Input.is_action_just_pressed("debug_oxyloss10"):
		lose_oxygen(10)
	elif Input.is_action_just_pressed("debug_oxygain10"):
		gain_oxygen(10)
	elif Input.is_action_just_pressed("debug_kill_player"):
		damage_player(MAX_HEALTH)
	elif Input.is_action_just_pressed("debug_no_oxygen"):
		lose_oxygen(MAX_OXYGEN)
#End Inputs Functions

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
	
	lose_oxygen(delta * oxygenLoseSpeed)
	
	move_and_slide()

func headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = sin(time * BOB_FREQ / 2) * BOB_AMP
	return pos

#Player Condition Functions
func damage_player(amount):
	health -= amount
	if health < 0.0:
		health = 0.0
	print("health: ", health)
func heal_player(amount):
	health += amount
	if health > MAX_HEALTH:
		health = MAX_HEALTH
	print("health: ", health)
func lose_oxygen(amount):
	oxygen -= amount
	if oxygen < 0.0:
		oxygen = 0.0
	print("oxygen: ", oxygen)
func gain_oxygen(amount):
	oxygen += amount
	if oxygen > MAX_HEALTH:
		oxygen = MAX_HEALTH
	print("oxygen: ", oxygen)

#Utility Functions
func quit_game():
	get_tree().quit()
