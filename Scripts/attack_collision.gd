extends Area2D


var mouse = false
var enem = null

func _on_input_event(viewport, event, shape_idx):
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print(self)
		if enem:
			print("attack!")


func _on_area_entered(area):
	
	if area.get_parent() and area.get_parent().is_in_group("enemy_runes"):
		enem = area.get_parent()
		

func _on_area_exited(area):
	enem = null
