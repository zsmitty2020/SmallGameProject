extends Holdable

class_name Weapon

@export var projectile : PackedScene = null
@export var magazine : PackedScene = null

var max_ammo = 32
var cur_ammo = max_ammo

var semi_auto : bool = false
var firing : bool = false
var fire_rate : float = 9.0 #in shots per second
var cur_fire_cooldown : float =  0


@onready var reload_timer :Timer = $reload_timer
@onready var ammo_text : Label3D = $ammo
var reloading : bool = false

func _ready():
	ammo_text.text = str(cur_ammo)
	reload_timer.timeout.connect(reload_phase_2)

func use():
	if reloading:return
	
	firing = true
	
func dont_use():
	firing = false

func drop() -> bool:
	if reloading:
		
		return false
	
	dont_use()
	attachment_joint = null
	possessor = null
	freeze = false
	visible = true
	collision_layer = 1
	collision_mask = 1
	return true

func shoot():
	#print(firing)
	if cur_ammo <= 0:
		reload()
	
	spawn_bullet()
	offset = .2
	cur_fire_cooldown = 1 / fire_rate
	cur_ammo -= 1
	ammo_text.text = str(cur_ammo)
	#print("bang")

func reload():
	if reloading:
		return
	
	var new_dropped_mag = magazine.instantiate()
	new_dropped_mag.global_transform = $ammo_box_mesh.global_transform
	get_tree().current_scene.add_child(new_dropped_mag)
	reloading = true
	firing = false
	reload_timer.start()
	$ammo_box_mesh.visible = false
	ammo_text.visible = false
	#apply_central_impulse(global_basis.x * 20)

func reload_phase_2():
	reloading = false
	$ammo_box_mesh.visible = true
	ammo_text.visible = true
	cur_ammo = max_ammo
	ammo_text.text = str(cur_ammo)

func spawn_bullet():
	print("bang")

func personal_process(delta):
		
	if cur_fire_cooldown == 0:
		if firing:
			#print("do")
			shoot()

	if cur_fire_cooldown > 0:
		cur_fire_cooldown -= delta
		if cur_fire_cooldown < 0:
			cur_fire_cooldown = 0
		
