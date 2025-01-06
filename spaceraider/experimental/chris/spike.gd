extends Area3D

@export var projectile_speed : float = 25
@export var die_time : float = 1.0
var moving = true

var do_not_collide_with = null
func _process(delta: float) -> void:
	die_time -= delta
	
	if moving:
		global_position -= global_basis.z * projectile_speed * delta
	
	if die_time <= 0:
		queue_free()
	


func _on_body_entered(body: Node3D) -> void:
	if body == do_not_collide_with:
		print("do2")
		return
	
	global_position += global_basis.z * .1
	die_time = 2
	#set_deferred("monitoring", false)
	moving = false
	set_deferred("monitoring", false)
	call_deferred("reparent", body)
