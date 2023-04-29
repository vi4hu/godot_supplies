extends Node

signal supplies_loaded(supplies)

var _supplies : Resource = load("res://addons/supplies/db/supplies.gd").new()

const _save_path: String = "user://supplies.tres"


func _exit_tree() -> void:
	_save_supplies()


func _ready() -> void:
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	_init_()


func _init_() -> void:
	if not ResourceLoader.exists(_save_path):
		ResourceSaver.save(_supplies, _save_path)
	else:
		_load_supplies()


func _save_supplies() -> void:
	ResourceSaver.save(_supplies, _save_path)


func _load_supplies() -> void:
	if ResourceLoader.exists(_save_path):
		var loaded_supplies = load(_save_path)
		if loaded_supplies is Resource:
			_supplies = loaded_supplies
			emit_signal('supplies_loaded', loaded_supplies)


func _drop_supplies() -> void:
	_supplies.data.clear()
	_save_supplies()


func save() -> void:
	_save_supplies()


func put_supply(new_supply: Dictionary) -> void:
	_supplies.data.push(new_supply)


func take_out_supply(key: String) -> Dictionary:
	if _supplies.data.has(key):
		var supply = _supplies.data[key]
		_supplies.data.erase(key)
		return supply
	return {}


func get_supplies() -> Dictionary:
	return _supplies.data
