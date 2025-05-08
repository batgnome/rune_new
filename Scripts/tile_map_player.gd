extends TileMap
var aStar:AStar2D
var astargrid = AStarGrid2D.new()
@export var cell_size = Vector2i(20,20)
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
	
	init_grid()


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
		
		astargrid.set_point_solid(a,false)
	

func update_path():
	$Line2D.points = PackedVector2Array(astargrid.get_point_path(start, end))
	
			
func get_rune_path(rune_start,rune_end):
	start = rune_start
	end = rune_end
	return astargrid.get_point_path(start, end)



