extends Node

var active_rune_tile: Node = null

func select(tile: Node):
	if active_rune_tile != null and active_rune_tile != tile:
		active_rune_tile.deselect()
		

	active_rune_tile = tile

func _unhandled_input(event):
	if event.is_action_pressed('esc'):
		get_tree().quit()

	
