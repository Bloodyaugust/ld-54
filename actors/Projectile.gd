extends Node2D

@export var damage: float = 1.0
@export var speed: float = 1.0
@export var time_to_live: float = 1.0

var target: Vector2 = Vector2.ZERO
var team: int = 1

@onready var _area2D: Area2D = %Area2D

var _damage_done: bool = false
var _time_alive: float = 0.0

func get_damage() -> float:
  if _damage_done:
    return 0

  _damage_done = true
  return damage

func _on_area2D_area_entered(entering_area: Area2D) -> void:
  if entering_area.get_parent().has_signal("died"):
    queue_free()

func _physics_process(delta) -> void:
  _time_alive += delta

  if _time_alive >= time_to_live:
    queue_free()
  else:
    global_translate(Vector2(speed * delta * cos(global_rotation), speed * delta * sin(global_rotation)))

func _ready():
  _area2D.area_entered.connect(_on_area2D_area_entered)
  
  if team == 1:
    _area2D.set_collision_layer_value(1, true)
    _area2D.set_collision_layer_value(2, false)
    _area2D.set_collision_mask_value(1, false)
    _area2D.set_collision_mask_value(2, true)
  else:
    _area2D.set_collision_layer_value(1, false)
    _area2D.set_collision_layer_value(2, true)
    _area2D.set_collision_mask_value(1, true)
    _area2D.set_collision_mask_value(2, false)

  look_at(target)
