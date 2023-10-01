extends Node2D

const ENEMY_SCENES: Dictionary = {
  0: [
    {
      "points": 1,
      "scene": preload("res://actors/enemies/BasicKamikaze.tscn"),
    },
  ],
}
const POINTS_PER_WAVE: int = 10

@export var spawn_interval: float

@onready var _player_ship: Node2D = %Player.get_child(0)

var _player_dead: bool = false
var _points_remaining_in_wave: int = POINTS_PER_WAVE
var _time_to_spawn: float = 0.0
var _wave: int = 0

func _on_player_ship_died() -> void:
  _player_dead = true

func _process(delta) -> void:
  if !_player_dead:
    _time_to_spawn -= delta

    if _time_to_spawn <= 0.0:
      var _new_enemy_dictionary: Node2D = ENEMY_SCENES[_wave].pick_random()
      var _new_enemy: Node2D = _new_enemy_dictionary.scene.instantiate()

      _new_enemy.global_position = Vector2.from_angle(randf_range(-PI, PI)) * randf_range(500.0, 1000.0) + _player_ship.global_position
      $"../".add_child(_new_enemy)

      _time_to_spawn = spawn_interval

func _ready() -> void:
  _player_ship.died.connect(_on_player_ship_died)
