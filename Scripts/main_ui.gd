extends Control


# Called when the node enters the scene tree for the first time.
@onready var values = %values
@onready var labels = %labels
@onready var icon = %icon
@onready var inv: RuneInv = preload("res://runes/runeInventory.tres")
#@onready var inv: RuneInv = preload("res://runes/TEST_INV.tres")
@onready var slots: Array = $Panel/inv/GridContainer.get_children()
var is_open = false
var select: runeItem
signal rune_chosen(runeItem)
signal close_button()
signal start
signal attack_pressed
signal muted
func _ready():
	values.visible = false
	icon.visible = false
	labels.visible = false
	set_values()
	
	
	self.mouse_filter = Control.MOUSE_FILTER_STOP
	#inv.update.connect(update_slots)
	update_slots()

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
				values.get_child(2).text = str(rune.tails.size()+1) +"/"+str(current_rune.max_size)
				values.get_child(4).text = str(current_rune.attack_range)
				values.get_child(3).text = str(current_rune.attack_power)
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
	$Panel/inv.visible = false
	



func on_get_rune(rune):
	if rune:
		emit_signal("rune_chosen", rune)
	else:
		emit_signal("rune_chosen", preload("res://runes/blank.tres"))

func update_slots():
	for i in range(min(inv.slots.size(),slots.size())):
		slots[i].update(inv.slots[i])
		slots[i].connect("getRune", Callable(self, "on_get_rune")) 


func _on_attack_pressed():
	emit_signal("attack_pressed")


func _on_lost_confirmed():
	pass # Replace with function body.


func _on_pause_button_down():
	print("paused")
	if get_tree().paused:
		$Pause.visible = false
		get_tree().paused = false
	else:
		$Pause.visible = true
		get_tree().paused = true


func _on_mute_toggled(toggled_on):
	emit_signal("muted",toggled_on)


func _on_back_to_game_button_down():
	$Pause.visible = false
	get_tree().paused = false


func _on_home_button_down():
	$Pause.visible = false
	get_tree().paused = false
	transition_to_level("res://scenes/DEMO.tscn")

func transition_to_level(level_path: String):
	var tween = create_tween()
	var fade = get_node("Fade")
	fade.visible = true
	fade.get_child(1).play("fade_out")
	#tween.tween_property(audio_player, "volume_db", -40, 2.0)  # Fade to 0 dB over 2 seconds
	await fade.get_child(1).animation_finished
	get_tree().change_scene_to_file(level_path)
	



func _on_inv_ui_rune_chosen(runeItem):
	emit_signal("inv_select",runeItem)
