extends Node3D

class_name RoomSegment

##width of the room in meters
@export var width : int = 4

##height of the room in meters
@export var height : int = 4

##width of how many meters to remove from the bottom right corner
#@export var empty_corner_width : int = 0

##height of how many meters to remove from the bottom right corner
#@export var empty_corner_height : int = 0

@export var holes : Array[Vector4i] = []

var width_in_tiles = 1
var height_in_tiles = 1
var grid = []

func gen_grid():
	for i in range(width_in_tiles):
		var column = []
		for j in range(height_in_tiles):
			column.append(1)
		grid.append(column)
	
	add_holes_to_grid()

func add_holes_to_grid():
	for hole in holes:
		var coords = Vector2(hole[0], hole[1])
		var dimensions = Vector2(hole[2], hole[3])
		
		if coords.x < 0 or coords.x >= width:
			print("hole cannot exist")
			continue
		
		if coords.y < 0 or coords.y >= height:
			print("hole cannot exit")
			continue
		
		for w in range(dimensions[0]):
			var x = coords[0] + w
			if x >= width:
				continue
			for h in range(dimensions[1]):
				var y = coords[1] + h
				if y >= height:
					continue
				grid[x][y] = 0
