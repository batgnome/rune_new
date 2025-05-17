extends Node2D

@onready var enemies = get_children()
var current_enem
func _ready():
	current_enem = await select_playing_enemy()
	
func _process(delta):
	if current_enem:
		match current_enem.CURRENT_STATE:
			current_enem.STATE.MOVE:
				current_enem.walk_path()
			current_enem.STATE.ATTACK:
				pass
		if !current_enem.active:
			current_enem = await select_playing_enemy()
	else:
		current_enem = await select_playing_enemy()
		
func select_playing_enemy():
	await wait(3)
	var closest_enem = 10000
	var enem = null
	for e in enemies:
		if e.active:
			if e.get_nearest_rune() < closest_enem:
				closest_enem = e.get_nearest_rune()
				enem = e
	return enem

func wait(seconds):
	await get_tree().create_timer(seconds).timeout
