extends Control

# This script's only job is to detect input and emit signals.

signal tapped
signal dragged(mouse_motion_event: InputEventMouseMotion)

var is_mouse_down: bool = false
var has_dragged_this_click: bool = false

func _gui_input(event: InputEvent):
  # Handle Mouse Button Press
  if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
    is_mouse_down = true
    has_dragged_this_click = false
    # We don't need to do anything else here.

  # Handle Mouse Movement (Drag)
  elif event is InputEventMouseMotion and is_mouse_down:
    has_dragged_this_click = true
    dragged.emit(event) # Just tell the world we dragged.

  # Handle Mouse Button Release (Tap)
  elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
    if is_mouse_down:
      if not has_dragged_this_click:
        tapped.emit() # If no drag happened, it was a tap.
      
      is_mouse_down = false
