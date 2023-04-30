@tool
extends Area2D

@onready var grid: Sprite2D = $Grid
@onready var collision: CollisionShape2D = $Collision
@onready var bg: ColorRect = $BG

@export var grid_dimension : Vector2 = Vector2(4, 4) :
	set (value):
		grid_dimension = _handle_grid_size(value)

const grid_size : Vector2 = Vector2(32, 32)
var is_ready: bool = false
var supply_slots: Dictionary
var supply_items: Dictionary

func _ready() -> void:
	is_ready = true
	_setup()
	fill_supplies()
	initiate()


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
	bg.set_color(Color(0.3, 0.3, 0.3))
	bg.set_position(Vector2.ZERO)
	bg.set_size(Vector2((grid_size.x * value.x), (grid_size.y * value.y)))


func _handle_grid_size(value: Vector2) -> Vector2:
	if is_ready:
		_setup_collision(value)
		_set_bg(value)
		_setup_grid(value)
	return value


func fill_supplies() -> void:
	print(SuppliesData.get_supplies())


func initiate() -> void:
	var supplyitems = get_tree().get_nodes_in_group('supplyitem')
	for supplyitem in supplyitems:
#		connect('area_entered', supplyitem.inside_inventory)
#		connect('area_exited', supplyitem.outside_inventory)
		supplyitem.initiate()


func add_item_to_inventory(supply: Control) -> bool:
	var supply_grid_pos = supply.global_position / grid_size
	var slot_id: Vector2 = supply_grid_pos - global_position / grid_size
	var slot_size: Vector2 = supply.size / grid_size
	
	var max_supply_grid_pos: Vector2 = supply_grid_pos + slot_size - Vector2(1, 1)
	var min_slot_bounds: Vector2 = global_position / grid_size - Vector2(1, 1)
	var max_slot_bounds: Vector2 = min_slot_bounds + grid_dimension
	
	if supply_grid_pos.x < min_slot_bounds.x or max_supply_grid_pos.x > max_slot_bounds.x:
		return false

	if supply_grid_pos.y < min_slot_bounds.y or max_supply_grid_pos.y > max_slot_bounds.y:
		return false
#	print(slot_id, slot_size, supply_grid_pos, max_supply_grid_pos, min_slot_bounds, max_slot_bounds)
		
	if supply_items.has(supply):
		remove_item_in_inventory_slot(supply, supply_items[supply])

	for y_ctr in range(slot_size.y):
		for x_ctr in range(slot_size.x):
			supply_slots[Vector2(slot_id.x + x_ctr, slot_id.y + y_ctr)] = supply

	supply_items[supply] = slot_id
	return true


func remove_item_in_inventory_slot(supply: Control, existing_id: Vector2):
	var slot_size: Vector2 = supply.size / grid_size

	for y_Ctr in range(slot_size.y):
		for x_Ctr in range(slot_size.x):
			if supply_slots.has(Vector2(existing_id.x + x_Ctr, existing_id.y + y_Ctr)):
				supply_slots.erase(Vector2(existing_id.x + x_Ctr, existing_id.y + y_Ctr))
