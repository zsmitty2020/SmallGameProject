extends Node

class_name Inventory

@export var left_hand_spot : Node3D = null
@export var both_hands_spot : Node3D = null
@export var right_hand_spot : Node3D = null
@export var inventory_owner : Node3D = null
@export var inventory_info : Node3D = null

var left_hand_item : Holdable = null
var right_hand_item : Holdable = null

@export var inventory_size = 4
var inventory_slots : Array[Holdable] = []
var dropping_items : bool = false

func _ready():
	for i in range(inventory_size):
		inventory_slots.append(null)

func print_slots():
	print(inventory_slots)

func use_left(on_this : Node3D):
	
	if left_hand_item != null:
		if dropping_items:
			
			if left_hand_item.needs_two_hands:
				#right_hand_item.drop()
				right_hand_item = null
			left_hand_item.drop()
			left_hand_item = null
			return
		left_hand_item.use()
	else:
		
		if on_this is Holdable:
			left_hand_item = on_this
			if left_hand_item.needs_two_hands:
				if right_hand_item:
					left_hand_item = null
					return
				
				right_hand_item = left_hand_item
				left_hand_item.hold(both_hands_spot, inventory_owner)
			else:
				left_hand_item.hold(left_hand_spot, inventory_owner)
	
func use_right(on_this : Node3D):
	
	if right_hand_item != null:
		if dropping_items:
			if right_hand_item.needs_two_hands:
				#left_hand_item.drop()
				left_hand_item = null
			right_hand_item.drop()
			right_hand_item = null
			return
		right_hand_item.use()
	else:
		if on_this is Holdable:
			right_hand_item = on_this
			if right_hand_item.needs_two_hands:
				if left_hand_item:
					right_hand_item = null
					return
				left_hand_item = right_hand_item
				right_hand_item.hold(both_hands_spot, inventory_owner)
				
			else:
				right_hand_item.hold(right_hand_spot, inventory_owner)
	

func stop_use_left():
	if left_hand_item:
		left_hand_item.dont_use()

func stop_use_right():
	if right_hand_item:
		right_hand_item.dont_use()

func swap_left_right_hand():
	if left_hand_item:
		if left_hand_item.needs_two_hands:
			return

	var temp = left_hand_item
	left_hand_item = right_hand_item
	right_hand_item = temp
	
	if right_hand_item:
		right_hand_item.dont_use()
		right_hand_item.hold(right_hand_spot, inventory_owner)
	
	if left_hand_item:
		left_hand_item.dont_use()
		left_hand_item.hold(left_hand_spot, inventory_owner)

func reload_weapons():
	if left_hand_item is Weapon:
		left_hand_item.reload()
	
	if right_hand_item is Weapon:
		right_hand_item.reload()

