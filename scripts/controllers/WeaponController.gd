extends Node2D

var data: ModuleData
var team: int = 1

@onready var _parent_ship: Node2D = get_parent()

var _time_to_reload: float = 0.0

func _fire() -> void:
  var _new_projectile: Node2D = data.projectile_scene.instantiate()
  
  _new_projectile.global_position = _parent_ship.global_position
  _new_projectile.target = Vector2.ZERO
  _new_projectile.team = team
  
  $"/root".add_child(_new_projectile)
  _time_to_reload = data.reload_time

func _process(delta) -> void:
  _time_to_reload -= delta
  
  if _time_to_reload <= 0.0:
    _fire()
