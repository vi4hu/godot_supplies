extends Node

signal supplies_loaded(supplies)

var _supplies: Dictionary # = preload("res://addons/supplies/db/supplies.gd")

const _save_path: String = "user://supplies.dat"


func _exit_tree() -> void:
	_save_supplies()


func _ready() -> void:
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	_init_()


func _init_() -> void:
	if not FileAccess.file_exists(_save_path):
		print(1)
		_save_supplies()
	else:
		_load_supplies()


func _save_supplies() -> void:
	var file = FileAccess.open(_save_path, FileAccess.WRITE)
	file.store_string(str(_supplies))



func _load_supplies() -> void:
	var file = FileAccess.open(_save_path, FileAccess.READ)
	_supplies = JSON.parse_string(file.get_as_text())
	print(_supplies)



func _drop_supplies() -> void:
	_supplies.clear()
	_save_supplies()


func save(data: Dictionary) -> void:
	_supplies = data
	print(_supplies)
	_save_supplies()


#func put_supply(new_supply: Dictionary) -> void:
#	_supplies.data.push(new_supply)


func take_out_supply(key: String) -> Dictionary:
	if _supplies.data.has(key):
		var supply = _supplies.data[key]
		_supplies.data.erase(key)
		return supply
	return {}


func get_supplies() -> Dictionary:
	return _supplies.data
