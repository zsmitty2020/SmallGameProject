extends CharacterBody3D

class_name PlayerBody
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
var BASE_FOV : float = 90	#Changeable from the player's options
const FOV_CHANGE = 1.25

@onready var head = $head
@onready var camera = $head/Camera3D
@onready var eye_ray = $head/Camera3D/look_ray

var i_am_looking_at : Holdable = null
var i_am_holding = null
#signal im_looking_at(object)

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(80))
	
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if event.pressed:
				if i_am_holding:
					#print("start shooting")
					i_am_holding.use()
			else:
				if i_am_holding:
					i_am_holding.dont_use()
		
	
	if event is InputEventKey and event.pressed:
		if OS.get_keycode_string(event.keycode) == 'E':
			
			if i_am_holding:
				i_am_holding.drop()
				i_am_holding = null
			
			if i_am_looking_at:
				i_am_holding = i_am_looking_at
				i_am_looking_at.hold($head/right_hand,self)

	
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
	#print(camera.transform.origin)
	if input_dir == Vector2(0,0):
		camera.transform.origin = camera.transform.origin.lerp(Vector3(0,0,0), delta * 8)
		bob_time = 0
	else:
		bob_time += delta * velocity.length() * float(is_on_floor())
		camera.transform.origin = headbob(bob_time)
	
	#FOV
	if speed == SPRINT_SPEED:
		var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
		var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
		camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	else:
		camera.fov = lerp(camera.fov, BASE_FOV, delta * 8.0)
	
	check_look_ray()
	move_physics_objects_out_of_my_way(delta)
	
	move_and_slide()

func headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = sin(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func check_look_ray():
	
	$head/right_hand.look_at(camera.global_position - camera.global_basis.z * 10)
	$info_label.text = ""
	i_am_looking_at = null
	
	##Fail states to avoid calculating more than necessary
	if not eye_ray.is_colliding():
		#$head/right_hand.rotation = Vector3(0,0,0)
		return
	#$head/right_hand.look_at(eye_ray.get_collision_point())
	
	if not eye_ray.get_collider().has_method("i_am_being_looked_at"):
		return
		
	i_am_looking_at = eye_ray.get_collider()
	$info_label.global_position = i_am_looking_at.global_position
	$info_label.global_position.y += .75
	$info_label.text = i_am_looking_at.i_am_being_looked_at()
	#$info_label.look_at(camera.global_position)
	
func move_physics_objects_out_of_my_way(delta):

	var collision = move_and_collide(velocity * delta, true)
	if collision:
		var object_collided_with = collision.get_collider()
		
		if object_collided_with.global_position.y < global_position.y - 1:
			return
		#print(object_collided_with)
		if object_collided_with is RigidBody3D:
			var pos =  collision.get_position()#object_collided_with.global_position - collision.get_position()
			pos.y = object_collided_with.global_position.y
			pos = pos - object_collided_with.global_position
			var dir = global_position.direction_to(collision.get_position())
			dir.y = 0
			object_collided_with.apply_impulse(dir, pos)

func quit_game():
	get_tree().quit()
