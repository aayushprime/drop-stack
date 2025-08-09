extends Panel

var level: int = 0

func _ready():
  var target = Levels.id_to_level[level]["target"]
  var template = Levels.id_to_level[level]["template"]

  $Panel/Label.text = "Level " + str(level)
  $Panel/Objective.text = "Reach " + str(target) + "m to win"

  $Panel/Retry.pressed.connect(func():
      var game_scene = load("res://scenes/game.tscn").instantiate()
      game_scene.shapes_template = Levels.key_to_template[template]
      game_scene.level = level
      game_scene.target = target
      get_tree().root.add_child(game_scene)
      get_parent().queue_free()
  )
  $Panel/Back.pressed.connect(func():
    get_tree().change_scene_to_file("res://scenes/levels.tscn")
    queue_free()
  )
