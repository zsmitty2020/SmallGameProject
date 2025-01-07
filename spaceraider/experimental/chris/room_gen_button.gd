extends Holdable

@export var room_to_gen : Room = null

func use():
	if room_to_gen != null:
		room_to_gen.make_room()
