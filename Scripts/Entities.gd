extends Node2D

@onready var enemies = get_children()
var current_enem
func _ready():
	current_enem = select_playing_enemy()
	
func _process(delta):
	if current_enem:
		match current_enem.CURRENT_STATE:
			current_enem.STATE.MOVE:
				current_enem.walk_path()
func select_playing_enemy():
	var closest_enem = 10000
	for e in enemies:
		if e.active:
			if e.get_nearest_rune() < closest_enem:
				closest_enem = e.get_nearest_rune()
				return e
	return null

