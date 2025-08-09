extends Control

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var levels_container: Control = $ScrollContainer/LevelsContainer




func _ready():
  get_tree().current_scene = self
  $Back.pressed.connect(func():
    get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
  )

  var user_data = LocalStorage.get_item("levels", {})

  user_data["0"] = {
    "stars": 0,
    "completed": true
  }


  for id in Levels.id_to_level.keys():
    var level = Levels.id_to_level[id]
    var level_instance = preload("res://scenes/level.tscn").instantiate()
    level_instance.level = level["id"]

    if user_data.has(str(int(id))):
      level_instance.stars = user_data[str(int(id))]["stars"]

    if user_data.has(str(id - 1)):
      level_instance.disabled = false
    else:
      level_instance.disabled = true

    levels_container.add_child(level_instance)
    levels_container.move_child(level_instance, 1)
    level_instance.get_node("Button").pressed.connect(func():
      var level_popup = preload("res://scenes/level_popup.tscn").instantiate()

      level_popup.level = level.id
      level_popup.stars = level_instance.stars

      level_popup.play_level.connect(func(template, level, target):
        var game_scene = preload("res://scenes/game.tscn").instantiate()
        game_scene.shapes_template = Levels.key_to_template[template]
        game_scene.level = level
        game_scene.target = target
        get_tree().root.add_child(game_scene)
        queue_free()
      )

      add_child(level_popup)
    )

  await get_tree().process_frame
  scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value
