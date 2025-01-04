extends Node3D

class_name Room

@export var room_width : int = 10
@export var room_height : int = 10

@export var tile_width : int = 4
@export var tile_height : int = 4

@export var room_segments : Array[PackedScene] = []
var usuable_room_segments = {}

var grid = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for segment in room_segments:
		var temp = segment.instantiate()
		if temp is not RoomSegment:
			print("this scene does not create a room segment")
			continue
		
		if temp.width % tile_width != 0 or temp.height % tile_height != 0:
			print("this room does not have proper width or height")
			continue
		
		var segments_width_in_tiles = temp.width / tile_width
		var segments_height_in_tiles = temp.height / tile_height
		usuable_room_segments[segment] = [segments_width_in_tiles, segments_height_in_tiles]
	
	for i in range(room_width):
		var column = []
		for j in range(room_height):
			column.append(0)
		grid.append(column)
	
	make_room()

#Dictionary
func make_room():
	clear_room()
	for x in range(room_width):
		for y in range(room_height):
			if grid[x][y] is Node3D:
				continue
			
			var potential_rooms = usuable_room_segments.keys()
			potential_rooms.shuffle()
			var placed_tile = false
			while not placed_tile:
				#print(grid[x][y])
				var segment = potential_rooms.pop_front()
				var segment_width = usuable_room_segments[segment][0]
				var segment_height = usuable_room_segments[segment][1]
				
				var valid_segment = true
				
				for x2 in range(segment_width):
					for y2 in range(segment_height):
						var a = x + x2
						var b = y + y2
						if a > room_width - 1 or b > room_height - 1:
							valid_segment = false
							continue
						if grid[a][b] is Node3D:
							
							valid_segment = false
				
				placed_tile = valid_segment
				if placed_tile:
					place_tile(x, y, segment)
	

func place_tile(x, y, segment : PackedScene):
	var segment_width = usuable_room_segments[segment][0]
	var segment_height = usuable_room_segments[segment][1]
	var new_segment = segment.instantiate()
	
	add_child(new_segment)
	new_segment.global_position = global_position + Vector3(x * tile_width, 0, y * tile_height)
	for a in range(segment_width):
		for b in range(segment_height):
			grid[x + a][y + b] = new_segment
	
func clear_room():
	for column in grid:
		for cell in column:
			if cell is Node3D:
				cell.queue_free()
	
