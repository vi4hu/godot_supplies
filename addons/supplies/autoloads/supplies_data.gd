extends Node

signal supplies_loaded(supplies)

var _supplies: Dictionary = {}

const _save_path: String = "user://supplies.dat"


#func _exit_tree() -> void:
#	_save_supplies()


func _ready() -> void:
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	_init_()
#	drop()


func _init_() -> void:
	if not FileAccess.file_exists(_save_path):
		_save_supplies()
	else:
		_load_supplies()


func _save_supplies() -> void:
	var file = FileAccess.open(_save_path, FileAccess.WRITE)
	file.store_string(str(_supplies))


func _load_supplies() -> void:
	var file = FileAccess.open(_save_path, FileAccess.READ)
	print(file.get_as_text())
	_supplies = JSON.parse_string(file.get_as_text())


func _drop_supplies() -> void:
	_supplies.clear()
#	print(_supplies)
	_save_supplies()


func save(data: Dictionary) -> void:
	_supplies = data
	_save_supplies()


func drop() -> void:
	_drop_supplies()

#func put_supply(new_supply: Dictionary) -> void:
#	_supplies.push(new_supply)


func take_out_supply(key: String) -> Dictionary:
	if _supplies.has(key):
		var supply = _supplies[key]
		_supplies.erase(key)
		return supply
	return {}


func get_supplies() -> Dictionary:
	return _supplies
