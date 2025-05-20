extends Node2D


func set_texture(texture):
	$Sprite2D.texture = texture


func delete_segments(size):
	get_parent().delete_segments(size)

func add_index(size):
	$index.text = str(size)
	queue_redraw()
