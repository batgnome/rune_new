extends Area2D


var mouse = false
var enem = null
var parent 
signal attack_done
func _on_input_event(_viewport, event, _shape_idx):
	if get_parent().get_parent().is_in_group("enemy_runes"):
		pass
	else:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if enem:
				enem.delete_segments(parent.attack_power)
			emit_signal("attack_done")


func _on_area_entered(area):
	var parent = get_parent().get_parent()
	if parent.is_in_group("enemy_runes"):
		if area.get_parent() and area.get_parent().is_in_group("pl_runes") and not parent.attack_done:
			enem = area.get_parent()
			emit_signal("attack_done",enem)
	else:
		if area.get_parent() and area.get_parent().is_in_group("enemy_runes"):
			enem = area.get_parent()
		

func _on_area_exited(_area):
	enem = null
