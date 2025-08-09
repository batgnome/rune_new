extends Node2D
var children
var enemy_player
enum STATE {MOVING, ATTACKING, PAUSED}
var current_state
func _ready():
	children = get_children();
	enemy_player = children[0]


func _process(delta):
	if is_instance_valid(enemy_player):
		match current_state:
			STATE.MOVING:
				enemy_player.move()
			STATE.ATTACKING:
				enemy_player.attack()
			STATE.PAUSED:
				pass
	else:
		get_new_enemy_player()		
	
func get_new_enemy_player():
	for enemy in children:
		if enemy.isActive() and enemy.isNearest():
			enemy_player = enemy
