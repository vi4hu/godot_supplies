"""
Credits:
Some concepts from https://github.com/hamburgear/Godot-Action-RPG-Inventory
"""
@tool
extends Area2D

@onready var grid: Sprite2D = $Grid
@onready var collision: CollisionShape2D = $Collision
@onready var bg: ColorRect = $BG

@export var grid_dimension : Vector2 = Vector2(4, 4) :
	set (value):
		grid_dimension = _handle_grid_size(value)
@export var bg_color: Color = Color(0.2, 0.2, 0.3)
const grid_size : Vector2 = Vector2(32, 32)
var is_ready: bool = false
var supply_slots: Dictionary
var supply_items: Dictionary
var item_path = 'res://addons/supplies/examples/items/'
var ingame_path = 'res://addons/supplies/examples/gameitems/'
var grid_world_location: Array


func _ready() -> void:
	is_ready = true
	_setup()
	fill_supplies()
	initiate()
	grid_world_location.append(global_position)
	grid_world_location.append(global_position+grid_dimension*grid_size)


func _input(event: InputEvent):
	if event.is_action_pressed('save'):
		SuppliesData.save(supply_items)
	if event.is_action_pressed('drop'):
		SuppliesData.drop()

	if event is InputEventKey and event.is_pressed():
		print(event.unicode)
		if event.unicode == 98:
			if visible:
				hide()
			else:
				show()


func _setup() -> void:
	_setup_collision(grid_dimension)
	_set_bg(grid_dimension)
	_setup_grid(grid_dimension)


func _setup_grid(value: Vector2) -> void:
	grid.set_centered(false)
	grid.set_region_enabled(true)
	grid.set_region_rect(Rect2(0, 0, (grid_size.x * value.x), (grid_size.y * value.y)))
	grid.set_texture_repeat(2)


func _setup_collision(value: Vector2) -> void:
	collision.set_position(
		Vector2((grid_size.x * value.x)/2, (grid_size.y * value.y)/2)
	)
	collision.shape.set_size(
		Vector2((grid_size.x * value.x), (grid_size.y * value.y))
	)


func _set_bg(value: Vector2) -> void:
	bg.set_color(bg_color)
	bg.set_position(Vector2.ZERO)
	bg.set_size(Vector2((grid_size.x * value.x), (grid_size.y * value.y)))
	bg.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)


func _handle_grid_size(value: Vector2) -> Vector2:
	if is_ready:
		_setup_collision(value)
		_set_bg(value)
		_setup_grid(value)
	return value


func add_supply(supply_data: Dictionary) -> void:
	var supply = load(item_path + supply_data.supply_code + '.tscn').instantiate()
	var added_supply_data: Dictionary = supply.initiate(supply_data)
	if added_supply_data.is_empty():
		supply.queue_free()
		return
	
	var supply_item_data = added_supply_data.duplicate()
	supply_items[supply_item_data.uuid] = supply_item_data
	
	added_supply_data.slot_id = parse_vector(added_supply_data.slot_id)
	for y_ctr in range(added_supply_data.dimension.y):
		for x_ctr in range(added_supply_data.dimension.x):
			supply_slots[
				Vector2(added_supply_data.slot_id.x + x_ctr, added_supply_data.slot_id.y + y_ctr)
			] = supply.uuid
	add_child(supply)


func fill_supplies() -> void:
	var loaded_supplies = SuppliesData.get_supplies()
	for supply_data in loaded_supplies.values():
		add_supply(supply_data)
#	print(">>>>>>>", supply_items,"<<<<<<<<<<", supply_slots)


func initiate() -> void:
	var supplyitems = get_tree().get_nodes_in_group('supplyitem')
	for supplyitem in supplyitems:
		supplyitem.initiate()


func add_item_to_inventory(supply: Control) -> bool:
	var supply_grid_pos = supply.global_position / grid_size
	var slot_id: Vector2 = supply_grid_pos - global_position / grid_size
	var slot_size: Vector2 = supply.dimension
	
	var max_supply_grid_pos: Vector2 = supply_grid_pos + slot_size - Vector2(1, 1)
	var min_slot_bounds: Vector2 = global_position / grid_size - Vector2(1, 1)
	var max_slot_bounds: Vector2 = min_slot_bounds + grid_dimension
	
	if supply_grid_pos.x < min_slot_bounds.x or max_supply_grid_pos.x > max_slot_bounds.x:
		return false

	if supply_grid_pos.y < min_slot_bounds.y or max_supply_grid_pos.y > max_slot_bounds.y:
		return false
#	print(slot_id, slot_size, supply_grid_pos, max_supply_grid_pos, min_slot_bounds, max_slot_bounds)
		
	if supply_items.has(supply.uuid):
		remove_item_in_inventory_slot(supply, parse_vector(supply_items[supply.uuid].slot_id))
	print(slot_size)
	for y_ctr in range(slot_size.y):
		for x_ctr in range(slot_size.x):
			supply_slots[Vector2(slot_id.x + x_ctr, slot_id.y + y_ctr)] = supply.uuid
	supply.slot_id = slot_id
	supply_items[supply.uuid] = supply.get_data()
#	print(supply_items)
#	print(supply_slots)
	return true


func remove_item_in_inventory_slot(supply: Control, existing_id: Vector2, drop:bool=false):
	var slot_size: Vector2 = supply.dimension

	for y_Ctr in range(slot_size.y):
		for x_Ctr in range(slot_size.x):
			if supply_slots.has(Vector2(existing_id.x + x_Ctr, existing_id.y + y_Ctr)):
				supply_slots.erase(Vector2(existing_id.x + x_Ctr, existing_id.y + y_Ctr))
	supply_items.erase(supply.uuid)
	if drop:
		var dropped_supply = load(ingame_path + supply.supply_code + '.tscn').instantiate()
		dropped_supply.global_position = get_parent().global_position
		get_tree().get_root().add_child(dropped_supply)


func check_if_item_can_fit(x: int, y: int, m: Vector2) -> bool:
	for gx in range(x, m.x):
		for gy in range(y, m.y):
			if supply_slots.keys().has(Vector2(gx, gy)):
				return false
	return true


func add_new_item_to_inventory(data: Dictionary) -> bool:
	# Note: need supply_code, supply_dimension
	for dy in range(grid_dimension.y):
		for dx in range(grid_dimension.x):
			if Vector2(dx, dy) in supply_slots.keys():
				continue
			var m = Vector2(dx + data.dimension.x, dy + data.dimension.y)
			if m.x > grid_dimension.x or m.y > grid_dimension.y:
				continue
			var can_fit = check_if_item_can_fit(
				dx, dy, m
			)
			if can_fit:
				data['slot_id'] = {'x': dx, 'y': dy}
				add_supply(data)
				return true
	return false


func parse_vector(dict: Dictionary) -> Vector2:
	return Vector2(dict.x, dict.y)


func parse_dict(dict: Vector2) -> Dictionary:
	return {'x': dict.x, 'y': dict.y}
