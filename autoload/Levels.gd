extends Node

static var meta: Array = []
static var id_to_level: Dictionary = {}


var key_to_template = {
  "animals": preload("res://scenes/animals.tscn"),
  "shapes": preload("res://scenes/geometric.tscn")
}

static func _init():
    load_meta()

static func load_meta():
    var file := FileAccess.open("res://resources/levels.json", FileAccess.READ)
    if file:
        var content = file.get_as_text()
        var result = JSON.parse_string(content)
        if result is Array:
            meta = result
            for level in meta:
                if level.has("id"):
                    id_to_level[int(level["id"])] = level
        else:
            push_error("cards.json does not contain an array")
    else:
        push_error("Could not open cards.json")
