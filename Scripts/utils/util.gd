class_name Utils


static func can_move_to(world_position: Vector2,tilemap: TileMap) -> bool:
	print(world_position)
	print(tilemap)
	var map_pos =tilemap.local_to_map(world_position)
	var cell_data = tilemap.get_cell_tile_data(0, map_pos)
	return cell_data and cell_data.get_custom_data("walkable") == true
