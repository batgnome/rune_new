extends Node2D

@onready var enemies = get_children()
var current_enem
var parent
func _ready():
	parent = get_parent()
	current_enem = await select_playing_enemy()
func _process(_delta):
	
	if is_instance_valid(current_enem) and current_enem:
		match current_enem.CURRENT_STATE:
			current_enem.STATE.MOVE:
				if not current_enem.playing:
					current_enem.take_turn()
			current_enem.STATE.ATTACK:
				current_enem.active = false
		if current_enem.CURRENT_STATE==current_enem.STATE.INACTIVE:
			current_enem = await select_playing_enemy()
	else:
		current_enem = await select_playing_enemy()
		

		
func select_playing_enemy():
	print("some selected")
	await wait(3)
	var closest_enem = 10000
	var enem = null
	for e in enemies:
		if not is_instance_valid(e):
			continue
		if e.CURRENT_STATE == e.STATE.WAITING:
			
			var dist = e.get_nearest_rune()[0]
			if dist < closest_enem:
				closest_enem = dist
				enem = e
	if is_instance_valid(enem):
		enem.CURRENT_STATE = enem.STATE.MOVE
	return enem

func wait(seconds):
	await get_tree().create_timer(seconds).timeout
