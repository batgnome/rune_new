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
var speed = 3
var playing = false
var active  = true
var attack_marker_texture = preload("res://assets/runes/att_marker.png")
var attack_collision_scene = preload("res://scenes/attack_collision.tscn")
@onready var clock = $Timer
var attack_done = true
var rune_name
var bullet = preload("res://scenes/bullet.tscn")
func _process(_delta):
	$timer_display.set_value((clock.get_time_left()/clock.wait_time)*100)
	match CURRENT_STATE:
		STATE.BUILD:
			%state.text = "BUILD"
			%att_area.get_child(0).get_child(0).disabled = true
		STATE.PRE:
			%state.text = "PRE"
			%att_area.get_child(0).get_child(0).disabled = true
		STATE.MOVE:
			%state.text = "MOVE"
			%att_area.get_child(0).get_child(0).disabled = true
		STATE.ATTACK:
			%state.text = "ATTACK"
	if CURRENT_STATE == STATE.ATTACK:
		%att_area.get_child(0).get_child(0).disabled = false
		if $Area2D.has_overlapping_areas():
			#print("here attack bullet 1")
			area_attack($Area2D.get_overlapping_areas())
		$draw_layer.queue_redraw()
		

func _ready():
	add_to_group("enemy_runes")
	add_to_group("damagable")
	print(get_groups())
	if not tilemap:
		tilemap = get_parent().get_parent().get_child(0)
	init()
	
func init():
	%att_area.get_child(0).get_child(0).disabled = true
	if type:
		$Sprite2D.texture = type.texture
		maxsize = type.max_size
		max_range = type.speed
		current_range = type.speed
		init_attack_collision_shapes(type.attack_range)
		rune_name = type.name
	else: 
		type = preload("res://runes/eye.tres")
		init()


func fire(rotate):

	var b = bullet.instantiate()
	b.add_to_group("enemy_runes")
	b.enemy = true
	b.speed = 30  # or however fast you want — 3 is probably too slow unless it's pixels/frame
	b.damage = type.attack_power
	b.pos = global_position #- TILE_OFFSET
	b.max_dist = type.attack_range*20
	b.rota = rotate  # This sets the direction the bullet travels
	b.owner_group = "enemy_runes"
	b.target_group = "pl_runes"
	get_tree().root.get_child(0).add_child(b)
	
func take_turn():
	playing = true
	CURRENT_STATE = STATE.MOVE
	await walk_path()
	await start_attack()


	
func init_attack_collision_shapes(size):
	var circle = CircleShape2D.new()
	circle.radius = size * 20

	$att_area/att_bullet/CollisionShape2D.shape = circle



func set_attack(yesno):
	for a in %att_area.get_children():
		a.set_pickable(yesno)
		
						

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
	$Timer.start(speed)
	fired = false
	active = false
	playing = false
	CURRENT_STATE = STATE.ATTACK
	attack_done = false
	$draw_layer.queue_redraw()


				
#Move functions

func walk_path():
	var moved = 0
	while current_range > 0 and is_instance_valid(target):
		# Recalculate path each step to follow player movement
		var raw_path = tilemap.get_rune_path(
			pos_tran(global_position),
			pos_tran(target.global_position)
		)
		if raw_path.size() < 3:
			#print("started")
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
	t.set_texture(type.tail_texture)
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
				$draw_layer.queue_redraw()
	return shortest_path
	
func _on_timer_timeout():
	fired = false
	CURRENT_STATE = STATE.MOVE
	current_range = max_range
	active = true
	
#utils
func pos_tran(pos):
	return Vector2i(floor(pos.x/TILESIZE),floor(pos.y/TILESIZE))
	
func wait(seconds):
	await get_tree().create_timer(seconds).timeout

##debugs
#func _draw():
	##_debug_draw_astar_line()
	#if CURRENT_STATE == STATE.ATTACK and not attack_done:
		#render_markers(attack_marker_texture, type.attack_range)
		
		
	
func _debug_draw_astar_line():
	if target:
		var this_path = tilemap.get_rune_path(pos_tran(position),pos_tran(target.position))
		path = this_path
		$Line2D.global_position = Vector2(0,0)
		$Line2D.points = PackedVector2Array(this_path)

var fired = false
func _on_att_bullet_area_entered(area):
	area_attack(area)

func area_attack(area):
	if area is Array:
		for a in area:
			#print(a.get_parent().get_parent())
			if a.get_parent().get_parent().is_in_group("pl_runes"):
				area = a.get_parent()
				break
		
	var rune = area.get_parent()
	if rune.is_in_group("pl_runes") and not fired:
			fired = true
			var rotate = get_angle_to(rune.position)
			attack_done = true
			wait(0.4)
			fire(rotate)
