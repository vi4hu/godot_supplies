@tool
extends Control

@export var supply_code: = 'supply_item'
@export var slot_id: = Vector2.ZERO
@export var supply_img: Texture2D = preload("res://addons/supplies/resources/grid.png") :
	set (value):
		supply_img = _set_image(value)
@export var dimension: Vector2 = Vector2(1, 1):
	set (value):
		dimension = _set_dimension(value)

const item_size: Vector2 = Vector2(32, 32)
const pixel_to_leave: Vector2 = Vector2(2, 2)

var uuid: String
var isready: bool = false
var isinsidegrid: bool = false
var overlapping_supplies: Array = []
var old_position
var selected = false


func _ready() -> void:
	isready = true


func _data() -> Dictionary:
	return {
		'uuid': uuid,
		'supply_code': supply_code,
		'slot_id': {'x': slot_id.x, 'y': slot_id.y},
		'dimension': {'x': dimension.x, 'y': dimension.y}
	}


func _process(delta) -> void:
	if selected:
		global_position = (
			self.get_global_mouse_position() - Vector2(
				item_size.x /2, item_size.y/2
			)
		).snapped(item_size)
	if overlapping_supplies.size() > 0:
		$Item.modulate = Color(0.4, 0, 0)
	else:
		$Item.modulate = Color(0.0, 0.0, 1)


func _set_image(value: Texture2D) -> Texture2D:
	if isready:
		$Item.texture = value
	return value


func _set_dimension(value: Vector2) -> Vector2:
	if isready:
		$Item/Area/Boundary.set_position(
			Vector2((item_size.x * value.x)/2, (item_size.y * value.y)/2)
		)
		$Item/Area/Boundary.shape.set_size(
			Vector2((item_size.x * value.x), (item_size.y * value.y)) - pixel_to_leave
		)
	return value


func initiate(data:Dictionary = {}) -> Dictionary:
	if data:
		load_info(data)
		global_position = slot_id * item_size.x
	else:
#		uuid = Uuid.v4()
		return {}
	if not is_connected('gui_input', hover):
		connect("gui_input", hover)
	if not $Item/Area.is_connected("area_entered", overlapping_with_other_item):
		$Item/Area.connect("area_entered", overlapping_with_other_item)
	if not $Item/Area.is_connected("area_exited", not_overlapping_with_other_item):
		$Item/Area.connect("area_exited", not_overlapping_with_other_item)
	return get_data()


func get_data() -> Dictionary:
	return _data()


func load_info(data: Dictionary) -> void:
	if data.has('uuid'):
		uuid = data.uuid
	else:
		uuid = Uuid.v4()
	supply_code = data.supply_code
	slot_id = Vector2(data.slot_id.x, data.slot_id.y)
	dimension = Vector2(data.dimension.x, data.dimension.y)


func inside_inventory(area: Area2D) -> void:
	isinsidegrid = true


func outside_inventory(area: Area2D) -> void:
	isinsidegrid = false


func hover(event: InputEvent) -> void:
	if event.is_action_pressed("select_item"):
		selected = true
		$Item.set_z_index(1000)
		old_position = global_position
	
	if event.is_action_released("select_item"):
#		print(get_data())
		selected = false
		$Item.set_z_index(1)
		if isinsidegrid: 
			if overlapping_supplies.size() > 0:
				global_position = old_position
			if !get_tree().get_first_node_in_group('supplygrid').add_item_to_inventory(self):
				global_position = old_position
			else:
				pass


func overlapping_with_other_item(area: Area2D) -> void:
	var supply = area.get_parent().get_parent()
	if supply == self:
		return
	
	if area == get_tree().get_first_node_in_group('supplygrid'):
		return
	if supply.is_in_group('supplyitem'):
		overlapping_supplies.append(supply)


func not_overlapping_with_other_item(area: Area2D) -> void:
	var supply = area.get_parent().get_parent()
	if supply == self:
		return
	
	if area == get_tree().get_first_node_in_group('supplygrid'):
		return
		
	overlapping_supplies.erase(supply)
