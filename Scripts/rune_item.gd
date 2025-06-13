@tool
extends Resource

class_name runeItem

@export var name: String = ""
@export var speed: int
@export var attack_range: int
@export var attack_power: int
@export var max_size: int
@export var texture: Texture2D
@export var tail_texture: Texture2D


@export var atlas_texture: Texture2D = preload("res://assets/tiles/tile_hd.png") : set = set_atlas_texture
@export var tile_index: Vector2i = Vector2i(0, 0) : set = set_tile_index
@export var tile_size: int = 100 : set = set_tile_size


var _tile_index := Vector2i(0, 0)
var _tile_size := 100
var _atlas_texture: Texture2D = null

func set_atlas_texture(value):
	atlas_texture = value
	_update_preview()

func set_tile_index(value):
	tile_index = value
	_update_preview()

func set_tile_size(value):
	tile_size = value
	_update_preview()

func set_tail_texture():
	var region = Rect2((tile_index.x+1) * tile_size, tile_index.y * tile_size, tile_size, tile_size)
	var tex := AtlasTexture.new()
	tex.atlas = atlas_texture
	tex.region = region
	tex.filter_clip = true
	tail_texture = tex
# Needed for getters so inspector knows how to render values properly
func get_tile_index(): return _tile_index
func get_tile_size(): return _tile_size
func get_atlas_texture(): return _atlas_texture

func _update_preview():
	
	var region = Rect2(tile_index.x * tile_size, tile_index.y * tile_size, tile_size, tile_size)
	var tex := AtlasTexture.new()
	
	tex.atlas = atlas_texture
	tex.region = region
	tex.filter_clip = true
	texture = tex
	
	set_tail_texture()
	
