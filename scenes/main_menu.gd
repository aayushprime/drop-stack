extends Control

var coop_scene: PackedScene = preload("res://scenes/coop.tscn")
var level_scene: PackedScene = preload("res://scenes/levels.tscn")

var animal_templates : PackedScene = preload("res://scenes/animals.tscn")
var geometric_templates: PackedScene = preload("res://scenes/geometric.tscn")

func _ready() -> void:

  DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)


  $Menu/Levels.pressed.connect(func():
    $Menu.visible = false

    var next_scene = level_scene.instantiate()

    get_tree().root.add_child(next_scene)
    queue_free()
  )
  $Menu/PlayAnimals.pressed.connect(func():
    $Menu.visible = false

    var next_scene = coop_scene.instantiate()
    next_scene.shapes_template = animal_templates

    get_tree().root.add_child(next_scene)
    queue_free()
  )
  $Menu/PlayGeometric.pressed.connect(func():
    $Menu.visible = false

    var next_scene = coop_scene.instantiate()
    next_scene.shapes_template = geometric_templates

    get_tree().root.add_child(next_scene)
    queue_free()
  )
  $Menu/Quit.pressed.connect(func():
    get_tree().quit()
  )
  if OS.has_feature("web"):
      $Menu/Quit.visible = false
  
