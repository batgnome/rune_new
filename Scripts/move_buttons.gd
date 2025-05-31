extends Node2D


@onready var parent

signal move_button
func _ready():
	parent = get_parent()
	pass # Replace with function body.

func _on_down_input_event(_viewport, event, _shape_idx):
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			emit_signal("move_button",Vector2.DOWN)

func _on_right_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			emit_signal("move_button",Vector2.RIGHT)

func _on_left_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			emit_signal("move_button",Vector2.LEFT)

func _on_up_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			emit_signal("move_button",Vector2.UP)
