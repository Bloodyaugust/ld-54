extends Node

const PersistentStore := preload("res://scripts/classes/PersistentStore.gd")
const RUN_SCENE: PackedScene = preload("res://scenes/run.tscn")

signal state_changed(state_key, substate)

var persistent_store:Resource
var state: Dictionary = {
  "client_view": ViewController.CLIENT_VIEWS.NONE,
  "game": "",
  "debug": true,
  "kills": 0,
  "player_safe": true,
  "wave": 1,
 }

func end_game() -> void:
  ViewController.set_client_view(ViewController.CLIENT_VIEWS.MAIN_MENU, ViewController.TRANSITION_TYPES.FADE)
  set_state("game", GameConstants.GAME_OVER)
  set_state("player_safe", true)

func start_game() -> void:
  ViewController.set_client_view(ViewController.CLIENT_VIEWS.NONE)
  set_state("game", GameConstants.GAME_STARTING)
  set_state("kills", 0)
  set_state("wave", 1)
  $"/root".add_child(RUN_SCENE.instantiate())

func save_persistent_store() -> void:
  if ResourceSaver.save(persistent_store, ClientConstants.CLIENT_PERSISTENT_STORE_PATH) != OK:
    print("Failed to save persistent store")

func set_state(state_key: String, new_state) -> void:
  state[state_key] = new_state
  emit_signal("state_changed", state_key, state[state_key])
  print("State changed: ", state_key, " -> ", state[state_key])
  
func _initialize():
  set_state("game", GameConstants.GAME_OVER)

  if (state.debug):
    (func(): ViewController.set_client_view(ViewController.CLIENT_VIEWS.MAIN_MENU, ViewController.TRANSITION_TYPES.FADE)).call_deferred()
  else:
    (func(): ViewController.set_client_view(ViewController.CLIENT_VIEWS.SPLASH, ViewController.TRANSITION_TYPES.FADE)).call_deferred()

func _ready():
  if FileAccess.file_exists(ClientConstants.CLIENT_PERSISTENT_STORE_PATH):
    persistent_store = load(ClientConstants.CLIENT_PERSISTENT_STORE_PATH)

  if !persistent_store:
    persistent_store = PersistentStore.new()
    save_persistent_store()

  call_deferred("_initialize")
