@tool
extends Control

@export var supply_code: = 'Box'
@export var grid_slot: = Vector2.ZERO
@export var supply_img: Texture2D = preload("res://addons/supplies/resources/grid.png") :
	set (value):
		supply_img = _set_image(value)
@export var dimension: Vector2 = Vector2(32, 32):
	set (value):
		dimension = _set_dimension(value)

var uuid: String
var isready: bool = false


func _ready() -> void:
	isready = true


func put_as_supply() -> void:
	SuppliesData.put_supply(
		{
			'uuid': uuid,
			'supply_code': supply_code,
			'grid_slot': grid_slot
		}
	)


func load_info(data: Dictionary) -> void:
	if data['uuid']:
		uuid = data['uuid']
		supply_code = data['supply_code']
		grid_slot = data['grid_slot']


func _set_image(value: Texture2D) -> Texture2D:
	if isready:
		$Item.texture = value
	return value


func _set_dimension(value: Vector2) -> Vector2:
	if isready:
		$Item/Area/Boundary.set_position(
			Vector2(value.x/2, value.y/2)
		)
		$Item/Area/Boundary.shape.set_size(
			Vector2(value.x, value.y)
		)
	return value
