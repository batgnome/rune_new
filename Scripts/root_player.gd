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
@onready var tilemap = $TileMapPlayer

signal get_rune(rune)
# Called when the node enters the scene tree for the first time.
func _init():
	current_state = STATES.GAME
	
func get_tilemap():
	return tilemap

func _ready():
	#$Camera2D.zoom = Vector2(2,2)

	for i in get_child(1).get_children():
		i.connect("rune_set", Callable(ui, "_on_main_get_rune"))
		i.current_state = i.STATE.PRE
	#print(tilemap)
	_init()
func _process(_delta):
	if runes.get_children().size() == 0:
		print("dead")
	if Entities.get_children().size() == 0:
		print("win")
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
	
