extends Node2D

signal died
signal modules_changed

const INTEGRITY_MIN: float = 1.0
const KP: float = 0.65
const KI: float = 0.35
const KD: float = 0.20
const THRUST_MIN: float = 1.0
const THRUST_MAX_SPEED_MODIFIER: float = 0.5
const THRUST_TO_ANGULAR_SCALAR: float = 2.75
const MASS_MIN: float = 1.0
const WEAPON_CONTROLLER_SCRIPT: Script = preload("res://scripts/controllers/WeaponController.gd")

@export var starting_modules: Array[ModuleData]
@export var team: int = 1
@export var scrap: float = 1.0

var move_target: Vector2 = Vector2.ZERO
var pid_output: float = 0.0

@onready var _area2D: Area2D = %Area2D
@onready var _health_bar: Control = %HealthBar
@onready var _weapons_container: Node2D = %Weapons

var _angular_velocity: float = 0.0
var _braking: bool = false
var _destroyed: bool = false
var _integral: float = 0.0
var _integrity: float = INTEGRITY_MIN
var _integrity_max: float = INTEGRITY_MIN
var _thrust: float = THRUST_MIN
var _mass: float = MASS_MIN
var _modules: Array[ModuleData] = []
var _previous_error: float = 0.0
var _setpoint: float = 0.0
var _velocity: Vector2 = Vector2.ZERO

func add_module(module: ModuleData) -> void:
  _modules.append(module)

  _integrity_max += module.structural_integrity
  _integrity += module.structural_integrity
  _mass += module.weight

  match module.type:
    GameConstants.MODULE_TYPES.ENGINE:
      _thrust += module.thrust
    GameConstants.MODULE_TYPES.WEAPON:
      var _new_weapon = WEAPON_CONTROLLER_SCRIPT.new()
      _new_weapon.data = module
      _new_weapon.team = team

      _weapons_container.add_child(_new_weapon)

  modules_changed.emit()

func damage(amount: float) -> void:
  _integrity -= clamp(amount, 0.0, INF)
  _health_bar.set_health(_integrity / _integrity_max)

func get_damage() -> float:
  return _integrity
  
func get_destroyed() -> float:
  return _destroyed

func remove_module(module: ModuleData) -> void:
  _integrity_max -= module.structural_integrity
  _integrity = clamp(_integrity - module.structural_integrity, 1.0, _integrity_max)
  _mass -= module.weight

  match module.type:
    GameConstants.MODULE_TYPES.ENGINE:
      _thrust -= module.thrust
    GameConstants.MODULE_TYPES.WEAPON:
      var _weapons: Array[Node] = _weapons_container.get_children()

      for _weapon in _weapons:
        if _weapon.data == module:
          _weapon.queue_free()
          break

  _modules.erase(module)
  modules_changed.emit()

func set_braking(braking: bool) -> void:
  _braking = braking

func _on_area2D_area_entered(entering_area: Area2D) -> void:
  var _entering_area_parent: Node2D = entering_area.get_parent()

  damage(_entering_area_parent.get_damage())

func _on_modules_changed() -> void:
  _health_bar.set_health(_integrity / _integrity_max)  

func _physics_process(delta) -> void:
  if !_destroyed && Store.state["game"] == GameConstants.GAME_IN_PROGRESS:
    if _braking:
      var _new_velocity_length: float = max(_velocity.length() - (_thrust * delta), 0.0)

      _velocity = _velocity.normalized() * _new_velocity_length

      if abs(_angular_velocity) <= _thrust * THRUST_TO_ANGULAR_SCALAR * delta:
        _angular_velocity = 0.0
      else:
        _angular_velocity += (_thrust * THRUST_TO_ANGULAR_SCALAR * delta) * (signf(_angular_velocity) * -1)
    else:
      _setpoint = global_position.angle_to_point(move_target)

      # Calculate the error
      var _error: float = wrapf(_setpoint - global_rotation, -PI, PI)

      # Proportional term
      var _p: float = KP * _error

      # Integral term
      _integral += _error * delta
      var _i: float = KI * _integral

      # Derivative term
      var _d: float = KD * (_error - _previous_error) / delta

      # Control output
      pid_output = clamp(_p + _i + _d, -1.0, 1.0)
      _angular_velocity += (_thrust * THRUST_TO_ANGULAR_SCALAR) * pid_output * delta
      _previous_error = _error

      var _velocity_this_frame: float = delta * _thrust
      _velocity += Vector2(_velocity_this_frame * cos(global_rotation), _velocity_this_frame * sin(global_rotation))

      var _new_velocity_length: float = min(_velocity.length(), _thrust * THRUST_MAX_SPEED_MODIFIER)
      _velocity = _velocity.normalized() * _new_velocity_length

  if Store.state["game"] == GameConstants.GAME_IN_PROGRESS:
    global_rotation += _angular_velocity * delta
    global_translate(_velocity)

func _process(_delta) -> void:
  if _integrity <= 0.0 && !_destroyed:
    _destroyed = true
    _area2D.monitorable = false
    _area2D.monitoring = false
    died.emit()
    modulate = Color.BLACK
    _health_bar.visible = false
    Store.set_state("kills", Store.state.kills + 1)
    Store.set_state("scrap", Store.state.scrap + scrap)

func _ready() -> void:
  modules_changed.connect(_on_modules_changed)
  _area2D.area_entered.connect(_on_area2D_area_entered)

  for _module in starting_modules:
    add_module(_module)
