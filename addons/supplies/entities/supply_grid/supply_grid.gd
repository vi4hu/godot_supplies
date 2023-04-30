@tool
extends Area2D

@onready var grid: Sprite2D = $Grid
@onready var collision: CollisionShape2D = $Collision
@onready var bg: ColorRect = $BG

@export var grid_size : Vector2 = Vector2(64, 64) :
	set (value):
		grid_size = _handle_grid_size(value)

var is_ready: bool = false


func _ready() -> void:
	is_ready = true
	_setup()
	fill_supplies()


func _setup() -> void:
	_setup_collision(grid_size)
	_set_bg(grid_size)
	_setup_grid(grid_size)


func _setup_grid(_grid_size: Vector2) -> void:
	grid.set_centered(false)
	grid.set_region_enabled(true)
	grid.set_region_rect(Rect2(0, 0, _grid_size.x, _grid_size.y))
	grid.set_texture_repeat(2)


func _setup_collision(_grid_size: Vector2) -> void:
	collision.set_position(
		Vector2(_grid_size.x/2, _grid_size.y/2)
	)
	collision.shape.set_size(
		Vector2(_grid_size.x, _grid_size.y)
	)


func _set_bg(_grid_size: Vector2) -> void:
	bg.set_color(Color(0.3, 0.3, 0.3))
	bg.set_position(Vector2.ZERO)
	bg.set_size(Vector2(_grid_size.x, _grid_size.y))


func _handle_grid_size(value: Vector2) -> Vector2:
	if is_ready:
		_setup_collision(value)
		_set_bg(value)
		_setup_grid(value)
	return value


func fill_supplies() -> void:
	print(SuppliesData.get_supplies())
