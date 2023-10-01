extends Control

const MODULES: Array[ModuleData] = [
  preload("res://data/modules/basic_armor.tres"),
  preload("res://data/modules/basic_cannon.tres"),
  preload("res://data/modules/basic_engine.tres"),
]
const SHIP_MODULE_COMPONENT: PackedScene = preload("res://views/components/ShipModule.tscn")
const STORE_MODULE_COMPONENT: PackedScene = preload("res://views/components/StoreModule.tscn")

@onready var _next_wave: Button = %NextWave
@onready var _ship_integrity_label: Label = %ShipIntegrity
@onready var _ship_weight_label: Label = %ShipWeight
@onready var _ship_thrust_label: Label = %ShipThrust
@onready var _ship_weapons_label: Label = %ShipWeapons
@onready var _ship_modules_list: VBoxContainer = %ShipModulesList
@onready var _store_modules_list: VBoxContainer = %StoreModulesList

var _player_ship

func _on_next_wave_pressed() -> void:
  ViewController.set_client_view(ViewController.CLIENT_VIEWS.NONE)
  Store.next_wave.emit()

func _on_store_module_bought(module: ModuleData) -> void:
  _player_ship.add_module(module)

func _on_player_modules_changed() -> void:
  GDUtil.queue_free_children(_ship_modules_list)

  _ship_integrity_label.text = "Integrity: %.1f" % _player_ship._integrity_max
  _ship_weight_label.text = "Mass: %.1f" % _player_ship._mass
  _ship_thrust_label.text = "Thrust: %.1f" % _player_ship._thrust
  _ship_weapons_label.text = "Weapons: %s" % _player_ship._modules.filter(func(module: ModuleData): return module.type == GameConstants.MODULE_TYPES.WEAPON).size()

func _on_state_changed(state_key, substate):
  match state_key:
    "game":
      match substate:
        GameConstants.GAME_IN_PROGRESS:
          if !GDUtil.reference_safe(_player_ship):
            _player_ship = get_tree().get_first_node_in_group("player")
            _player_ship.modules_changed.connect(_on_player_modules_changed)
            _on_player_modules_changed()
        GameConstants.GAME_OVER:
          _player_ship = null

func _ready():
  Store.state_changed.connect(self._on_state_changed)
  _next_wave.pressed.connect(_on_next_wave_pressed)

  ViewController.register_view(ViewController.CLIENT_VIEWS.UPGRADE, self)

  for _module in MODULES:
    var _new_store_module_component: Control = STORE_MODULE_COMPONENT.instantiate()

    _new_store_module_component.bought.connect(_on_store_module_bought)
    _new_store_module_component.module = _module
    _store_modules_list.add_child(_new_store_module_component)
