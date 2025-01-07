extends RayCast3D


var bullet_spawn_location : Vector3 = Vector3(0,0,0)
var die : float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	force_raycast_update()
	$Node3D.global_position = bullet_spawn_location
	if is_colliding():
		point_bullet_at_target(get_collision_point())
	else:
		#print("do")
		#print(global_position)
		point_bullet_at_target(global_position + -global_basis.z * 200)

func point_bullet_at_target(target_pos):
	$Node3D.look_at(target_pos)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Node3D.global_position -= $Node3D.global_basis.z * delta * 50
	die -= delta
	if die <= 0:
		queue_free()
