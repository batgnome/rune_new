extends Control


func set_value(value):
	$TextureProgressBar.value = value
	if value <= 100:
		show()
	else:
		hide()
