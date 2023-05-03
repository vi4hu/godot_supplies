extends Sprite2D

@export var supply_code: = 'supply_item'
@export var dimension: Vector2 = Vector2(1, 1)


func _ready():
	$Area.connect('mouse_entered', add)


func _data() -> Dictionary:
	return {
		'supply_code': supply_code,
		'dimension': {'x': dimension.x, 'y': dimension.y}
	}


func get_data() -> Dictionary:
	return _data()


func add() -> void:
	var res = get_tree().get_first_node_in_group('supplygrid').add_new_item_to_inventory(get_data())
	if res:
		call_deferred('queue_free')
