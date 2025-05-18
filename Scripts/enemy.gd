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

var maxsize = 2
var max_range = 2
var current_range = 2

const TILESIZE = 20
var speed = 2
var playing = false
var active  = true

@onready var clock = $Timer

func _process(_delta):
	$timer_display.set_value((clock.get_time_left()/clock.wait_time)*100)
	#match CURRENT_STATE:
		#
		#STATE.MOVE:
			##$timer_display.set_value(100)
			##if playing:
			#walk_path()
		#STATE.ATTACK:
			#$timer_display.set_value(($Timer.get_time_left()/$Timer.wait_time)*100)
			#$timer.text = str(($Timer.get_time_left()/$Timer.wait_time)*100)
			#if $Timer.time_left  <= 0:
				#CURRENT_STATE = STATE.MOVE
				#current_range = max_range
				#active = true
	#
		
func _ready():
	add_to_group("enemy_runes")
	init()
	add_to_group("enemy_runes")
	print(get_groups())
func init():
	if type:
		$Sprite2D.texture = type.texture
		maxsize = type.max_size
		max_range = type.speed
		current_range = type.speed
	else:
		type = preload("res://runes/eye.tres")

func move(pos):
	await wait(0.4)
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
	if raw_path.size() > 2 and current_range > 0:
		await move(raw_path[1])
		current_range -= 1
		walk_path()
	else:
		CURRENT_STATE = STATE.ATTACK
		$Timer.start(speed)
		active = false
		playing = false
		#$active.text = name+": not playing"
		

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
	return shortest_path
				
func pos_tran(pos):
	return Vector2i(floor(pos.x/TILESIZE),floor(pos.y/TILESIZE))

func _draw():
	#_debug_draw_astar_line()
	pass
	
func wait(seconds):
	await get_tree().create_timer(seconds).timeout
	
func _debug_draw_astar_line():
	if target:
		var this_path = tilemap.get_rune_path(pos_tran(position),pos_tran(target.position))
		path = this_path
		$Line2D.global_position = Vector2(0,0)
		$Line2D.points = PackedVector2Array(this_path)


func _on_timer_timeout():
	CURRENT_STATE = STATE.MOVE
	current_range = max_range
	active = true
	
func delete_segments(size):
	for s in size:
		await wait(0.2)
		if tails.size() > 0:
			tails[s].queue_free()
			tails.remove_at(s)
			tail_position.remove_at(s)
		else:
			queue_free()
	pass
