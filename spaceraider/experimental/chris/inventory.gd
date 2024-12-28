extends Node

class_name Inventory

@export var left_hand_spot : Node3D = null
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

func use_left(on_this : Node3D):
	
	if left_hand_item != null:
		if dropping_items:
			left_hand_item.drop()
			left_hand_item = null
			return
		left_hand_item.use()
	else:
		if on_this is Holdable:
			left_hand_item = on_this
			left_hand_item.hold(left_hand_spot, inventory_owner)

func use_right(on_this : Node3D):
	
	if right_hand_item != null:
		if dropping_items:
			right_hand_item.drop()
			right_hand_item = null
			return
		right_hand_item.use()
	else:
		if on_this is Holdable:
			right_hand_item = on_this
			right_hand_item.hold(right_hand_spot, inventory_owner)


func stop_use_left():
	if left_hand_item:
		left_hand_item.dont_use()

func stop_use_right():
	if right_hand_item:
		right_hand_item.dont_use()

func swap_left_right_hand():
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
	
	if dropping_items and inventory_item_in_slot != null:
		inventory_item_in_slot.drop()
		inventory_slots[inventory_index] = null
		return
	
	inventory_slots[inventory_index] = left_hand_item
	left_hand_item = inventory_item_in_slot
	
	if left_hand_item:
		left_hand_item.visible = true
	
	if inventory_slots[inventory_index] :
		inventory_slots[inventory_index].visible = false
		inventory_slots[inventory_index].dont_use()
	#if left_hand_item:
		#pass
	
	#if inventory_item_in_slot:
		#pass
	
	
