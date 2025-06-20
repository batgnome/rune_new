extends TileMap
var aStar:AStar2D
var astargrid = AStarGrid2D.new()
const TILESIZE = 20
@export var cell_size = Vector2i(TILESIZE,TILESIZE)
var grid_size
var start = Vector2i.ZERO
var end = Vector2i(12, 10)
var parent = get_parent()
var current_rune
var slider
var slider_label
@onready var Entities
@onready var Runes
func _ready()->void:
	parent = get_parent()
	Entities = $"../Entities"
	Runes = $"../runes"
	
	
	init_grid()


func _on_rune_selected(rune):
	
	current_rune = rune
	
func init_grid():
	grid_size = Vector2i(get_viewport_rect().size) / cell_size

	astargrid.region = Rect2(Vector2i(0,0),grid_size)
	astargrid.cell_size = cell_size
	astargrid.offset = cell_size/2

	astargrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astargrid.update()
	astargrid.fill_solid_region(Rect2i(Vector2i.ZERO, grid_size),true)

	queue_redraw()
	var solid_tiles = get_used_cells(0)
	var dumpTiles = []
	for tile in solid_tiles:
		dumpTiles.append(tile)
		astargrid.set_point_solid(tile,false)
	
#
#func _draw():
	##draw_rect(Rect2(start * cell_size, cell_size), Color.GREEN_YELLOW)
	##draw_rect(Rect2(end * cell_size, cell_size), Color.ORANGE_RED)
	###draw_rect(get_viewport_rect(),Color.RED)
	#
	#draw_grid()
	#update_path()
	#draw_rect(get_viewport_rect(),Color.AQUA)
	

func draw_grid():
	for x in grid_size.x:
		for y in grid_size.y:
			var cell = Vector2i(x, y)
			var pos = cell * cell_size
			if astargrid.is_point_solid(cell):
				draw_rect(Rect2(pos, cell_size), Color.BLACK)  # Solid
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
func update_path():
	$Line2D.points = PackedVector2Array(astargrid.get_point_path(start, end))
	
			
func get_rune_path(rune_start,rune_end):
	var points = astargrid.get_point_path(rune_start, rune_end)
	
	return points
	
var t
var coords
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if t:
			set_cell(0,coords,0,Vector2i(0,0))
		coords = local_to_map(get_global_mouse_position())
		
		t = get_cell_tile_data(0, coords)
		if t:
			set_cell(0,coords,0,Vector2i(3,0))


