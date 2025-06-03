extends Node

var current_level: int = 0
var levels_unlocked: int = 1  # Start with level 0 unlocked

func save():
	var data = {
		"current_level": current_level,
		"levels_unlocked": levels_unlocked
	}
	var file = FileAccess.open("user://save.dat", FileAccess.WRITE)
	file.store_var(data)
	file.close()

func load():
	if FileAccess.file_exists("user://save.dat"):
		var file = FileAccess.open("user://save.dat", FileAccess.READ)
		var data = file.get_var()
		file.close()
		current_level = data.get("current_level", 0)
		levels_unlocked = data.get("levels_unlocked", 1)
		

