extends Area3D

@export var projectile_speed : float = 30
@export var die_time : float = 1.0
var moving = true

var do_not_collide_with = null
var last_translation : Vector3 = Vector3(0,0,0)
func _process(delta: float) -> void:
	die_time -= delta
	
	if moving:
		last_translation = global_basis.z * projectile_speed * delta
		global_position -= last_translation
		
	
	if die_time <= 0:
		queue_free()
	
func _on_body_entered(body: Node3D) -> void:
	print(body)
	if body == do_not_collide_with:
		print("do2")
		return
	
	global_position += last_translation - global_basis.z * .2 #global_basis.z * .1 + last_translation
	die_time = 2
	moving = false
	set_deferred("monitoring", false)
	call_deferred("reparent", body)
