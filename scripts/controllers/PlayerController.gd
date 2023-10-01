extends Node2D

const CAMERA_LOOK_MAX_DISTANCE: float = 150.0
const CAMERA_LOOK_MAX_AT_DISTANCE: float = 1500.0
const BRAKING_MOUSE_DISTANCE_MAX: float = 50.0

@export var camera_look_distance_curve: Curve

@onready var _better_camera: Camera2D = get_tree().get_first_node_in_group("better_camera")
@onready var _ship: Node2D = %Ship

var _in_safe_radius: bool = true
var _safe_radius_time_to_lose: float = GameConstants.SAFE_RADIUS_LOSE_TIME

func _enter_safe_radius() -> void:
  _in_safe_radius = true
  _safe_radius_time_to_lose = GameConstants.SAFE_RADIUS_LOSE_TIME
  Store.set_state("player_safe", true)
  
func _exit_safe_radius() -> void:
  _in_safe_radius = false
  Store.set_state("player_safe", false)

func _on_ship_modules_changed() -> void:
  Store.set_state("mass", _ship._mass)

func _physics_process(_delta):
  var _look_direction: Vector2 = (get_global_mouse_position() - _ship.global_position).normalized()
  var _look_distance: float = camera_look_distance_curve.sample(_ship.global_position.distance_to(get_global_mouse_position()) / CAMERA_LOOK_MAX_AT_DISTANCE) * CAMERA_LOOK_MAX_DISTANCE

  _better_camera.set_target_position(_ship.global_position + (_look_direction * _look_distance))

  if _ship.global_position.distance_to(Vector2.ZERO) > GameConstants.SAFE_RADIUS && _in_safe_radius:
    _exit_safe_radius()

  if !_in_safe_radius && _ship.global_position.distance_to(Vector2.ZERO) <= GameConstants.SAFE_RADIUS:
    _enter_safe_radius()

func _process(delta) -> void:
  if _ship.global_position.distance_to(get_global_mouse_position()) <= BRAKING_MOUSE_DISTANCE_MAX:
    _ship.set_braking(true)
  else:
    _ship.set_braking(false)
    _ship.move_target = get_global_mouse_position()

  if !_in_safe_radius:
    _safe_radius_time_to_lose -= delta

    if _safe_radius_time_to_lose <= 0.0:
      _ship.damage(_ship._integrity)

  %PID.text = "%s" % _ship.pid_output

func _ready():
  _ship.modules_changed.connect(_on_ship_modules_changed)
