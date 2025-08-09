extends Control

var _disabled = false
var disabled: bool :
  set(value):
    _disabled = value
    $Button/Lock.visible = _disabled
    $"Button/LevelLabel".visible = !_disabled
    $Button.disabled = _disabled
  get:
    return _disabled

var _stars = 0
var stars: int:
  set(value):
    _stars = value
    for i in range(3):
      $Button/Stars.get_child(i).disabled =  i >= _stars
  get:
    return _stars


func tilt(left: bool) -> void:
  $Button.rotation_degrees = -5 if left else 5
  $Button.position += Vector2(-50, 0) if left else Vector2(50, 0)
  $Button/Stars.position += Vector2(-70, 0) if left else Vector2(70, 0)


var level: int = 0

func _ready():
  $"Button/LevelLabel".text = str(level)

  tilt(level % 2 == 0)
