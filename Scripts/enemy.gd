extends Node2D  

@export var tilemap : TileMap
@export var type : runeItem

enum STATE {BUILD,INACTIVE,WAITING,MOVE,ATTACK}
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
var speed = 3
var playing = false
var active  = true
var attack_marker_texture = preload("res://assets/runes/att_marker.png")
var attack_collision_scene = preload("res://scenes/attack_collision.tscn")
@onready var clock = $Timer
var rune_name
var fired = false
var bullet = preload("res://scenes/bullet.tscn")
var swipe = preload("res://scenes/swipe.tscn")

func _process(_delta):
	$timer_display.set_value((clock.get_time_left()/clock.wait_time)*100)
	match CURRENT_STATE:
		STATE.BUILD:
			%state.text = "BUILD"
		STATE.INACTIVE:
			%state.text = "INACTIVE"
		STATE.MOVE:
			fired = false
			%state.text = "MOVE"
		STATE.ATTACK:
			%state.text = "ATTACK"
		STATE.WAITING:
			%state.text = "WAITING"
	if CURRENT_STATE == STATE.ATTACK:
		if get_nearest_rune()[1] <= type.attack_range:
			shoot()
			set_state(STATE.INACTIVE)
			fired = true
		$draw_layer.queue_redraw()
		

func _ready():
	add_to_group("enemy_runes")
	add_to_group("damagable")
	
	if not tilemap:
		tilemap = get_parent().get_parent().get_child(0)
		tilemap.astargrid.set_point_solid(tilemap.local_to_map(global_position),true)
	init()
	
func init():
	if type:
		$Sprite2D.texture = type.texture
		if $Sprite2D.texture.get_size() > Vector2.ONE *20:
			$Sprite2D.scale = (Vector2.ONE * 20.0/type.tile_size)*0.7
		else:
			$Sprite2D.scale = Vector2.ONE*0.7
		maxsize = type.max_size
		max_range = type.speed
		current_range = type.speed
		rune_name = type.name
	else: 
		type = preload("res://runes/eye.tres")
		init()


func fire(rotate_bullet):
	var b = null
	if type.attack_range == 1:
		b = swipe.instantiate()
	else:
		b = bullet.instantiate()
	b.add_to_group("enemy_runes")
	b.enemy = true
	b.speed = 300  
	b.damage = type.attack_power
	b.pos = global_position #- TILE_OFFSET
	b.max_dist = type.attack_range*20
	b.rota = rotate_bullet  # This sets the direction the bullet travels
	b.owner_group = "enemy_runes"
	b.target_group = "pl_runes"
	get_tree().root.get_child(0).add_child(b)
	
func shoot():
	if is_instance_valid(target):
		var rotate_bullet = get_angle_to(target.position)
		wait(0.4)
		fire(rotate_bullet)
		
func take_turn():
	get_nearest_rune()
	playing = true
	set_state(STATE.MOVE)
	
	await walk_path()
	await start_attack()

func set_state(state):
	print(state)
	CURRENT_STATE = state
		
func delete_segments(size):
	for s in size:
		if tails.size() > 0 :
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
				
	
func start_attack():
	shoot()
	$Timer.start(speed)
	active = false
	playing = false
	CURRENT_STATE = STATE.INACTIVE
	$draw_layer.queue_redraw()


func walk_path():
	#print("walk this way")
	var moved = 0
	while current_range > 0 and is_instance_valid(target):
		# Recalculate path each step to follow player movement
		#print("astar points", tilemap.astargrid)
		var raw_path = tilemap.get_rune_path(
			pos_tran(position),
			pos_tran(target.position)
		)
		#print(pos_tran(position)," enem ",pos_tran(target.position))
		if raw_path.size() < 3 or get_nearest_rune()[1] <= type.attack_range-1:
			
			start_attack()
			break  # No path or already at target

		# Move to next step
		var next_pos = raw_path[1]
		move(next_pos)
		current_range -= 1
		moved += 1

		await wait(0.4)  # Allow animation to play

	# After walking is done, trigger attack state
	if moved > 0:
		$draw_layer.queue_redraw()
		
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
		
func can_move_to(world_position: Vector2) -> bool:
	var map_pos = tilemap.local_to_map(world_position)
	var cell_data = tilemap.get_cell_tile_data(0, map_pos)
	return cell_data and cell_data.get_custom_data("walkable") == true
	
func create_tail():
	var t = tail.instantiate()
	t.set_texture(type.tail_texture,type.get_tile_size())
	t.top_level = true
	t.add_to_group("enemy_runes")
	t.add_index(tails.size())
	tails.append(t)
	add_child(t)			
	
func update_tails():
	for i in tail_position.size():
		if is_instance_valid(tails[i]):
			tails[i].position = tail_position[i]
			
func get_nearest_rune():
	
	var shortest_path = 10000
	var distance_to = 10000
	var current_path = 0
	var candidates = get_tree().get_nodes_in_group("pl_runes")
	
	for i in candidates:
		if !i.is_in_group("bullets"):
			if i and tilemap:
				current_path = tilemap.get_rune_path(
					tilemap.local_to_map(position),
					tilemap.local_to_map(i.position)
				).size()
				
				if current_path < shortest_path:
					target = i
					shortest_path = current_path
					$draw_layer.queue_redraw()
				distance_to = floor(position.distance_to(target.position)/20)
	return [shortest_path,distance_to]
	
func _on_timer_timeout():
	fired = false
	set_state(STATE.WAITING)
	#CURRENT_STATE = STATE.WAITING
	current_range = max_range
	
	active = true
	
#utils
func pos_tran(pos):
	return Vector2i(floor(pos.x/TILESIZE),floor(pos.y/TILESIZE))
	
func wait(seconds):
	await get_tree().create_timer(seconds).timeout

##debugs
func _draw():
	_debug_draw_astar_line()
	#if CURRENT_STATE == STATE.ATTACK:
		#render_markers(attack_marker_texture, type.attack_range)
		
		
	
func _debug_draw_astar_line():
	print(target)
	if target:
		print("astar points", tilemap.astargrid.get_id_path(pos_tran(position),target.position))
		var this_path = tilemap.get_rune_path(pos_tran(position),pos_tran(target.position))
		path = this_path
		$Line2D.global_position = Vector2(0,0)
		$Line2D.points = PackedVector2Array(this_path)




