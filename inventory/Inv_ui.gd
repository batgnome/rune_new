extends Control

#@onready var inv: RuneInv = preload("res://runes/runeInventory.tres")
@onready var inv: RuneInv = preload("res://runes/TEST_INV.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()
var is_open = false
var select: runeItem
signal rune_chosen(runeItem)
signal close_button()

func _ready():
	self.mouse_filter = Control.MOUSE_FILTER_STOP
	#inv.update.connect(update_slots)
	update_slots()
	close()

func on_get_rune(rune):
	if rune:
		emit_signal("rune_chosen", rune)
	else:
		emit_signal("rune_chosen", preload("res://runes/blank.tres"))

func update_slots():
	for i in range(min(inv.slots.size(),slots.size())):
		slots[i].update(inv.slots[i])
		slots[i].connect("getRune", Callable(self, "on_get_rune")) 
		

func open():
	self.mouse_filter = Control.MOUSE_FILTER_STOP
	visible = true
	is_open = true
	
	
func close():
	visible = false
	is_open = false

func _on_close_button_pressed():
	emit_signal("rune_chosen", preload("res://runes/blank.tres"))
	emit_signal("close_button")


func _on_confirm_pressed():
	emit_signal("close_button")
