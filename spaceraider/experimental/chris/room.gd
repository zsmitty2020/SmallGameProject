extends Node3D

class_name Room

@export var room_width : int = 10
@export var room_height : int = 10

@export var tile_width : int = 4
@export var tile_height : int = 4

@export var room_segments : Array[PackedScene] = []
var usuable_room_segments = {}

##x,y are the coords of the hole, z and w are the width and height respectively
@export var holes : Array[Vector4i] = []

@export var wall_scene : PackedScene = null

var grid = []
# Called when the node enters the scene tree for the first time.
func _process(delta):
	make_room()

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
		temp.width_in_tiles = segments_width_in_tiles
		temp.height_in_tiles = segments_height_in_tiles
		temp.gen_grid()
		#print(temp.grid)
		usuable_room_segments[segment] = [segments_width_in_tiles, segments_height_in_tiles, temp.grid]
		
	for i in range(room_width):
		var column = []
		for j in range(room_height):
			column.append(1)
		grid.append(column)
	
	add_holes_to_grid()
	make_room()
	#make_room()

func add_holes_to_grid():
	for hole in holes:
		var coords = Vector2(hole[0], hole[1])
		var dimensions = Vector2(hole[2], hole[3])
		
		if coords.x < 0 or coords.x >= room_width:
			print("hole cannot exist")
			continue
		
		if coords.y < 0 or coords.y >= room_height:
			print("hole cannot exit")
			continue
		
		for w in range(dimensions[0]):
			var x = coords[0] + w
			if x >= room_width:
				continue
			for h in range(dimensions[1]):
				var y = coords[1] + h
				if y >= room_height:
					continue
				grid[x][y] = 0
			
#Dictionary
func make_room():
	clear_room()
	for x in range(room_width):
		for y in range(room_height):
			if grid[x][y] is Node3D:
				continue
			else:
				if grid[x][y] == 0:
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
						#print(usuable_room_segments[segment][2])
						if usuable_room_segments[segment][2][x2][y2] == 0:
							continue
						
						var a = x + x2
						var b = y + y2
						if a > room_width - 1 or b > room_height - 1:
							valid_segment = false
							continue
						
						if grid[a][b] is Node3D:
							valid_segment = false
						else:
							if grid[a][b] == 0:
								valid_segment = false
				
				placed_tile = valid_segment
				if placed_tile:
					place_tile(x, y, segment)
					
	place_walls()
	
func place_tile(x, y, segment : PackedScene):
	var segment_width = usuable_room_segments[segment][0]
	var segment_height = usuable_room_segments[segment][1]
	var new_segment = segment.instantiate()
	
	add_child(new_segment)
	new_segment.global_position = global_position + Vector3(x * tile_width, 0, y * tile_height)
	for a in range(segment_width):
		for b in range(segment_height):
			if usuable_room_segments[segment][2][a][b] == 0:
				continue
			grid[x + a][y + b] = new_segment

func place_walls():
	for x in range(room_width):
		for y in range(room_height):
			if grid[x][y] is not Node3D:
				if grid[x][y] == 0:
					continue
			
			var left_cell = Vector2(x-1, y)
			var right_cell = Vector2(x+1, y)
			var above_cell = Vector2(x, y - 1)
			var below_cell = Vector2(x, y + 1)
			
			#handle left cell
			if left_cell.x < 0:
				place_wall(x,y, -1, 0)
			elif grid[left_cell.x][left_cell.y] is Node3D:
				pass
			elif grid[left_cell.x][left_cell.y] == 0:
				place_wall(x,y, -1, 0)

			#handle right cell
			if right_cell.x == room_width:
				place_wall(x,y, 1, 0)
			elif grid[right_cell.x][right_cell.y] is Node3D:
				pass
			elif grid[right_cell.x][right_cell.y] == 0:
				place_wall(x,y, 1, 0)
			
			#handle top cell
			if above_cell.y < 0:
				place_wall(x,y, 0, -1)
			elif grid[above_cell.x][above_cell.y] is Node3D:
				pass
			elif grid[above_cell.x][above_cell.y] == 0:
				place_wall(x,y, 0, -1)
			
			#handle bottom cell
			if below_cell.y == room_height:
				place_wall(x,y, 0, 1)
			elif grid[below_cell.x][below_cell.y] is Node3D:
				pass
			elif grid[below_cell.x][below_cell.y] == 0:
				place_wall(x,y, 0, 1)

func place_wall(cell_x, cell_y, offset_x = 0, offset_y = 0):
	
	var tile = grid[cell_x][cell_y]
	if tile is not  Node3D:
		return
	var new_wall = wall_scene.instantiate()
	tile.add_child(new_wall)
	
	new_wall.global_position = global_position + Vector3(tile_width * cell_x, 0, tile_height * cell_y)
	
	new_wall.global_position += Vector3(tile_width /2, 0, tile_height / 2)
	
	new_wall.global_position.x += (tile_width / 2) * offset_x
	new_wall.global_position.z += (tile_height / 2) * offset_y
	new_wall.global_position.y += new_wall.mesh.size.y / 2
	
	new_wall.global_rotation.y = PI/2 * offset_x
	
func clear_room():
	for x in range(room_width):
		for y in range(room_height):
			var cell = grid[x][y]
			if cell is Node3D:
				#print("do")
				cell.queue_free()
				grid[x][y]= 1
				#cell = 1
			elif cell != 0:
				grid[x][y] = 1
