extends Node2D

@export var inv: RuneInv
var inside = false
var inside_hold = false
var rune_name: String = "Blank"
var speed: int = 0 
var attack_range: int = 0
var attack_power: int = 0
var max_size: int = 0

@onready var blank_texture = $Sprite2D.texture
var texture: Texture2D = blank_texture

var current_rune: runeItem
var current_moves = 0

var marker_texture = preload("res://assets/runes/marker.png")
var attack_marker_texture = preload("res://assets/runes/att_marker.png")
var arrow_marker_texture = preload("res://assets/runes/arrow_marker.png")
var bullet = preload("res://scenes/bullet.tscn")

var attack_collision_scene = preload("res://scenes/attack_collision.tscn")
var tail_scene = preload("res://scenes/tail.tscn")

var tail_position = []
var tails = []
var attack_done = false

const TILE_OFFSET = Vector2(-10, -10)
const TILESIZE = 20
const TIMER_SPEED = 2
enum STATE { BUILD, PRE, MOVE, ATTACK }
var fired = false
@onready var clock = $Timer
@onready var current_state = STATE.BUILD
@onready var manager = get_parent().get_parent()
@onready var tilemap = manager.tilemap
signal rune_set(rune)

var this_path = []
var baked_path = []
var path_select = false

func _ready():
	add_to_group("damagable")
	#shader nonsense
	var viewport_texture = $view_container/SubViewport.get_texture()
	$Sprite2D.material.set_shader_parameter("mask_texture", viewport_texture)
	$Sprite2D.material = $Sprite2D.material.duplicate()
	
	set_rune(preload("res://runes/blank.tres"))
	connect("rune_set", Callable(manager, "_on_rune_selected"))
	
	
func _process(_delta):
	if !tilemap:
		tilemap = manager.tilemap
		
	$timer_display.set_value((clock.get_time_left() / clock.wait_time) * 100)
	
	update_tails()
	
	if  manager.rune == self:
		if tilemap:
			this_path = tilemap.get_rune_path(pos_tran(position),pos_tran(get_global_mouse_position()))
			
			
		$Sprite2D.material.set_shader_parameter("show_outline", manager.rune == self)
		
		match current_state:
			STATE.MOVE:
				if path_select == false:
					baked_path = []
					if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
						baked_path = this_path
					if !baked_path.is_empty():
						path_select = true
						walk_path(baked_path)
				queue_redraw()
				

				if current_moves <= 0:
					set_state(STATE.ATTACK)
			STATE.ATTACK:
				set_attack()
	else:
		this_path = []
		queue_redraw()
			
func _input(event):
	if current_state == STATE.MOVE:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if path_select:
				path_select = false
				baked_path.clear()
				this_path.clear()

			
func walk_path(path):
	var moved = 0
	var i = 0
	while i < path.size()-1:
		if current_moves <= 0:
			set_state(STATE.ATTACK)
			path_select = false
			break
		var next_pos = path[i+1]
		move(next_pos)
		current_moves -= 1
		moved += 1

		await wait(0.2) 
		i+=1
	if current_moves > 0:
		path_select = false
	# After walking is done, trigger attack state
	if moved > 0:
		$draw_layer.queue_redraw()
		
func move(pos):
	
	tilemap.astargrid.set_point_solid(tilemap.local_to_map(global_position),false)
	if pos != global_position:
		tail_position.append(global_position)
		tilemap.astargrid.set_point_solid(tilemap.local_to_map(global_position),true)
		if tail_position.size() > max_size -1:
			tilemap.astargrid.set_point_solid(tilemap.local_to_map(tail_position[0]),false)
			tail_position.pop_front()
		else:
			create_tail()
	update_tails()
	global_position = pos
	tilemap.astargrid.set_point_solid(tilemap.local_to_map(global_position),true)
	tilemap.queue_redraw()
	
	
func _draw():
	if current_state == STATE.MOVE:
		$Line2D.global_position = Vector2(0,0)
		$Line2D.points = PackedVector2Array(this_path)
	else:
		$Line2D.points = []
		
func pos_tran(pos):
	return Vector2i(floor(pos.x/TILESIZE),floor(pos.y/TILESIZE))
	
func _unhandled_input(event):
	
	if current_state != STATE.BUILD and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		
		if manager.rune == self:
			$draw_layer.queue_redraw()
			if not current_moves > 0 and current_state == STATE.MOVE:
				set_state(STATE.ATTACK)
		else:
			$draw_layer.queue_redraw()
	if manager.rune == self:		
		if current_state == STATE.MOVE:
			if event.is_action("attack"):
				set_attack()

		if current_state == STATE.ATTACK \
		and event is InputEventMouseButton  \
		and event.button_index == MOUSE_BUTTON_LEFT \
		and event.pressed \
		and not fired:
			var nodes =get_parent().get_children()
			var entered = false
			for n in nodes:
				if n.mouse_entered == true:
					entered = true
			if not entered:
				fired = true
				var angle = get_local_mouse_position().angle()
				fire(angle)
				

func _on_mouse_selected(_viewport, event, _shape_idx):
	if current_state != STATE.BUILD and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		$Sprite2D.material.set_shader_parameter("show_outline", true)
		emit_signal("rune_set", self)

			
