extends Node2D

const ENEMY_SCENES: Array[PackedScene] = [
  preload("res://actors/enemies/BasicKamikaze.tscn"),
]

@export var spawn_interval: float

var _time_to_spawn: float = 0.0

func _process(delta) -> void:
  _time_to_spawn -= delta

  if _time_to_spawn <= 0.0:
    var _new_enemy: Node2D = ENEMY_SCENES.pick_random().instantiate()

    _new_enemy.global_position = Vector2(randf_range(500.0, 800.0) * -1 if randf() >= 0.5 else 1, randf_range(500.0, 800.0) * -1 if randf() >= 0.5 else 1)
    $"../".add_child(_new_enemy)

    _time_to_spawn = spawn_interval