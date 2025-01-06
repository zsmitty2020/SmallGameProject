extends Weapon

func spawn_bullet():
	
	var spike_target_pos = $barrel.global_transform.origin - $barrel.global_basis.z * 200
	if "camera" in possessor:
		print("spike gun wokring")
		spike_target_pos = possessor.camera.global_transform.origin - possessor.camera.global_basis.z * 200

	var new_bullet = projectile.instantiate()
	new_bullet.do_not_collide_with = possessor
	
	get_tree().current_scene.add_child(new_bullet)
	new_bullet.global_position  = $barrel.global_position
	new_bullet.look_at(spike_target_pos)
	
