extends Node2D

enum STATES  {
	ACTIVE,
	GAME,
	PAUSE
}
enum TURN {PLAYER,ENEMY}
var turn_state
var current_state
var tilemap
var rune
@onready var runes = $runes
@onready var Entities = $Entities
@onready var ui = %Main_Ui

signal get_rune(rune)
# Called when the node enters the scene tree for the first time.
func _init():
	turn_state =TURN.PLAYER
	current_state = STATES.ACTIVE
	tilemap = $TileMap
	
func get_tilemap():
	return tilemap

func _ready():
	#$Camera2D.zoom = Vector2(2,2)

	for i in get_child(0).get_children():
		i.connect("rune_set", Callable(ui, "_on_main_get_rune"))
	_init()
	
func _on_main_ui_start():
	if current_state == STATES.ACTIVE:
		for i in runes.get_children():
			if i.CURRENT_STATE == i.STATE.BUILD:
				i.CURRENT_STATE = i.STATE.ACTIVE
		for i in Entities.get_children():
			if i.CURRENT_STATE == i.STATE.BUILD:
				i.CURRENT_STATE = i.STATE.ACTIVE
		current_state = STATES.GAME
		tilemap.queue_redraw()
	else:
		for i in runes.get_children():
			if i.Rname =="blank":
				%AlertDialogue.popup_centered()
				return
		_start_game()

func _on_alert_dialogue_confirmed():
	_start_game()
	
func _start_game():
	ui._hide_start()
	for i in runes.get_children():
		i.CURRENT_STATE = i.STATE.MOVE
		rune.set_rune(rune)
		if i.Rname == "blank":
			i.queue_free()
