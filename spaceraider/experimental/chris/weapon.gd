extends RigidBody3D

class_name Weapon

var attachment_joint = null
var source_pos = Vector3(0,0,0)
var offset = Vector3(0,0,0)
var offset_reduction_rate = 3

func i_am_being_looked_at(player_that_is_looking_at_me : PlayerBody):
	pass
	
func hold(attach_to):
	attachment_joint = attach_to
	#collision_layer = 0

func shoot():
	pass
