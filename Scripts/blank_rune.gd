extends Node2D
@export var inv: RuneInv
var myInv
var inside = false
var inside_hold = false
var Rname: String = "Blank"
var speed: int = 0 
var attack_range: int =0 
var attack_power: int = 0
var max_size: int = 0
var blank = preload("res://assets/runes/blank.png")
var texture: Texture2D = preload("res://assets/runes/blank.png")
var current_rune: runeItem
var manager
var current_moves = 0
var marker = preload("res://assets/runes/marker.png")
var att_marker = preload("res://assets/runes/att_marker.png")
var arrow_marker = preload("res://assets/runes/arrow_marker.png")
var att_col = preload("res://scenes/attack_collision.tscn")
var tail = preload("res://scenes/tail.tscn")
var tail_position = []
var tails = []
enum STATE {BUILD,PRE,MOVE,ATTACK}
const TILESIZE = 20

@onready var  CURRENT_STATE = STATE.BUILD
signal rune_set(rune)

func get_current_state():
	return CURRENT_STATE
func _ready():
	attack_collision_2(attack_range) 
	$Sprite2D.material = $Sprite2D.material.duplicate()
	CURRENT_STATE = STATE.BUILD
	set_rune(preload("res://runes/blank.tres"))
	manager = get_parent().get_parent()
	myInv = %Inv_ui
	myInv.connect("rune_chosen", Callable(self, "_on_rune_chosen"))
	
	
func _process(_delta):
	update_tails()
	if CURRENT_STATE != STATE.BUILD:
		$Sprite2D.material.set_shader_parameter("show_outline", manager.rune == self)
		if current_moves <= 0 and CURRENT_STATE == STATE.MOVE:
			CURRENT_STATE = STATE.ATTACK
			queue_redraw()
		if CURRENT_STATE == STATE.ATTACK:
			pass
func _draw():
	#render moves
	if CURRENT_STATE != STATE.BUILD:
		if manager.rune == self:
			#print("state: ", CURRENT_STATE, " moves: ", current_moves)
			if CURRENT_STATE == STATE.ATTACK:
				#print("super")
				render_markers(att_marker,attack_range)
				
			if CURRENT_STATE == STATE.MOVE:
				
				
				if current_moves >0:
					var rect1 =Rect2(Vector2(-10,-30),Vector2(20,20))
					if can_move_to(Vector2(position.x-20,position.y)):
						draw_set_transform(Vector2(0, 0), deg_to_rad(-90), Vector2.ONE)
						draw_texture_rect(arrow_marker,rect1,false)
					if can_move_to(Vector2(position.x+20,position.y)):
						draw_set_transform(Vector2(0, 0), deg_to_rad(90), Vector2.ONE)
						draw_texture_rect(arrow_marker,rect1,false)
					#Up
					if can_move_to(Vector2(position.x,position.y-20)):
						draw_set_transform(Vector2(0, 0), deg_to_rad(0), Vector2.ONE)
						draw_texture_rect(arrow_marker,rect1,false)
					#Down
					if can_move_to(Vector2(position.x,position.y+20)):
						draw_set_transform(Vector2(0, 0), deg_to_rad(180), Vector2.ONE)
						draw_texture_rect(arrow_marker,rect1,false)
					draw_set_transform(Vector2(0, 0), deg_to_rad(0), Vector2.ONE)
				render_markers(marker,current_moves)
		
func render_markers(mark,size):
	var offset = Vector2(-10,-10)
	for x in range(-size, size + 1):
		for z in range(-size, size + 1):
			if abs(z) + abs(x) <= size:
				if can_move_to(Vector2(position.x+20*x,position.y+20*z)):
					var rect =Rect2(Vector2(offset.x+20*x,offset.y+20*z),Vector2(20,20))
					draw_texture_rect(mark,rect,false)	

func attack_collision(size):

	var offset = Vector2(-10, -10)
	var tile_points := []

	for x in range(-size, size + 1):
		for y in range(-size, size + 1):
			if abs(x) + abs(y) <= size:  # same as your marker shape
				var tile_center = Vector2(offset.x + 20 * x + 10, offset.y + 20 * y + 10)
				tile_points.append(tile_center)
func attack_collision_2(size):
	
	var offset = Vector2(-10, -10)

	for x in range(-size, size + 1):
		for y in range(-size, size + 1):
			if abs(x) + abs(y) <= size:  # same as your marker shape
				if !(x == 0 and y == 0):
					var tile_center = Vector2(offset.x + 20 * x, offset.y + 20 * y)
					var att = att_col.instantiate()
					att.position = tile_center
					%att_area.add_child(att)

func create_attack(mark,size):
	var _collision = CollisionPolygon2D.new()
	
	var _offset = Vector2(-10,-10)
	for x in range(-size, size + 1):
		for z in range(-size, size + 1):
			if abs(z) + abs(x) <= size:
				print(Vector2i(x,z))
				#if can_move_to(Vector2(position.x+20*x,position.y+20*z)):
					#var rect =Rect2(Vector2(offset.x+20*x,offset.y+20*z),Vector2(20,20))
					#draw_texture_rect(mark,rect,false)	
					
#closes menu if selected outside the rune
func _unhandled_input(event):
	if CURRENT_STATE != STATE.BUILD:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			myInv.close()
			
		if manager.rune == self:
			
			if CURRENT_STATE == STATE.MOVE:
				if current_moves > 0:
					move_logic(event)
				else:
					CURRENT_STATE = STATE.ATTACK
		else:
			queue_redraw()
		
