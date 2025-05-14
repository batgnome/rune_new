extends Node2D  # or CharacterBody2D if you're using physics later

@export var tilemap : TileMap
var path = []  # Full A* path
var path_index = 0
var moving = false
var move_speed = 200  # Speed of step movement (pixels/sec)
var step_target = Vector2.ZERO  # Current tile moving towards
var manager
enum STATE {BUILD,PRE,MOVE,ATTACK}
var CURRENT_STATE = STATE.BUILD
var target
var previous_position = global_position
@export var type : runeItem
var tail = preload("res://scenes/tail.tscn")
var tail_position = []
var tails = []
var maxsize = 2
const TILESIZE = 20
func _process(_delta):
	if CURRENT_STATE == STATE.MOVE:
		print("start")
		get_nearest_rune()	
		await get_tree().create_timer(2.5).timeout  # Wait 1.5 seconds
		walk_path()
		
		
func _ready():
	$Sprite2D.modulate = Color(1, 1, 0.7)    # yellowish
	#tilemap = $ROOT/TileMap
	init()
	add_to_group("enemy_runes")
	if CURRENT_STATE == STATE.MOVE:
		get_nearest_rune()	
		await get_tree().create_timer(2.5).timeout  # Wait 1.5 seconds
		walk_path()
	if type:
		maxsize = type.max_size
	else:
		type = preload("res://runes/eye.tres")
		
func set_tilemap(tilemap_in):
	tilemap = tilemap_in
func init():
	if type:
		$Sprite2D.texture = type.texture
		$Sprite2D.modulate = Color(1, 1, 0.7)    # yellowish
		
func move(pos):
	await get_tree().create_timer(0.4).timeout
	tilemap.astargrid.set_point_solid(tilemap.local_to_map(global_position),false)
	if pos != global_position:
		tail_position.append(global_position)
		tilemap.astargrid.set_point_solid(tilemap.local_to_map(global_position),true)
		if tail_position.size() > maxsize+1:
			tilemap.astargrid.set_point_solid(tilemap.local_to_map(tail_position[0]),false)
			tail_position.pop_front()
		else:
			create_tail()
	update_tails()
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
	
func create_tail():
	var t = tail.instantiate()
	t.set_texture(type.tail_texture)
	t.top_level = true
	t.add_to_group("enemy_runes")
	tails.append(t)
	add_child(t)			
	
func update_tails():
	for i in tail_position.size():
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

func _draw():
	update_path()
	pass

func pos_tran(pos):
	return Vector2i(floor(pos.x/TILESIZE),floor(pos.y/TILESIZE))
	
	
func update_path():
	if target:
		var this_path = tilemap.get_rune_path(pos_tran(position),pos_tran(target.position))
		path = this_path
		$Line2D.global_position = Vector2(0,0)
		$Line2D.points = PackedVector2Array(this_path)

func _unhandled_input(event):
	if event.is_action_pressed("left"):
		walk_path()
