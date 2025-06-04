extends Node2D

enum STATES  {
	PRE,
	GAME,
	PAUSE
}
var current_state

var rune
@onready var runes = $runes
@onready var Entities = $Entities
@onready var ui = %Main_Ui
@onready var tilemap = %TileMapPlayer
@onready var audio_player = $"../AudioStreamPlayer2D"
signal get_rune(rune)
# Called when the node enters the scene tree for the first time.
func _init():
	current_state = STATES.GAME
	
func get_tilemap():
	return tilemap

func _ready():
	audio_player.volume_db = -40  # Start muted
	audio_player.play()

	var tween = create_tween()
	tween.tween_property(audio_player, "volume_db", 0, 2.0)  # Fade to 0 dB over 2 seconds
	tilemap = $TileMapPlayer
	for i in get_child(1).get_children():
		i.connect("rune_set", Callable(ui, "_on_main_get_rune"))
		i.current_state = i.STATE.PRE
	_init()
func _process(_delta):
	if runes.get_children().size() == 0:
		%lost.popup_centered()
		pause_bullets()
		pass
	if Entities.get_children().size() == 0:
		%Win.popup_centered()
		pause_bullets()
		pass
		
func _on_main_ui_start():
	if current_state == STATES.PRE:
		for i in runes.get_children():
			if i.CURRENT_STATE == i.STATE.BUILD:
				i.CURRENT_STATE = i.STATE.PRE
		for i in Entities.get_children():
			if i.CURRENT_STATE == i.STATE.BUILD:
				i.CURRENT_STATE = i.STATE.PRE
		current_state = STATES.GAME
		#tilemap.queue_redraw()
	else:
		for i in runes.get_children():
			if i.rune_name =="blank":
				%AlertDialogue.popup_centered()
				return
		_start_game()

func _on_alert_dialogue_confirmed():
	_start_game()
	
func _start_game():
	ui._hide_start()
	for i in runes.get_children():
		i.current_state = i.STATE.MOVE
		rune.set_rune(rune)
		if i.rune_name == "blank":
			i.queue_free()
	for i in Entities.get_children():
		i.clock.start(4)
	#set_enem_first()

func set_enem_first():
	var closest_enem = 10000
	var enem_start
	for e in Entities.get_children():
		if e.active:
			if e.get_nearest_rune() < closest_enem:
				closest_enem =  e.get_nearest_rune()
				enem_start=e
	if enem_start:
		$"../CanvasLayer/active".text = enem_start.name
		enem_start.playing = true
	


func _on_main_ui_attack_pressed():
	if is_instance_valid(rune):
		if rune.current_state == rune.STATE.MOVE:
			rune.current_state = rune.STATE.ATTACK
			rune.clock.start(rune.TIMER_SPEED)

func _on_win_confirmed():
	Global.current_level = max(Global.current_level, 2)
	Global.levels_unlocked = max(Global.levels_unlocked, 2)  # unlock next
	Global.save()
	print(Global.levels_unlocked)
	transition_to_level("res://scenes/DEMO.tscn")

func _on_lost_confirmed():
	transition_to_level("res://scenes/DEMO.tscn")

func transition_to_level(level_path: String):
	var tween = create_tween()
	%Fade.visible = true
	%Fade.get_child(1).play("fade_out")
	tween.tween_property(audio_player, "volume_db", -40, 2.0)  # Fade to 0 dB over 2 seconds
	await %Fade.get_child(1).animation_finished
	get_tree().change_scene_to_file(level_path)
	
func pause_bullets():
	for bullet in get_tree().get_nodes_in_group("bullets"):
		if is_instance_valid(bullet):
			bullet.queue_free()

