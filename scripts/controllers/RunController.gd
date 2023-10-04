extends Node2D

@onready var _player: Node2D = %Player.get_child(0)

func _draw():
  draw_arc(Vector2.ZERO, GameConstants.SAFE_RADIUS, 0.0, 2.0 * PI, 128, Color.SKY_BLUE, 8.0, true)

func _on_player_died() -> void:
  await get_tree().create_timer(2).timeout

  Store.end_game()
  queue_free()

func _on_store_state_changed(state_key, substate) -> void:
  match state_key:
    "game":
      match substate:
        GameConstants.GAME_OVER:
          queue_free()

func _ready():
  Store.state_changed.connect(_on_store_state_changed)
  _player.died.connect(_on_player_died)
  (func(): Store.set_state("game", GameConstants.GAME_IN_PROGRESS)).call_deferred()
