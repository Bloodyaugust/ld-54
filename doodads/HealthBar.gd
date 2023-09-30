extends Control

@onready var _parent: Node2D = get_parent()
@onready var _health_bar_green: ColorRect = %HealthBarGreen
@onready var _starting_offset_from_parent: Vector2 = global_position - _parent.global_position

var _health_scale: float = 1.0
var _starting_bar_width: float

func set_health(health_scale: float) -> void:
  _health_scale = health_scale
  _health_bar_green.custom_minimum_size = Vector2(_starting_bar_width * _health_scale, _health_bar_green.custom_minimum_size.y)

func _process(_delta) -> void:
  rotation = -_parent.global_rotation
  global_position = _parent.global_position + _starting_offset_from_parent

func _ready() -> void:
  _starting_bar_width = _health_bar_green.custom_minimum_size.x