func move_in_direction(dir: Vector2):
	
	if current_state != STATE.BUILD and current_state == STATE.MOVE and manager.rune == self:
		var no_move = false
		var target_pos = position + dir * TILESIZE
		var index = tail_position.find(target_pos)
		
		if index == -1:
			if dir == Vector2.UP:
				no_move = $move_buttons/up.has_overlapping_areas()
			elif dir == Vector2.DOWN:
				no_move = $move_buttons/down.has_overlapping_areas()
			elif dir == Vector2.LEFT:
				no_move = $move_buttons/left.has_overlapping_areas()
			elif dir == Vector2.RIGHT:
				no_move = $move_buttons/right.has_overlapping_areas()
		
		if Utils.can_move_to(target_pos,manager.tilemap) and current_moves > 0 and not no_move:
			
			if index != -1:
				tail_position.remove_at(index)
				tail_position.append(global_position)
			else:
				tail_position.append(global_position)
				if tail_position.size() >= max_size:
					tail_position.pop_front()
				else:
					create_tail()
					update_tails()
			position = target_pos
			current_moves -= 1
			emit_signal("rune_set", self)
			$draw_layer.queue_redraw()

func create_tail():
	var t = tail_scene.instantiate()
	t.add_to_group("pl_runes")
	t.set_texture(current_rune.tail_texture,current_rune.tile_size)
	t.top_level = true
	tails.append(t)
	add_child(t)

func update_tails():
	for i in tail_position.size():
		tails[i].position = tail_position[i] #- Vector2(TILESIZE, TILESIZE)

func _on_rune_chosen(rune):
	if current_state != STATE.BUILD:
		if rune.name != "blank" and inv.get_amount(rune) > 0:
			if current_rune:
				inv.sub(rune)
				inv.add(current_rune)
			else:
				inv.sub(rune)
			current_rune = rune
			set_rune(self)
		elif rune.name != "blank" and inv.get_amount(rune) < 0:
			current_rune = rune
			set_rune(self)
		elif current_rune:
			if inv and inv.get_amount(current_rune) >= 0:
				inv.add(current_rune)
			current_rune = null
			set_rune(self)
			
func set_attack():
	for a in $move_buttons.get_children():
		a.set_pickable(false)

func set_move():
	for a in $move_buttons.get_children():
		a.set_pickable(true)
			
func set_state(new_state):
	if current_state != new_state:
		match  new_state:
			STATE.MOVE:
				set_move()
				attack_done = false
				fired = false
				current_moves = speed
			STATE.ATTACK:
				clock.start(TIMER_SPEED)
		current_state = new_state
		$draw_layer.queue_redraw()
		queue_redraw()
		
func set_rune(rune):
	emit_signal("rune_set", rune)
	if current_rune:
		rune_name = current_rune.name
		speed = current_rune.speed
		current_moves = speed
		attack_range = current_rune.attack_range
		attack_power = current_rune.attack_power
		max_size = current_rune.max_size
		texture = current_rune.texture
		set_texture(texture)
	else:
		rune_name = "blank"
		speed = 0
		current_moves = 0
		attack_range = 0
		attack_power = 0
		max_size = 0
		texture = blank_texture
		set_texture(texture)
	#init_attack_collision_shapes(attack_range)

func set_texture(img):
	
	$Sprite2D.texture = img
	print($Sprite2D.texture.get_size() > Vector2.ONE *20)
	if current_rune and $Sprite2D.texture.get_size() > Vector2.ONE *20:
		$Sprite2D.scale = (Vector2.ONE * 20.0/current_rune.tile_size)*0.7
	else:
		$Sprite2D.scale = Vector2.ONE*0.7
func deselect():
	$draw_layer.queue_redraw()

func _on_move_buttons_move_button(dir):
	move_in_direction(dir)

func _on_timer_timeout():
	set_state(STATE.MOVE)
	path_select = false


func delete_segments(size):
	for s in size:
		if tails.size() > 0:
			var dying_tail = tails[0]
			tail_position.remove_at(0)
			tails.remove_at(0)
			emit_signal("rune_set", self)
			if is_instance_valid(dying_tail):
				await dying_tail.die()
		else:
			# Play death anim for head if no tails left
			emit_signal("rune_set",null)
			var anim_sprite = %death_anim
			anim_sprite.play()

func fire(rotate_bullet):
	var b = bullet.instantiate()
	b.add_to_group("pl_runes")
	b.speed = 30  # or however fast you want — 3 is probably too slow unless it's pixels/frame
	b.damage = attack_power
	b.pos = global_position #- TILE_OFFSET
	b.max_dist = attack_range*20
	b.rota = rotate_bullet  # This sets the direction the bullet travels
	b.owner_group = "pl_runes"
	b.target_group = "enemy_runes"
	
	get_tree().root.get_child(0).add_child(b)
	
	
func wait(seconds):
	await get_tree().create_timer(seconds).timeout		


func _on_animated_sprite_2d_animation_finished():
	queue_free()

var mouse_entered = false
func _on_select_rune_mouse_entered():
	mouse_entered = true

func _on_select_rune_mouse_exited():
	mouse_entered = false
