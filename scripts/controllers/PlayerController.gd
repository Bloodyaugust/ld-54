extends Node2D

const CAMERA_LOOK_MAX_DISTANCE: float = 150.0
const CAMERA_LOOK_MAX_AT_DISTANCE: float = 1500.0
const BRAKING_MOUSE_DISTANCE_MAX: float = 50.0

@export var camera_look_distance_curve: Curve

@onready var _better_camera: Camera2D = get_tree().get_first_node_in_group("better_camera")
@onready var _ship: Node2D = %Ship

func _physics_process(_delta):
  var _look_direction: Vector2 = (get_global_mouse_position() - _ship.global_position).normalized()
  var _look_distance: float = camera_look_distance_curve.sample(_ship.global_position.distance_to(get_global_mouse_position()) / CAMERA_LOOK_MAX_AT_DISTANCE) * CAMERA_LOOK_MAX_DISTANCE

  _better_camera.set_target_position(_ship.global_position + (_look_direction * _look_distance))

func _process(_delta) -> void:
  if _ship.global_position.distance_to(get_global_mouse_position()) <= BRAKING_MOUSE_DISTANCE_MAX:
    _ship.set_braking(true)
  else:
    _ship.set_braking(false)
    _ship.move_target = get_global_mouse_position()
    
  %PID.text = "%s" % _ship.pid_output
