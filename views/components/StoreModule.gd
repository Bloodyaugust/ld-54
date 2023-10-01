extends Control

signal bought(module: ModuleData)

var module: ModuleData

@onready var _buy_button: Button = %Buy
@onready var _module_name_label: Label = %Name
@onready var _module_weight_label: Label = %Weight
@onready var _module_description_label: Label = %Description
@onready var _module_integrity_label: Label = %Integrity

func _evaluate_button_enabled() -> void:
  _buy_button.disabled = Store.state["scrap"] < module.cost || Store.state["mass"] + module.weight > GameConstants.MASS_MAX

func _on_buy_pressed() -> void:
  bought.emit(module)
  Store.set_state("scrap", Store.state["scrap"] - module.cost)

func _on_state_changed(state_key, substate):
  match state_key:
    "mass", "scrap":
      _evaluate_button_enabled()

func _ready():
  Store.state_changed.connect(self._on_state_changed)
  _buy_button.pressed.connect(_on_buy_pressed)

  _buy_button.text = "Buy (-%s Scrap)" % module.cost
  _module_name_label.text = module.name
  _module_weight_label.text = "Mass: %s" % module.weight
  _module_description_label.text = module.description
  _module_integrity_label.text = "Integrity: %s" % module.structural_integrity
