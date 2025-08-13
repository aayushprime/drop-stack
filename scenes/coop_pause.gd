extends Panel

func _ready():
  $Panel/Continue.pressed.connect(func():
    queue_free()
  )
  $Panel/Quit.pressed.connect(func():
    get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
  )