func inventory_button_pressed(button:int):
	if button > 57 or button < 48:
		return
	
	var actual_button = button - 48 #what number key you are pressing
	var inventory_index = actual_button - 1 #arrays start at 0, so increment down by 1
	
	if inventory_index < 0:
		inventory_index += 10
	
	if inventory_index > inventory_size - 1:
		return

	var inventory_item_in_slot = inventory_slots[inventory_index]
	
	if dropping_items:
		if inventory_item_in_slot != null:
			inventory_item_in_slot.drop()
			
			if inventory_item_in_slot.needs_two_hands:
				var other_spot = get_other_slot_of_two_handed_item_in_inventory(inventory_index, inventory_item_in_slot)
				inventory_slots[other_spot] = null
			
			inventory_slots[inventory_index] = null
		return
	#print(left_hand_item)
	if left_hand_item == null:
		###IF NOTHING IS IN MY LEFT HAND DO THIS
		
		if inventory_item_in_slot == null:
			return
		
		if inventory_item_in_slot.needs_two_hands:
			var other_spot = get_other_slot_of_two_handed_item_in_inventory(inventory_index, inventory_item_in_slot)
			
			var temp_right_hand_item = right_hand_item
			
			left_hand_item = inventory_item_in_slot
			right_hand_item = inventory_item_in_slot
			left_hand_item.visible = true
			
			inventory_slots[inventory_index] = null
			inventory_slots[other_spot] = null
			
			
			if temp_right_hand_item:
				if other_spot > inventory_index:
					inventory_slots[other_spot] = temp_right_hand_item
				else:
					inventory_slots[inventory_index] = temp_right_hand_item
				
				temp_right_hand_item.visible = false
				temp_right_hand_item.dont_use()
		else:
			
			inventory_slots[inventory_index] = null
			left_hand_item = inventory_item_in_slot
			
			left_hand_item.visible = true
			#inventory_slots[inventory_index].dont_use()
	else:
		if left_hand_item.needs_two_hands:
			#print("do a")
			if inventory_item_in_slot == null:
				if inventory_index + 1 == inventory_size:
					print("nuh uh, you can't put this here")
					return
				
				var inventory_item_in_second_slot = inventory_slots[inventory_index + 1]
				
				var thing_to_put_in_right_hand = null
					
				if inventory_item_in_second_slot != null:
					if inventory_item_in_second_slot.needs_two_hands:
						print("nuh uh, you can't put this here")
						return
					else:
						thing_to_put_in_right_hand = inventory_item_in_second_slot
					
				inventory_slots[inventory_index] = left_hand_item
				inventory_slots[inventory_index + 1] = left_hand_item
					
				left_hand_item.visible = false
				left_hand_item.dont_use()
				left_hand_item = null
				right_hand_item = thing_to_put_in_right_hand
				if right_hand_item:
					right_hand_item.drop()
					right_hand_item.hold(right_hand_spot, get_parent())
					right_hand_item.visible = true
				return
			
			if inventory_item_in_slot.needs_two_hands:
				
				var other_spot = get_other_slot_of_two_handed_item_in_inventory(inventory_index, inventory_item_in_slot)
				
				inventory_slots[inventory_index] = left_hand_item
				inventory_slots[other_spot] = left_hand_item
				
				left_hand_item.visible = false
				left_hand_item.dont_use()
				
				left_hand_item = inventory_item_in_slot
				right_hand_item = inventory_item_in_slot
				left_hand_item.visible = true
				
				return
			else:
				#print("do")
				var inventory_item_in_second_slot = inventory_slots[inventory_index + 1]
				
				var thing_to_put_in_right_hand = null
				
				if inventory_item_in_second_slot != null:
					if inventory_item_in_second_slot.needs_two_hands:
						print("nuh uh, you can't put this here")
						return
					else:
						thing_to_put_in_right_hand = inventory_item_in_second_slot
				
				inventory_slots[inventory_index] = left_hand_item
				inventory_slots[inventory_index + 1] = left_hand_item
				
				left_hand_item.visible = false
				left_hand_item.dont_use()
				
				left_hand_item = inventory_item_in_slot
				if left_hand_item:
					left_hand_item.visible = true
				
				right_hand_item = thing_to_put_in_right_hand
				if right_hand_item:
					right_hand_item.visible = true
				
				return
			
		else:
			if inventory_item_in_slot == null:
				inventory_slots[inventory_index] = left_hand_item
				left_hand_item.visible = false
				left_hand_item.dont_use()
				left_hand_item = null
				return
			
			if inventory_item_in_slot.needs_two_hands:
				var other_spot = get_other_slot_of_two_handed_item_in_inventory(inventory_index, inventory_item_in_slot)
				
				var temp_right_hand_item = right_hand_item
				var temp_left_hand_item = left_hand_item
				
				left_hand_item = inventory_item_in_slot
				right_hand_item = inventory_item_in_slot
				left_hand_item.visible = true
				
				inventory_slots[inventory_index] = null
				inventory_slots[other_spot] = null
				
				
				if temp_right_hand_item:
					if other_spot > inventory_index:
						inventory_slots[other_spot] = temp_right_hand_item
					else:
						inventory_slots[inventory_index] = temp_right_hand_item
					
					temp_right_hand_item.visible = false
					temp_right_hand_item.dont_use()
				
				if temp_left_hand_item:
					if other_spot < inventory_index:
						inventory_slots[other_spot] = temp_left_hand_item
					else:
						inventory_slots[inventory_index] = temp_left_hand_item
					
					temp_left_hand_item.visible = false
					temp_left_hand_item.dont_use()
			else:
				inventory_slots[inventory_index] = left_hand_item
				left_hand_item.visible = false
				left_hand_item.dont_use()
				left_hand_item = null
				
				left_hand_item = inventory_item_in_slot
				left_hand_item.visible = true

	#inventory_slots[inventory_index] = left_hand_item
	#left_hand_item = inventory_item_in_slot
	
	#if left_hand_item:
		#left_hand_item.visible = true
	
	#if inventory_slots[inventory_index]:
		#inventory_slots[inventory_index].visible = false
		#inventory_slots[inventory_index].dont_use()
	#if left_hand_item:
		#pass
	
	#if inventory_item_in_slot:
		#pass

func get_other_slot_of_two_handed_item_in_inventory(index_A : int, item : Holdable) -> int:
	
	if index_A == 0:
		return 1
	
	if index_A == inventory_size - 1:
		return inventory_size - 2
	
	if inventory_slots[index_A + 1] == item:
		return index_A + 1
	
	return index_A - 1
