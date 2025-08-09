extends Panel

var stars: int = 0
var level: int = 0


func _ready():
  var user_data = LocalStorage.get_item("levels", {})
  user_data[str(level)] = {
    "stars": stars,
    "completed": true
  }
  LocalStorage.set_item("levels", user_data)

  for i in range(3):
    var star = $Panel/Stars.get_child(i)
    star.disabled = i >= stars

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
  $Panel/Continue.pressed.connect(func():
    get_tree().change_scene_to_file("res://scenes/levels.tscn")
    queue_free()
  )
