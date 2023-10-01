extends Node2D

# Enemies
const ENEMY_BASIC_KAMIKAZE: Dictionary = {
  "points": 1,
  "scene": preload("res://actors/enemies/BasicKamikaze.tscn"),
}
const ENEMY_BASIC_PROJECTILE: Dictionary = {
  "points": 3,
  "scene": preload("res://actors/enemies/BasicProjectile.tscn"),
}
const ENEMY_BEEFY_KAMIKAZE: Dictionary = {
  "points": 5,
  "scene": preload("res://actors/enemies/BeefyKamikaze.tscn"),
}
const ENEMY_ELITE_KAMIKAZE: Dictionary = {
  "points": 15,
  "scene": preload("res://actors/enemies/EliteKamikaze.tscn"),
}
const ENEMY_QUICK_KAMIKAZE: Dictionary = {
  "points": 10,
  "scene": preload("res://actors/enemies/QuickKamikaze.tscn"),
}
const ENEMY_GATLING_PROJECTILE: Dictionary = {
  "points": 15,
  "scene": preload("res://actors/enemies/QuickKamikaze.tscn"),
}
const ENEMY_HEAVY_CANNON_PROJECTILE: Dictionary = {
  "points": 20,
  "scene": preload("res://actors/enemies/QuickKamikaze.tscn"),
}
const ENEMY_BOSS_1: Dictionary = {
  "points": 200,
  "scene": preload("res://actors/enemies/Boss1.tscn"),
}

const ENEMY_SCENES: Dictionary = {
  0: [
    ENEMY_BASIC_KAMIKAZE,
  ],
  1: [
    ENEMY_BASIC_KAMIKAZE,
  ],
  2: [
    ENEMY_BASIC_KAMIKAZE,
    ENEMY_BASIC_PROJECTILE,
  ],
  3: [
    ENEMY_BASIC_KAMIKAZE,
    ENEMY_BEEFY_KAMIKAZE,
    ENEMY_BASIC_PROJECTILE,
  ],
  4: [
    ENEMY_QUICK_KAMIKAZE,
    ENEMY_BEEFY_KAMIKAZE,
    ENEMY_BASIC_PROJECTILE,
  ],
  5: [
    ENEMY_QUICK_KAMIKAZE,
    ENEMY_BEEFY_KAMIKAZE,
    ENEMY_BASIC_PROJECTILE,
    ENEMY_ELITE_KAMIKAZE,
  ],
  6: [
    ENEMY_QUICK_KAMIKAZE,
    ENEMY_BEEFY_KAMIKAZE,
    ENEMY_BASIC_PROJECTILE,
    ENEMY_ELITE_KAMIKAZE,
  ],
  7: [
    ENEMY_QUICK_KAMIKAZE,
    ENEMY_BEEFY_KAMIKAZE,
    ENEMY_BASIC_PROJECTILE,
    ENEMY_ELITE_KAMIKAZE,
    ENEMY_GATLING_PROJECTILE,
  ],
  8: [
    ENEMY_QUICK_KAMIKAZE,
    ENEMY_BEEFY_KAMIKAZE,
    ENEMY_BASIC_PROJECTILE,
    ENEMY_ELITE_KAMIKAZE,
  ],
  9: [
    ENEMY_QUICK_KAMIKAZE,
    ENEMY_BEEFY_KAMIKAZE,
    ENEMY_BASIC_PROJECTILE,
    ENEMY_ELITE_KAMIKAZE,
    ENEMY_HEAVY_CANNON_PROJECTILE,
  ],
  10: [
    ENEMY_BOSS_1,
  ],
}
const MAX_WAVE: int = 10
const POINTS_PER_WAVE: int = 10
const POINTS_PER_WAVE_SCALAR: float = 1.5

@export var spawn_interval: float

@onready var _player_ship: Node2D = %Player.get_child(0)

var _player_dead: bool = false
var _points_remaining_in_wave: int = POINTS_PER_WAVE
var _remaining_enemies: int = 0.0
var _time_to_spawn: float = 0.0
var _upgrading: bool = false
var _wave: int = 9

func _on_enemy_ship_died() -> void:
  _remaining_enemies -= 1
  
  if _remaining_enemies == 0 && _points_remaining_in_wave <= 0:
    if _wave == MAX_WAVE:
      pass
    else:
      _wave += 1
      _points_remaining_in_wave = POINTS_PER_WAVE * (_wave * POINTS_PER_WAVE_SCALAR)
      Store.set_state("wave", _wave + 1)
      Store.set_state("game", GameConstants.GAME_UPGRADING)
      _upgrading = true
      ViewController.set_client_view(ViewController.CLIENT_VIEWS.UPGRADE)

func _on_player_ship_died() -> void:
  _player_dead = true

func _on_store_next_wave() -> void:
  _upgrading = false
  Store.set_state("game", GameConstants.GAME_IN_PROGRESS)  

func _process(delta) -> void:
  if !_player_dead && !_upgrading:
    _time_to_spawn -= delta

    if _time_to_spawn <= 0.0 && _points_remaining_in_wave > 0:
      var _new_enemy_dictionary: Dictionary = ENEMY_SCENES[_wave].pick_random()
      var _new_enemy: Node2D = _new_enemy_dictionary["scene"].instantiate()

      _new_enemy.get_child(0).died.connect(_on_enemy_ship_died)
      _new_enemy.global_position = Vector2.from_angle(randf_range(-PI, PI)) * randf_range(500.0, 1000.0) + _player_ship.global_position
      $"../".add_child(_new_enemy)

      _points_remaining_in_wave -= _new_enemy_dictionary["points"]
      _time_to_spawn = spawn_interval
      _remaining_enemies += 1

func _ready() -> void:
  Store.next_wave.connect(_on_store_next_wave)
  _player_ship.died.connect(_on_player_ship_died)
