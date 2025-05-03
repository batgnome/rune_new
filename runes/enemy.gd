extends Node2D  # or CharacterBody2D if you're using physics later

var tilemap
var path = []  # Full A* path
var path_index = 0
var moving = false
var move_speed = 200  # Speed of step movement (pixels/sec)
var step_target = Vector2.ZERO  # Current tile moving towards
var manager
enum STATE {PRE,MOVE,ATTACK}
var target
var previous_position = global_position
func _ready():
	add_to_group("enemy_runes")

	tilemap = $"../../../TileMap"
	$Line2D.global_position = Vector2(0,0)
	var tile_pos = Vector2i(floor(position.x),floor(position.y))
	print(tile_pos)
	tilemap.start = tile_pos
	get_nearest_rune()
	await get_tree().create_timer(2.5).timeout  # Wait 1.5 seconds
	walk_path()


		
func move(pos):
	await get_tree().create_timer(0.4).timeout
	tilemap.astargrid.set_point_solid(tilemap.local_to_map(global_position),false)
	global_position = pos
	tilemap.astargrid.set_point_solid(tilemap.local_to_map(global_position),true)
	tilemap.queue_redraw()

func walk_path():
	get_nearest_rune()
	var raw_path = tilemap.get_rune_path(
		pos_tran(global_position),
		pos_tran(target.global_position)
	)
	
	if raw_path.size() > 2:
		await move(raw_path[1])
		walk_path()
	
func get_nearest_rune():
	var shortest_path = 10000
	var current_path = 0
	manager = get_parent().get_parent()
	for i in manager.get_child(0).get_children():
		current_path = tilemap.get_rune_path(tilemap.local_to_map(position),tilemap.local_to_map(i.position)).size()
		if current_path < shortest_path:
			target = i
			shortest_path = current_path
			queue_redraw()
	
func _draw():
	update_path()

func pos_tran(pos):
	return Vector2i(floor(pos.x/20),floor(pos.y/20))
	
	
func update_path():
	if target:
		var this_path = tilemap.get_rune_path(pos_tran(position),pos_tran(target.position))
		path = this_path
		$Line2D.global_position = Vector2(0,0)
		$Line2D.points = PackedVector2Array(this_path)

func _unhandled_input(event):
	if event.is_action_pressed("left"):
		walk_path()
