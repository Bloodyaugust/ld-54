extends Node2D

@onready var _ship: Node2D = %Ship

func _process(_delta) -> void:
  _ship.move_target = get_global_mouse_position()
