extends Control

signal sold(module: ModuleData)

var module: ModuleData

@onready var _sell_button: Button = %Sell
@onready var _module_name_label: Label = %Name
@onready var _module_weight_label: Label = %Mass
@onready var _module_description_label: Label = %Description
@onready var _module_integrity_label: Label = %Integrity

func _on_sell_pressed() -> void:
  sold.emit(module)
  Store.set_state("scrap", Store.state["scrap"] + (module.cost * 0.5))

func _on_state_changed(_state_key, _substate):
  pass

func _ready():
  Store.state_changed.connect(self._on_state_changed)
  _sell_button.pressed.connect(_on_sell_pressed)

  _sell_button.text = "Sell (+%s Scrap)" % (module.cost * 0.5)
  _module_name_label.text = module.name
  _module_weight_label.text = "Mass: %s" % module.weight
  _module_description_label.text = module.description
  _module_integrity_label.text = "Integrity: %s" % module.structural_integrity
