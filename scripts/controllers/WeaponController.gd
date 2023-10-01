extends Node2D

var data: ModuleData
var team: int = 1

@onready var _parent_ship: Node2D = $"../../"

var _range_shape: CircleShape2D
var _target = null
var _time_to_reload: float = 0.0

func _draw() -> void:
  if !_parent_ship.get_destroyed():
    draw_arc(Vector2.ZERO, data.radius, 0.0, 2*PI, 32, Color.GREEN)

func _fire() -> void:
  var _new_projectile: Node2D = data.projectile_scene.instantiate()

  _new_projectile.global_position = _parent_ship.global_position
  _new_projectile.target = _target.global_position if GDUtil.reference_safe(_target) else Vector2.from_angle(global_rotation) + global_position
  _new_projectile.team = team

  $"../../../../".add_child(_new_projectile)
  _time_to_reload = data.reload_time

func _on_target_died() -> void:
  _target.died.disconnect(_on_target_died)
  _target = null

func _physics_process(_delta) -> void:
  if !_parent_ship.get_destroyed():
    if !GDUtil.reference_safe(_target):
      var _physics_shape_query_params: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
      
      _physics_shape_query_params.collide_with_areas = true
      _physics_shape_query_params.shape = _range_shape
      _physics_shape_query_params.transform = Transform2D(0.0, global_position)
      var _parent_area2D: Area2D = _parent_ship._area2D
      _physics_shape_query_params.collision_mask = _parent_area2D.collision_mask
      
      var _collisions: Array[Dictionary] = get_world_2d().direct_space_state.intersect_shape(_physics_shape_query_params)
      for _collision in _collisions:
        if _collision.collider.get_parent().has_signal("died") && !_collision.collider.get_parent().get_destroyed():
          _target = _collision.collider.get_parent()
          _target.died.connect(_on_target_died)
          break
    elif global_position.distance_to(_target.global_position) > data.radius:
      _target.died.disconnect(_on_target_died)
      _target = null

func _process(delta) -> void:
  if !_parent_ship.get_destroyed() && Store.state["game"] == GameConstants.GAME_IN_PROGRESS:
    _time_to_reload -= delta

    if _time_to_reload <= 0.0:
      _fire()

  if Store.state.debug:
    queue_redraw()

func _ready() -> void:
  _range_shape = CircleShape2D.new()
  _range_shape.radius = data.radius
