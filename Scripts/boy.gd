extends CharacterBody2D

@export var move_speed := 1200

var patrol_points: PackedVector2Array = []
var patrol_index := 0
var current_lvl := 0
var lvls: Array[Path2D] = []
var lvl_buttons: Array[Button] = []
var level_scenes = {
	1: "res://Levels/Level_0.tscn",
	2: "res://Levels/Level_1.tscn",
}

func _ready():
	
	if "load" in Global:
		Global.load()
	else:
		print("Global script missing load method!")

	$"../Fade".visible = false
	# Collect paths manually (or dynamically if needed)
	lvls = [null,
		$"../level_1",
		$"../level_2",
		$"../level_3",
		$"../level_4"
	]
	lvl_buttons =[$"../lvl0", $"../lvl1", $"../lvl2", $"../lvl3", $"../lvl4"]
	print(Global.levels_unlocked)
	for i in range(lvl_buttons.size()):
		lvl_buttons[i].disabled = true
	for i in range(Global.levels_unlocked):
		lvl_buttons[i].disabled = false
		
	if Global.current_level >= 1 and Global.current_level < lvl_buttons.size():
		var button_pos = lvl_buttons[Global.current_level-1].global_position
		global_position = button_pos
		current_lvl = Global.current_level-1
		patrol_points.clear()
		
func _physics_process(delta):
	if patrol_points.is_empty():
		velocity = Vector2.ZERO
		return

	var target = patrol_points[patrol_index]
	var to_target = target - global_position

	var distance = to_target.length()
	var direction = to_target.normalized()
	var step = move_speed * delta

	if distance < step:
		# Snap to target to avoid overshoot
		global_position = target
		patrol_index += 1
		if patrol_index >= patrol_points.size():
			patrol_points.clear()
			velocity = Vector2.ZERO
			return
	else:
		velocity = direction * move_speed
		move_and_slide()

func _input(event):
	if event.is_action_pressed("reset_progress"): 
		print("reset")
		Global.current_level = 0
		Global.levels_unlocked = 1 
		Global.save()
func load_patrol_points_from_level(lvl_index: int) -> void:
	if lvl_index >= 0 and lvl_index < lvls.size():
		var path_node = lvls[lvl_index]
		if path_node and path_node is Path2D:
			var local_points = path_node.curve.get_baked_points()
			var global_xform = path_node.get_global_transform()

			patrol_points.clear()
			for point in local_points:
				patrol_points.append(global_xform * point)
		else:
			print("Warning: Invalid Path2D at index", lvl_index)
	else:
		print("Warning: Level index out of bounds:", lvl_index)


func _on_lvl_1_pressed():
	if current_lvl == 1:
		transition_to_level(level_scenes[2])
	else:
		go_to_level(1)

func _on_lvl_2_pressed():
	if current_lvl == 2:
		transition_to_level(level_scenes[1])
	else:
		go_to_level(2)


func _on_lvl_3_pressed():
	go_to_level(3)

func _on_lvl_4_pressed():
	go_to_level(4)


func go_to_level(target_level: int):
	print("Target level:", target_level)
	patrol_points.clear()

	if target_level == current_lvl:
		print("Already at target level.")
		return

	if current_lvl > target_level:
		# Going BACKWARD
		for i in range(current_lvl, target_level, -1):
			if i < lvls.size():
				var path_node = lvls[i]
				if path_node and path_node is Path2D:
					var local_points = path_node.curve.get_baked_points().duplicate()
					local_points.reverse()
					var global_xform = path_node.get_global_transform()
					for point in local_points:
						patrol_points.append(global_xform * point)
				else:
					print("Invalid path at index", i)
			else:
				print("Level index out of bounds:", i)
	else:
		# Going FORWARD
		for i in range(current_lvl+1, target_level+1):
			if i < lvls.size():
				var path_node = lvls[i]
				if path_node and path_node is Path2D:
					var local_points = path_node.curve.get_baked_points()
					var global_xform = path_node.get_global_transform()
					for point in local_points:
						patrol_points.append(global_xform * point)
				else:
					print("Invalid path at index", i)
			else:
				print("Level index out of bounds:", i)

	current_lvl = target_level
	patrol_index = 0


func transition_to_level(level_path: String):
	$"../Fade".visible = true
	$"../Fade".get_child(1).play("fade_out")
	await $"../Fade".get_child(1).animation_finished
	get_tree().change_scene_to_file(level_path)

func _on_lvl_0_pressed():
	if current_lvl == 0:
		
		transition_to_level(level_scenes[1])
	else:
		print("Returning to level 0 from:", current_lvl)
		
		if current_lvl == 0:
			print("Already at the start.")
			return

		patrol_points.clear()

		# Walk backward from current to the *start of level 1*
		for i in range(current_lvl, 0, -1):
			if i < lvls.size() and lvls[i]:
				var path_node = lvls[i]
				if path_node is Path2D:
					var local_points = path_node.curve.get_baked_points().duplicate()
					local_points.reverse()
					var global_xform = path_node.get_global_transform()
					for point in local_points:
						patrol_points.append(global_xform * point)
				else:
					print("Invalid path at index", i)
			else:
				print("Level index out of bounds or null:", i)

		current_lvl = 0
		patrol_index = 0
