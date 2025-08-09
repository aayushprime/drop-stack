extends Node

# Dictionary to hold data in memory
var data: Dictionary = {}

# Path to save file
const SAVE_PATH := "user://local_storage.save"

func _ready():
    load_data()

func set_item(key: String, value):
    data[key] = value
    save_data()

func get_item(key: String, default = null):
    return data.get(key, default)

func remove_item(key: String):
    data.erase(key)
    save_data()

func clear():
    data.clear()
    save_data()

func save_data():
    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    file.store_var(data)
    file.close()

func load_data():
    if FileAccess.file_exists(SAVE_PATH):
        var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
        data = file.get_var()
        file.close()
    else:
        data = {}

# func _init():
#     load_data()
#     print("Loaded data on init:", data)
