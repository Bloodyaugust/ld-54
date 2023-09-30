extends Node2D

const THRUST_MIN: float = 1.0
const MASS_MAX: float = 100.0

@export var starting_modules: Array[ModuleData]

var move_target: Vector2 = Vector2.ZERO

var _thrust: float
var _modules: Array[ModuleData] = []
var _velocity: Vector2 = Vector2.ZERO

func add_module(module: ModuleData) -> void:
  _modules.append(module)

  match module.type:
    GameConstants.MODULE_TYPES.ENGINE:
      _thrust += module.thrust

func _physics_process(delta) -> void:
  look_at(move_target)

  var _velocity_this_frame: float = delta * _thrust
  _velocity += Vector2(_velocity_this_frame * cos(global_rotation), _velocity_this_frame * sin(global_rotation))
  
  var _new_velocity_length: float = min(_velocity.length(), _thrust)
  print("velocity: ", _velocity.length())
  _velocity = _velocity.normalized() * _new_velocity_length

  global_translate(_velocity)

func _ready() -> void:
  _thrust = THRUST_MIN

  for _module in starting_modules:
    add_module(_module)
