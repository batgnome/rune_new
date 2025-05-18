extends Node2D

@onready var enemies = get_children()
var current_enem
var parent
func _ready():
	parent = get_parent()
	current_enem = await select_playing_enemy()
	
func _process(delta):
	
	if is_instance_valid(current_enem) and current_enem:
		match current_enem.CURRENT_STATE:
			current_enem.STATE.MOVE:
				current_enem.walk_path()
			current_enem.STATE.ATTACK:
				pass
		if not current_enem.active:
			current_enem = await select_playing_enemy()
	else:
		current_enem = await select_playing_enemy()

		
func select_playing_enemy():
	await wait(3)
	var closest_enem = 10000
	var enem = null
	for e in enemies:
		if not is_instance_valid(e):
			continue
		if e.active:
			var dist = e.get_nearest_rune()
			if dist < closest_enem:
				closest_enem = dist
				enem = e
	return enem

func wait(seconds):
	await get_tree().create_timer(seconds).timeout
