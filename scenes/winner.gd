extends Control


@onready var winner_label = $WinnerLabel
@onready var play_again_button = $MainMenu

func _ready():
  play_again_button.pressed.connect(_on_play_again_pressed)

# This is our public setup function. The old scene will call this.
func set_winner_info(player_number: int):
  winner_label.text = "Player %s Wins!" % player_number

func _on_play_again_pressed():
  get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
