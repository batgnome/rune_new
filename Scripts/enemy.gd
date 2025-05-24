extends Node2D  

@export var tilemap : TileMap
@export var type : runeItem

enum STATE {BUILD,PRE,MOVE,ATTACK}
var CURRENT_STATE = STATE.BUILD

var path = []  # Full A* path
var manager
var target

var tail = preload("res://scenes/tail.tscn")
var tail_position = []
var tails = []

var maxsize
var max_range
var current_range

const TILESIZE = 20
const TILE_OFFSET = Vector2(-10, -10)
var speed = 2
var playing = false
var active  = true
var attack_marker_texture = preload("res://assets/runes/att_marker.png")
var attack_collision_scene = preload("res://scenes/attack_collision.tscn")
@onready var clock = $Timer

func _process(_delta):
	$timer_display.set_value((clock.get_time_left()/clock.wait_time)*100)


func _ready():
	if not tilemap:
		tilemap = get_parent().get_parent().get_child(0)
	add_to_group("enemy_runes")
	init()
	print(get_groups())
	
func init():
	if type:
		$Sprite2D.texture = type.texture
		maxsize = type.max_size
		max_range = type.speed
		current_range = type.speed
	else:
		type = preload("res://runes/eye.tres")
		init()

func move(pos):
	
	tilemap.astargrid.set_point_solid(tilemap.local_to_map(global_position),false)
	if pos != global_position:
		tail_position.append(global_position)
		tilemap.astargrid.set_point_solid(tilemap.local_to_map(global_position),true)
		if tail_position.size() > maxsize-1:
			tilemap.astargrid.set_point_solid(tilemap.local_to_map(tail_position[0]),false)
			tail_position.pop_front()
		else:
			create_tail()
	update_tails()
	global_position = pos
	tilemap.astargrid.set_point_solid(tilemap.local_to_map(global_position),true)
	tilemap.queue_redraw()

func take_turn():
	playing = true
	CURRENT_STATE = STATE.MOVE
	await walk_path()
	await start_attack()
	
func start_attack():
	$Timer.start(speed)
	active = false
	playing = false
	CURRENT_STATE = STATE.ATTACK
	queue_redraw()

func walk_path():
	
	get_nearest_rune()
	var raw_path = tilemap.get_rune_path(
		pos_tran(global_position),
		pos_tran(target.global_position)
	)
	if raw_path.size() > 2 and current_range > 0:
		await wait(0.4)
		move(raw_path[1])
		current_range -= 1
		await walk_path()
		#$active.text = name+": not playing"

func render_markers(mark, size):
	for x in range(-size, size + 1):
		for z in range(-size, size + 1):
			if abs(z) + abs(x) <= size:
				var target_pos = Vector2(position.x + TILESIZE * x, position.y + TILESIZE * z)
				if can_move_to(target_pos):
					var rect = Rect2(Vector2(TILE_OFFSET.x + TILESIZE * x, TILE_OFFSET.y + TILESIZE * z), Vector2(TILESIZE, TILESIZE))
					draw_texture_rect(mark, rect, false)

func attack_collision_2(size):
	for child in %att_area.get_children():
		child.queue_free()
	for x in range(-size, size + 1):
		for y in range(-size, size + 1):
			if abs(x) + abs(y) <= size and not (x == 0 and y == 0):
				var tile_center = Vector2(x + TILESIZE * x, y + TILESIZE * y)
				var att = attack_collision_scene.instantiate()
				att.position = tile_center
				att.connect("attack_done", Callable(self, "_attack_done"))
				att.parent = self
				%att_area.add_child(att)
				
func can_move_to(world_position: Vector2) -> bool:
	var map_pos = tilemap.local_to_map(world_position)
	var cell_data = tilemap.get_cell_tile_data(0, map_pos)
	return cell_data and cell_data.get_custom_data("walkable") == true
	
func create_tail():
	var t = tail.instantiate()
	t.set_texture(type.tail_texture)
	t.top_level = true
	t.add_to_group("enemy_runes")
	t.add_index(tails.size())
	tails.append(t)
	add_child(t)			
	
func update_tails():
	for i in tail_position.size():
		if is_instance_valid(tails[i]):
			tails[i].position = tail_position[i] -Vector2(TILESIZE,TILESIZE)/2

func get_nearest_rune():
	var shortest_path = 10000
	var current_path = 0
	var candidates = get_tree().get_nodes_in_group("pl_runes")

	for i in candidates:
		if i and tilemap:
			current_path = tilemap.get_rune_path(
				tilemap.local_to_map(position),
				tilemap.local_to_map(i.position)
			).size()
			
			if current_path < shortest_path:
				target = i
				shortest_path = current_path
				queue_redraw()
	return shortest_path
				

func _on_timer_timeout():
	CURRENT_STATE = STATE.MOVE
	current_range = max_range
	active = true
	
func delete_segments(size):
	for s in size:
		#print("tail size: ",tails.size(),", size: ", size,", s:", s)
		if tails.size() > 0 :
			print(tilemap.local_to_map(tail_position[0]))
			tilemap.astargrid.set_point_solid(tilemap.local_to_map(tail_position[0]),false)
			
			tail_position.remove_at(0)
			if is_instance_valid(tails[0]):
				tails[0].queue_free()
			tails.remove_at(0)
		else:
			tilemap.astargrid.set_point_solid(tilemap.local_to_map(global_position),false)
			queue_free()
		tilemap.queue_redraw()
		await wait(0.2)
				
#utils
func pos_tran(pos):
	return Vector2i(floor(pos.x/TILESIZE),floor(pos.y/TILESIZE))
	
func wait(seconds):
	await get_tree().create_timer(seconds).timeout

#debugs
func _draw():
	#_debug_draw_astar_line()
	if CURRENT_STATE == STATE.ATTACK:
		render_markers(attack_marker_texture, type.attack_range)
	pass
func _debug_draw_astar_line():
	if target:
		var this_path = tilemap.get_rune_path(pos_tran(position),pos_tran(target.position))
		path = this_path
		$Line2D.global_position = Vector2(0,0)
		$Line2D.points = PackedVector2Array(this_path)
