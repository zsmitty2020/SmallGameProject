extends Holdable

class_name Weapon

@export var projectile : PackedScene = null

var max_ammo = 32
var cur_ammo = max_ammo

var firing = false
var fire_rate : float = 9.0 #in shots per second
var cur_fire_cooldown : float =  0

func use():
	firing = true
	
func dont_use():
	firing = false
	
func shoot():
	#print(firing)
	spawn_bullet()
	offset = .2
	cur_fire_cooldown = 1 / fire_rate
	cur_ammo -= 1
	$ammo.text = str(cur_ammo)
	#print("bang")

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
		
