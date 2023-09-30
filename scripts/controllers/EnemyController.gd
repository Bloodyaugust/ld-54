extends Node2D

@onready var _player: Node2D = get_tree().get_first_node_in_group("player")
@onready var _ship: Node2D = %Ship

var _player_dead: bool = false

func _on_player_died() -> void:
  _player_dead = true
  _ship.move_target = global_position

func _process(_delta) -> void:
  if !_player_dead:
    _ship.move_target = _player.global_position

func _ready() -> void:
  _player.died.connect(_on_player_died)
