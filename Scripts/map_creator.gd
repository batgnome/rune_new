extends TileMap
var aStar:AStar2D
var astargrid = AStarGrid2D.new()
@export var cell_size = Vector2i(TILESIZE,TILESIZE)
var grid_size
var start = Vector2i.ZERO
var end = Vector2i(12, 10)
var parent = get_parent()
var rune = preload("res://scenes/blank_rune.tscn")
var enem = preload("res://scenes/enemy.tscn")
var current_rune
var slider
var slider_label
@onready var Entities
@onready var Runes
func _ready()->void:
	parent = get_parent()
	Entities = $"../Entities"
	Runes = $"../runes"
	print(Entities)
	slider = %HSlider
	slider_label = $"CanvasLayer/RunePalette/slider label"
	slider_label.text = "Size:" + str(slider.value)
	init_grid()
	$CanvasLayer/RunePalette.connect("rune_selected", Callable(self, "_on_rune_selected"))

func _on_rune_selected(rune):
	
	current_rune = rune
	print("Selected:", rune.name)
	
func init_grid():
	grid_size = Vector2i(get_viewport_rect().size) / cell_size

	astargrid.size = grid_size
	astargrid.cell_size = cell_size
	astargrid.offset = cell_size/2

	astargrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astargrid.update()
	astargrid.fill_solid_region(Rect2i(Vector2i.ZERO, grid_size),true)

	queue_redraw()
	var arr = get_used_cells(0)
	var test = []
	for a in arr:
		test.append(map_to_local(a))
		var cell_data = get_cell_tile_data(0, a)
		if cell_data.get_custom_data("rune_type"):
			if cell_data.get_custom_data("rune_type").name != 'blank':
				init_runes(a)
			else:
				#init_enem(a,cell_data.get_custom_data("rune_type"))
				pass
		astargrid.set_point_solid(a,false)
	
	#astargrid.update()
	#print(astargrid.get_point_path(start, end))
	
func init_runes(pos):
	var p = rune.instantiate()
	p.position = map_to_local(pos)
	%runes.add_child(p)
	set_cell(0,pos)
	pass
	
func init_enem(pos,type):
	enem.instantiate()
	enem.position = pos
func _draw():
	#draw_rect(Rect2(start * cell_size, cell_size), Color.GREEN_YELLOW)
	#draw_rect(Rect2(end * cell_size, cell_size), Color.ORANGE_RED)
	##draw_rect(get_viewport_rect(),Color.RED)
	if parent.current_state == parent.STATES.PRE:
		draw_grid()
	#update_path()
	#draw_rect(get_viewport_rect(),Color.AQUA)
	
func update_path():
	$Line2D.points = PackedVector2Array(astargrid.get_point_path(start, end))
	
func draw_grid():
	for x in grid_size.x:
		for y in grid_size.y:
			var cell = Vector2i(x, y)
			var pos = cell * cell_size
			if astargrid.is_point_solid(cell):
				draw_rect(Rect2(pos, cell_size), Color.BLUE)  # Solid
			else:
				draw_rect(Rect2(pos, cell_size), Color.GREEN)  # Walkable
	for x in grid_size.x + 1:
		draw_line(Vector2(x * cell_size.x, 0),
			Vector2(x * cell_size.x, grid_size.y * cell_size.y),
			Color.DARK_GRAY, 2.0)
	for y in grid_size.y + 1:
		draw_line(Vector2(0, y * cell_size.y),
			Vector2(grid_size.x * cell_size.x, y * cell_size.y),
			Color.DARK_GRAY, 2.0)

			
func get_rune_path(rune_start,rune_end):
	start = rune_start
	end = rune_end
	return astargrid.get_point_path(start, end)

var paint_tile_id = 2  # example tile source ID
var atlas_coords = Vector2i(0, 0)  # adjust as needed
var is_painting = false

func _unhandled_input(event):
	if parent.current_state == parent.STATES.PRE:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				is_painting = event.pressed  # true on down, false on release

		if event is InputEventMouseMotion and is_painting:
			paint_mult(event.position)

func paint_mult(screen_pos):
	var size = slider.value
	var local_pos = to_local(screen_pos)
	var coords = local_to_map(local_pos)
	
	if size == 0:
		set_cell(0, coords +Vector2i(0,0), paint_tile_id, atlas_coords)
	else:
		for x in range(0,size):
			for y in range(0,size):
				if !current_rune or current_rune.name =="tile":
					set_cell(0, coords-Vector2i(size,size)/(2) +Vector2i(x,y), paint_tile_id, atlas_coords)
				elif current_rune.name == "blank":
					var world_pos = map_to_local(coords - Vector2i(size, size) / 2 + Vector2i(x, y))
					for child in Entities.get_children():
						if child.position.distance_to(world_pos) < cell_size.x / 2:
							child.queue_free()

					for rune in Runes.get_children():
						if rune.position.distance_to(world_pos) < cell_size.x / 2:
							rune.queue_free()
					var rune = rune.instantiate()
					rune.position =map_to_local( coords-Vector2i(size,size)/(2) +Vector2i(x,y) )
					rune.set_rune(current_rune)
					Runes.add_child(rune)
				elif current_rune.name =="erase tile":
					set_cell(0, coords-Vector2i(size,size)/(2) +Vector2i(x,y), -1, atlas_coords)
				elif current_rune.name =="erase object":
					var world_pos = map_to_local(coords - Vector2i(size, size) / 2 + Vector2i(x, y))
					for child in Entities.get_children():
						if child.position.distance_to(world_pos) < cell_size.x / 2:
							child.queue_free()

					for rune in Runes.get_children():
						if rune.position.distance_to(world_pos) < cell_size.x / 2:
							rune.queue_free()
				else:
					var world_pos = map_to_local(coords - Vector2i(size, size) / 2 + Vector2i(x, y))
					for child in Entities.get_children():
						if child.position.distance_to(world_pos) < cell_size.x / 2:
							child.queue_free()

					for rune in Runes.get_children():
						if rune.position.distance_to(world_pos) < cell_size.x / 2:
							rune.queue_free()
					var rune = enem.instantiate()
					rune.set_tilemap(self)
					rune.position =map_to_local( coords-Vector2i(size,size)/(2) +Vector2i(x,y) )
					rune.type = current_rune
					Entities.add_child(rune)
				
	init_grid()



func _on_h_slider_value_changed(value):
	#print(slider)
	slider_label.text = "Size:" + str(value)
	pass # Replace with function body.

