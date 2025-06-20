extends Control

@export var rune_folder_path: String = "res://runes"  # Adjust to your folder
@export var button_scene: PackedScene  # We'll assign a simple Button scene here
var TILESIZE = 20
signal rune_selected(rune: runeItem)

func _ready():
	load_rune_buttons()

func load_rune_buttons():
	var dir = DirAccess.open(rune_folder_path)
	if dir:
		
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			
			if file.ends_with(".tres"):
				
				var rune = load(rune_folder_path + "/" + file)
				if rune is runeItem:
					
					create_btn(rune.texture,rune)
			file = dir.get_next()
		dir.list_dir_end()
	var t = ACTIVEload("res://assets/tiles/tile.png")
	var atlas_texture := AtlasTexture.new()
	atlas_texture.set_atlas(t)
	atlas_texture.set_region(Rect2i(Vector2i.ZERO,Vector2i(TILESIZE,TILESIZE)))
	var rune = runeItem.new()
	rune.name="tile"
	create_btn(atlas_texture,rune)
	
	atlas_texture = AtlasTexture.new()
	atlas_texture.set_atlas(t)
	atlas_texture.set_region(Rect2i(Vector2i(TILESIZE,40),Vector2i(TILESIZE,TILESIZE)))
	rune = runeItem.new()
	rune.name="erase tile"
	create_btn(atlas_texture,rune)
	rune = runeItem.new()
	rune.name="erase object"
	create_btn(atlas_texture,rune)
	
	

func create_btn(texture,rune):
	var btn = button_scene.instantiate()
	btn.texture_normal = texture
	btn.get_child(0).text = rune.name
	btn.connect("pressed", func(): emit_signal("rune_selected", rune))
	
	$RuneGrid.add_child(btn)
