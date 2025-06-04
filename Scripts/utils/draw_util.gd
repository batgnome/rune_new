extends Node2D

const TILESIZE = 20
@onready var parent = get_parent()
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#parent = get_parent()
	queue_redraw()
	


func _draw():
	if parent.is_in_group("pl_runes"):
		if parent.current_state != parent.STATE.BUILD and parent.manager.rune == parent:
			
			if parent.current_state == parent.STATE.ATTACK and not parent.attack_done:
				var color = Color8(255,150,0,65)
				draw_circle(Vector2.ZERO, parent.attack_range*20,color)
				render_markers(parent.attack_marker_texture, parent.attack_range)
			elif parent.current_state == parent.STATE.MOVE and parent.current_moves > 0:
				draw_movement_arrows()
				render_markers(parent.marker_texture, parent.current_moves)
				
	elif parent.is_in_group("enemy_runes"):
		if parent.CURRENT_STATE == parent.STATE.ATTACK and not parent.fired:
			#render_markers(parent.attack_marker_texture, parent.type.attack_range)
				var color = Color8(255,150,0,65)
				draw_circle(Vector2.ZERO, parent.type.attack_range*20,color)
			
func draw_movement_arrows():
	var rect = Rect2(Vector2(-10, -30), Vector2(TILESIZE, TILESIZE))
	var dirs = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
	var angles = [-90, 90, 0, 180]
	for i in range(4):
		var dir = dirs[i]
		if Utils.can_move_to(parent.position + TILESIZE * dir,parent.tilemap):
			draw_set_transform(Vector2.ZERO, deg_to_rad(angles[i]), Vector2.ONE)
			draw_texture_rect(parent.arrow_marker_texture, rect, false)
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
	
func render_markers(mark, size):
	for x in range(-size, size + 1):
		for z in range(-size, size + 1):
			if abs(z) + abs(x) <= size:
				var target_pos = Vector2(parent.position.x + TILESIZE * x, parent.position.y + TILESIZE * z)
				if Utils.can_move_to(target_pos,parent.tilemap):
					var rect = Rect2(Vector2(parent.TILE_OFFSET.x + TILESIZE * x, parent.TILE_OFFSET.y + TILESIZE * z), Vector2(TILESIZE, TILESIZE))
					draw_texture_rect(mark, rect, false)