##-------------------------Main Game-------------------------##
func move_logic(event):
	if CURRENT_STATE != STATE.BUILD:
		var pre_position = position
		if event.is_action_pressed('left') and can_move_to(position + (20*Vector2.LEFT)) and not $move_buttons/left.has_overlapping_areas():
			position += Vector2.LEFT*20
			current_moves -= 1
			tail_position.append(pre_position)
			emit_signal("rune_set",self)
		if event.is_action_pressed('right') and can_move_to(position + (20*Vector2.RIGHT)) and not $move_buttons/right.has_overlapping_areas():
			position += Vector2.RIGHT*20
			current_moves -= 1
			tail_position.append(pre_position)
			emit_signal("rune_set",self)
		if event.is_action_pressed('up') and can_move_to(position + (20*Vector2.UP)) and not $move_buttons/up.has_overlapping_areas():
			position += Vector2.UP*20
			current_moves -= 1
			tail_position.append(pre_position)
			emit_signal("rune_set",self)
		if event.is_action_pressed('down') and can_move_to(position + (20*Vector2.DOWN)) and not $move_buttons/down.has_overlapping_areas():
			position += Vector2.DOWN*20
			current_moves -= 1
			tail_position.append(pre_position)
			
			emit_signal("rune_set",self)
		queue_redraw()

func move_in_direction(dir: Vector2):
	if CURRENT_STATE != STATE.BUILD:
		var no_move = false
	
		if dir == Vector2.UP:
			no_move = $move_buttons/up.has_overlapping_areas()
		elif dir == Vector2.DOWN:
			no_move = $move_buttons/down.has_overlapping_areas()
		elif dir == Vector2.LEFT:
			no_move = $move_buttons/left.has_overlapping_areas()
		elif dir == Vector2.RIGHT:
			no_move = $move_buttons/right.has_overlapping_areas()
			
		if CURRENT_STATE != STATE.MOVE or manager.rune != self:
			return
		var target_pos = position + dir * 20
		if can_move_to(target_pos) and current_moves > 0 and not no_move:
			tail_position.append(global_position)
			if tail_position.size() > max_size+1:
				tail_position.pop_front()
			else:
				create_tail()
				update_tails()
			
			position = target_pos
			current_moves -= 1
			emit_signal("rune_set",self)
			queue_redraw()
			
func create_tail():
	var t = tail.instantiate()
	t.set_texture(current_rune.tail_texture)
	t.top_level = true
	t.add_to_group("pl_runes")
	tails.append(t)
	add_child(t)			
	
func update_tails():
	for i in tail_position.size():
		tails[i].position = tail_position[i] -Vector2(TILESIZE,TILESIZE)/2
func can_move_to(world_position: Vector2) -> bool:
	
	var map_pos = manager.tilemap.local_to_map(world_position)
	var cell_data = manager.tilemap.get_cell_tile_data(0, map_pos)
	
	if cell_data:
		var walkable = cell_data.get_custom_data("walkable")
		return walkable == true
	
	return false


##-------------------------Pre Game-------------------------##
##-------------------------Inventory functions-------------------------##
#sets the current rune to the selected on in the menu
func _on_rune_chosen(rune):
	if CURRENT_STATE != STATE.BUILD:
		if rune.name != 'blank':
			if inv.get_amount(rune) > 0:
				if current_rune:
					inv.sub(rune)
					inv.add(current_rune)
				else:
					inv.sub(rune)
				current_rune=rune
				set_rune(self)
		else:
			if current_rune:
				inv.add(current_rune)
				current_rune = null
			set_rune(self)

#load the rune attributes
func set_rune(rune):
	emit_signal("rune_set",rune)
	if current_rune:
		
		Rname = current_rune.name
		speed = current_rune.speed
		current_moves = speed
		attack_range = current_rune.attack_range
		attack_power = current_rune.attack_power
		max_size = current_rune.max_size
		texture = current_rune.texture
		set_texture(texture)
	else:
		Rname = "blank"
		speed = 0
		current_moves = 0
		attack_range = 0
		attack_power = 0
		max_size = 0
		texture = blank
		set_texture(texture)
	attack_collision_2(attack_range)
func set_texture(img):
	$Sprite2D.texture = img	
		
#close inventory when another rune is selected, referenced in the autoload function:
#runeSelectionManager
func deselect():
	queue_redraw()
	myInv.close()
	
#signal to the inv_ui node to get the close button on the inventory
func _on_inv_ui_close_button():
	myInv.close()


func _on_move_buttons_down_button():
	move_in_direction(Vector2.DOWN)


func _on_move_buttons_left_button():
	move_in_direction(Vector2.LEFT)


func _on_move_buttons_right_button():
	move_in_direction(Vector2.RIGHT)


func _on_move_buttons_up_button():
	move_in_direction(Vector2.UP)


func _on_mouse_selected(_viewport, event, _shape_idx):
	if CURRENT_STATE != STATE.BUILD:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			manager.rune = self
			#manager.set_rune(self)
			emit_signal("rune_set",self)
			if CURRENT_STATE == STATE.PRE:
				if myInv.is_open:
					myInv.close()
				else:
					myInv.open()
					RuneSelectionManager.select(self)

