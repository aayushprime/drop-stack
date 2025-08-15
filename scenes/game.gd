extends Control

var shapes = {}

@onready var drop_from = $Game/DropFrom
@onready var discard_area = $Game/DiscardArea/DropArea

@onready var line = $Line
@onready var line_label = $Line/Label

@onready var star_nodes = [
    $TopBar/ProgressBar/Star,
    $TopBar/ProgressBar/Star3,
    $TopBar/ProgressBar/Star2
]

var line_initial_position: Vector2

var turn: int = 1
var current_shape: RigidBody2D = null
var game_over: bool = false

var is_dragging: bool = false
var drag_start_position: Vector2 = Vector2.ZERO
const DRAG_THRESHOLD = 10.0

# variables I need
var target = 2
var level = 1

var winner_scene = preload("res://scenes/winner.tscn")
var shapes_template: PackedScene = preload("res://scenes/animals.tscn")

var level_reached = 0

var objects_used := 0
var stars_earned := 0
var stars_displayed := 0

func _ready() -> void:
    get_tree().current_scene = self
    line_initial_position = line.global_position
    $Game/Tip.text = "Reach " + str(target) + "m to win"

    $UI/Container/Left.pressed.connect(func():
        if not current_shape or game_over:
            return
        if current_shape.freeze:
            current_shape.global_position.x = clamp(current_shape.global_position.x - 10, 100, 620)
    )
    $UI/Container/Right.pressed.connect(func():
        if not current_shape or game_over:
            return
        if current_shape.freeze:
            current_shape.global_position.x = clamp(current_shape.global_position.x + 10, 100, 620)
    )
    $UI/Container/Drop.pressed.connect(func():
        if not current_shape:
            return
        is_dragging = false
        current_shape.freeze = false
        current_shape.sleeping_state_changed.connect(_on_physics_settle)
        $UI/Container/Drop.disabled = true
    )
    $UI/Container/Rotate.pressed.connect(func():
        if not current_shape or game_over:
            return
        if current_shape.freeze:
            current_shape.rotation_degrees += 15
    )

    var scene_instance = shapes_template.instantiate()
    for child in scene_instance.get_children():
        shapes[child.name] = child

    discard_area.body_entered.connect(_on_discard_area_body_entered)

    $TopBar/Settings.pressed.connect(func():
        var pause_scene = preload("res://scenes/pause.tscn").instantiate()
        pause_scene.level = level
        pause_scene.target = target
        add_child(pause_scene)
    )
    $TopBar/Label.text = "Level " + str(level)

    start_new_turn()


func start_new_turn() -> void:
    objects_used += 1
    spawn_shape()
    $UI/Container/Drop.disabled = false


func spawn_shape() -> void:
    var keys = shapes.keys()
    var random_key = keys[randi() % keys.size()]

    current_shape = shapes[random_key].duplicate()
    current_shape.visible = true
    current_shape.position = drop_from.position

    current_shape.freeze = true
    add_child(current_shape)


func _on_physics_settle() -> void:
    if current_shape.is_sleeping():
        current_shape.sleeping_state_changed.disconnect(_on_physics_settle)

        await get_tree().create_timer(0.5).timeout

        var pixels_per_meter := 100.0
        var highest_meters = get_highest_point(pixels_per_meter)
        level_reached = highest_meters

        var tween = create_tween()
        var line_target_y = line_initial_position.y - (highest_meters * pixels_per_meter)
        tween.tween_property(line, "global_position", Vector2(line_initial_position.x, line_target_y), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
        tween.tween_property(line_label, "text", str(highest_meters) + "m", 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

        check_stars(highest_meters)

        if stars_earned > stars_displayed:
            var gained = stars_earned - stars_displayed
            animate_stars(gained)
            increment_progress_bar(gained)
            stars_displayed = stars_earned

        if highest_meters >= target:
            game_over = true

            var won_popup = preload("res://scenes/level_complete.tscn").instantiate()
            won_popup.stars = stars_earned
            won_popup.level = level
            add_child(won_popup)
            # self.queue_free()
        else:
            start_new_turn()


func _on_discard_area_body_entered(body: Node2D) -> void:
    if game_over:
        return

    if body.is_in_group("shape"):
        game_over = true

        var lost_popup = preload("res://scenes/level_failed.tscn").instantiate()
        lost_popup.level = level
        add_child(lost_popup)


func get_highest_point(pixels_per_meter: float) -> float:
    var highest_y := INF
    var reference_y := line_initial_position.y  # your ground line

    for body in get_tree().get_nodes_in_group("shape"):
        if body is RigidBody2D:
            var col_poly := body.get_node_or_null("CollisionPolygon2D")
            if col_poly:
                var tf = col_poly.global_transform
                for local_point in col_poly.polygon:
                    var world_point: Vector2 = tf * local_point
                    highest_y = min(highest_y, world_point.y)

    var height_in_pixels := reference_y - highest_y
    var height_in_meters := height_in_pixels / pixels_per_meter

    return roundf(height_in_meters * 100) / 100.0


func _unhandled_input(event: InputEvent) -> void:
    if game_over or not current_shape or not current_shape.freeze:
        return

    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            is_dragging = true
            drag_start_position = event.position
        else:
            is_dragging = false

    elif event is InputEventMouseMotion and is_dragging:
        var new_x = clamp(current_shape.global_position.x + event.relative.x, 100, 620)
        current_shape.global_position.x = new_x


func check_stars(highest_meters: float) -> void:
    stars_earned = 0
    if highest_meters >= target:
        stars_earned += 1
    if objects_used >= 3:
        stars_earned += 1
    if objects_used >= 6:
        stars_earned += 1


func animate_stars(gained: int) -> void:
    for i in range(stars_displayed, stars_displayed + gained):
        if i < star_nodes.size():
            var star = star_nodes[i]
            var flying_star = star.duplicate()
            flying_star.disabled = false
            flying_star.texture_normal = preload("res://assets/levels/star.png")
            flying_star.global_position = get_viewport_rect().size / 2
            add_child(flying_star)

            var tween = create_tween()
            tween.tween_property(flying_star, "global_position", star.global_position, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
            tween.tween_callback(Callable(flying_star, "queue_free"))
            tween.tween_callback(func():
                star.disabled = false
            )


func increment_progress_bar(gained: int) -> void:
    var progress_bar = $TopBar/ProgressBar
    var target_value = clamp(progress_bar.value + (33 * gained), 0, progress_bar.max_value)
    var tween = create_tween()
    tween.tween_property(progress_bar, "value", target_value, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
