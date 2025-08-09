extends Panel

var stars: int = 0
var level: int = 0


signal play_level(template: String, level: int, target: int)

func _ready():
  for i in range(3):
    var star = $Panel/Stars.get_child(i)
    star.disabled = i >= stars

  var target = Levels.id_to_level[level]["target"]
  var template = Levels.id_to_level[level]["template"]
  $Panel/Label.text = "Level " + str(level)
  $Panel/Objective.text = "Reach " + str(target) + "m to win"

  $Panel/Back.pressed.connect(func():
    queue_free()
  )

  $Panel/Play.pressed.connect(func():
    emit_signal("play_level", template, level, target)
    queue_free()
  )
