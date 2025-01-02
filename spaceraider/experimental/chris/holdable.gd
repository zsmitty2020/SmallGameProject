extends RigidBody3D

class_name Holdable

@export var needs_two_hands : bool = false
@export var weight : int = 1

var possessor : Node3D = null
var attachment_joint : Node3D = null
var offset = 0
var offset_reduction_rate = 3

@onready var grab_spot = $grab_spot

var info_text = "a freaking holdable object"

func i_am_being_looked_at():
	return info_text
	
func hold(attach_to, holder):
	attachment_joint = attach_to
	possessor = holder
	freeze = true
	collision_layer = 0
	collision_mask = 0
	
func drop(): #-> bool:
	dont_use()
	attachment_joint = null
	possessor = null
	freeze = false
	visible = true
	collision_layer = 1
	collision_mask = 1
	#return true

func use():
	pass 

func dont_use():
	pass

func _process(delta):
	if attachment_joint:
		global_basis = attachment_joint.global_basis
		#global_basis = global_basis.slerp(attachment_joint.global_basis, delta * 16).orthonormalized()
		global_position = attachment_joint.global_position + (global_position - (grab_spot.global_position - offset * global_basis.z))
	offset = offset + (0 - offset) * delta * 5
	personal_process(delta)


func personal_process(delta):
	pass
