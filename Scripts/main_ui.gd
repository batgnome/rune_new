extends Control


# Called when the node enters the scene tree for the first time.
@onready var values = %values
@onready var labels = %labels
@onready var icon = %icon

signal start

func _ready():
	values.visible = false
	icon.visible = false
	labels.visible = false
	set_values()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_values(rune = null):

	if rune:
		if rune.current_rune:
			if rune.current_rune.name !="blank":
				var current_rune = rune.current_rune
				
				values.visible = true
				icon.visible = true
				labels.visible = true
				values.get_child(0).text = current_rune.name
				values.get_child(1).text = str(rune.current_moves) + "/" + str(current_rune.speed)
				values.get_child(2).text = str(current_rune.attack_range)
				values.get_child(3).text = str(current_rune.attack_power)
				values.get_child(4).text = str(current_rune.max_size)
				icon.texture = current_rune.texture
	else:
		values.visible = false
		icon.visible = false
		labels.visible = false

func _on_main_get_rune(rune):
	if rune:
		set_values(rune)
	pass # Replace with function body.



func _on_start_pressed():
	emit_signal("start")
	
func _hide_start():
	$Panel/NinePatchRect/start_label.visible = false
	%Start.visible = false
	
