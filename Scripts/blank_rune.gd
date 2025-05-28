extends Node2D

@export var inv: RuneInv
var inv_ui
var inside = false
var inside_hold = false
var rune_name: String = "Blank"
var speed: int = 0 
var attack_range: int = 0
var attack_power: int = 0
var max_size: int = 0

var blank_texture = preload("res://assets/runes/blank.png")
var texture: Texture2D = blank_texture

var current_rune: runeItem
var manager
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

@onready var clock = $Timer
@onready var current_state = STATE.BUILD
@onready var tilemap
signal rune_set(rune)

func get_current_state():
	return current_state

func _ready():
	var viewport_texture = $view_container/SubViewport.get_texture()
	$Sprite2D.material.set_shader_parameter("mask_texture", viewport_texture)
	$Sprite2D.material = $Sprite2D.material.duplicate()
	set_rune(preload("res://runes/blank.tres"))
	manager = get_parent().get_parent()
	tilemap = manager.tilemap
	inv_ui = %Inv_ui
	inv_ui.connect("rune_chosen", Callable(self, "_on_rune_chosen"))

func _process(_delta):
	if !tilemap:
		tilemap = manager.tilemap
	$timer_display.set_value((clock.get_time_left() / clock.wait_time) * 100)
	update_tails()
	if current_state != STATE.BUILD:
		$Sprite2D.material.set_shader_parameter("show_outline", manager.rune == self)
		if current_moves <= 0 and current_state == STATE.MOVE:
			set_state(STATE.ATTACK)
			clock.start(TIMER_SPEED)
			queue_redraw()
		elif current_state == STATE.ATTACK:
			set_attack()

func _draw():
	if current_state != STATE.BUILD and manager.rune == self:
		if current_state == STATE.ATTACK and not attack_done:
			render_markers(attack_marker_texture, attack_range)
		elif current_state == STATE.MOVE and current_moves > 0:
			draw_movement_arrows()
			render_markers(marker_texture, current_moves)

func draw_movement_arrows():
	var rect = Rect2(Vector2(-10, -30), Vector2(TILESIZE, TILESIZE))
	var dirs = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
	var angles = [-90, 90, 0, 180]
	for i in range(4):
		var dir = dirs[i]
		print("utils", tilemap)
		if Utils.can_move_to(position + TILESIZE * dir,tilemap):
			draw_set_transform(Vector2.ZERO, deg_to_rad(angles[i]), Vector2.ONE)
			draw_texture_rect(arrow_marker_texture, rect, false)
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
	
func render_markers(mark, size):
	for x in range(-size, size + 1):
		for z in range(-size, size + 1):
			if abs(z) + abs(x) <= size:
				var target_pos = Vector2(position.x + TILESIZE * x, position.y + TILESIZE * z)
				print("utils", tilemap)
				if Utils.can_move_to(target_pos,tilemap):
					var rect = Rect2(Vector2(TILE_OFFSET.x + TILESIZE * x, TILE_OFFSET.y + TILESIZE * z), Vector2(TILESIZE, TILESIZE))
					draw_texture_rect(mark, rect, false)

func init_attack_collision_shapes(size):
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

func _attack_done():
	attack_done = true
	queue_redraw()

func set_attack():
	for a in %att_area.get_children():
		a.set_pickable(true)
	for a in $move_buttons.get_children():
		a.set_pickable(false)

func set_move():
	for a in %att_area.get_children():
		a.set_pickable(false)
	for a in $move_buttons.get_children():
		a.set_pickable(true)

func _unhandled_input(event):
	if current_state != STATE.BUILD and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		inv_ui.close()
		if manager.rune == self:
			queue_redraw()
			if not current_moves > 0 and current_state == STATE.MOVE:
				set_state(STATE.ATTACK)
		else:
			queue_redraw()
	if current_state == STATE.MOVE:
		if event.is_action("attack"):
			set_attack()
			
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
			queue_redraw()

func create_tail():
	var t = tail_scene.instantiate()
	t.set_texture(current_rune.tail_texture)
	t.top_level = true
	t.add_to_group("pl_runes")
	tails.append(t)
	add_child(t)

func update_tails():
	for i in tail_position.size():
		tails[i].position = tail_position[i] - Vector2(TILESIZE, TILESIZE) / 2

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
		elif current_rune:
			inv.add(current_rune)
			current_rune = null
			set_rune(self)

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
	init_attack_collision_shapes(attack_range)

func set_texture(img):
	$Sprite2D.texture = img

func deselect():
	queue_redraw()
	inv_ui.close()

func _on_inv_ui_close_button():
	inv_ui.close()

func _on_mouse_selected(_viewport, event, _shape_idx):
	if current_state != STATE.BUILD and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		manager.rune = self
		emit_signal("rune_set", self)
		if current_state == STATE.PRE:
			if inv_ui.is_open:
				inv_ui.close()
			else:
				inv_ui.open()
				RuneSelectionManager.select(self)

func _on_move_buttons_move_button(dir):
	move_in_direction(dir)

func _on_timer_timeout():
	set_move()
	attack_done = false
	set_state(STATE.MOVE)
	current_moves = speed

func set_state(new_state):
	if current_state != new_state:
		current_state = new_state
		queue_redraw()
		
func delete_segments(size):
	for s in size:
		if tails.size() > 0:
			tail_position.remove_at(0)

			if is_instance_valid(tails[0]):
				await tails[0].die()
			tails.remove_at(0)
		else:
			var anim_sprite = $view_container/SubViewport/AnimatedSprite2D
			if not anim_sprite.is_playing():
				anim_sprite.play("default")  # Replace with your actual animation name
				await wait(0.8)
				queue_free()
			await wait(0.4)
		
func fire():
	var b = bullet.instantiate()
	b.speed = 3
	b.pos = global_position
	b.rota = global_rotation
	b.dir = rotation
	add_child(b)
	
func wait(seconds):
	await get_tree().create_timer(seconds).timeout		


func _on_animated_sprite_2d_animation_finished():
	print("dead???")
	queue_free()
