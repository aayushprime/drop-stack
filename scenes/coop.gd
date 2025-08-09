extends Control
class_name Root

var shapes_template: PackedScene = null

var winner_scene = preload("res://scenes/winner.tscn")

var shapes = {}

@onready var turn_label = $Game/TurnLabel
@onready var drop_from = $Game/DropFrom
@onready var drop_button = $Game/DropButton
@onready var discard_area = $Game/DiscardArea/DropArea

var turn: int = 1
var current_shape: RigidBody2D = null
var game_over: bool = false

var is_dragging: bool = false
var drag_start_position: Vector2 = Vector2.ZERO
const DRAG_THRESHOLD = 10.0

func _on_input_catcher_tapped():
    if not current_shape or game_over: return
    if current_shape.freeze:
        current_shape.rotation_degrees += 15

# This function runs when the InputCatcher tells us a drag happened.
func _on_input_catcher_dragged(event: InputEventMouseMotion):
    if not current_shape or game_over: return
    if current_shape.freeze:
        var new_x = clamp(event.global_position.x, 100, 620)
        current_shape.global_position.x = new_x


func _ready() -> void:
  $Game/InputCatcher.tapped.connect(_on_input_catcher_tapped)
  $Game/InputCatcher.dragged.connect(_on_input_catcher_dragged)


  var scene_instance = shapes_template.instantiate()
  for child in scene_instance.get_children():
    shapes[child.name] = child

  discard_area.body_entered.connect(_on_discard_area_body_entered)
  drop_button.pressed.connect(_on_drop_button_pressed)

  start_new_turn()


func start_new_turn() -> void:
  turn_label.text = "Player %s's Turn" % turn
  drop_button.show()
  drop_button.disabled = false
  spawn_shape()


func spawn_shape() -> void:
  var keys = shapes.keys()
  var random_key = keys[randi() % keys.size()]

  current_shape = shapes[random_key].duplicate()
  current_shape.visible = true
  current_shape.position = drop_from.position

  current_shape.freeze = true
  add_child(current_shape)


func _on_drop_button_pressed() -> void:
  if not current_shape:
    return

  is_dragging = false
  drop_button.hide()

  current_shape.freeze = false
  current_shape.sleeping_state_changed.connect(_on_animal_settled)


func _on_animal_settled() -> void:

  if current_shape.is_sleeping():
    current_shape.sleeping_state_changed.disconnect(_on_animal_settled)

    await get_tree().create_timer(0.5).timeout

    if not game_over:
      turn = 3 - turn
      start_new_turn()



func _on_discard_area_body_entered(body: Node2D) -> void:
  if game_over:
    return

  if body.is_in_group("shape"):
    game_over = true
    var winner = 3 - turn
    print("Animal fell! Player %s loses. Player %s wins!" % [turn, winner])

    await get_tree().create_timer(1.0).timeout

    var winner_scene_instance = winner_scene.instantiate()
    get_tree().root.add_child(winner_scene_instance)
    winner_scene_instance.set_winner_info(winner)
    self.queue_free()
