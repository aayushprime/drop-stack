extends Panel

var level: int = 0
var target: int = 45

func _ready():
  $Panel/Continue.pressed.connect(func():
    queue_free()
  )
  $Panel/Quit.pressed.connect(func():
    get_tree().change_scene_to_file("res://scenes/levels.tscn")
  )

  $Panel/Label.text = "Level " + str(level)
  $Panel/Objective.text = "Reach " + str(target) + "m for 3 stars"

