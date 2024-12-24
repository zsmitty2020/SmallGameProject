extends Weapon

func spawn_bullet():
	$AudioStreamPlayer3D.play()
	var new_bullet = projectile.instantiate()
	new_bullet.bullet_spawn_location = $barrel.global_position
	if "camera" in possessor:
		new_bullet.global_transform = possessor.camera.global_transform
	else:
		new_bullet.global_transform = possessor.global_transform
	get_tree().current_scene.add_child(new_bullet)
