extends Holdable

class_name Weapon

@export var projectile : PackedScene = null
@export var magazine : PackedScene = null

@export var max_ammo = 32
@onready var cur_ammo = max_ammo

@export var semi_auto : bool = false
var semi_auto_reset = true

var firing : bool = false
@export var fire_rate : float = 9.0 #in shots per second
var cur_fire_cooldown : float =  0

@export var recoil = .2

@onready var reload_timer :Timer = $reload_timer
@onready var ammo_text : Label3D = $ammo
@onready var ammo_box : MeshInstance3D = $ammo_box_mesh
var reloading : bool = false

func _ready():
	ammo_text.text = str(cur_ammo)
	reload_timer.timeout.connect(reload_phase_2)

func use():
	if reloading:return
	
	firing = true

func dont_use():
	firing = false
	semi_auto_reset = true

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
	
	
	if semi_auto:
		semi_auto_reset = false
	spawn_bullet()
	offset = recoil
	cur_fire_cooldown = 1 / fire_rate
	cur_ammo -= 1
	ammo_text.text = str(cur_ammo)
	
	if cur_ammo == 0:
		reload()
	#print("bang")

func reload():
	if reloading:
		return
	
	reloading = true
	firing = false
	reload_timer.start()
	
	ammo_box.visible = false
	ammo_text.visible = false
	if magazine == null:
		return
	
	var new_dropped_mag = magazine.instantiate()
	new_dropped_mag.global_transform = ammo_box.global_transform
	get_tree().current_scene.add_child(new_dropped_mag)
	
	#apply_central_impulse(global_basis.x * 20)

func reload_phase_2():
	reloading = false
	ammo_box.visible = true
	ammo_text.visible = true
	cur_ammo = max_ammo
	ammo_text.text = str(cur_ammo)

func spawn_bullet():
	print("bang")

func personal_process(delta):
		
	if cur_fire_cooldown == 0:
		if firing and semi_auto_reset:
			#print("do")
			shoot()

	if cur_fire_cooldown > 0:
		cur_fire_cooldown -= delta
		if cur_fire_cooldown < 0:
			cur_fire_cooldown = 0
	
