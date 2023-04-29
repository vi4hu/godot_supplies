extends Control

@export var supply_name: = 'something_unique'
@export var grid_position: = Vector2.ZERO


func put_as_supply() -> void:
	SuppliesData.put_supply(
		{
			'supply_name': supply_name,
			'grid_position': grid_position
		}
	)


func load_info(data: Dictionary) -> void:
	supply_name = data['supply_name']
	grid_position = data['grid_position']
