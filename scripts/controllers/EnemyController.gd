extends Node2D

@onready var _player: Node2D = get_tree().get_first_node_in_group("player")
@onready var _ship: Node2D = %Ship

func _process(_delta) -> void:
  _ship.move_target = _player.global_position
