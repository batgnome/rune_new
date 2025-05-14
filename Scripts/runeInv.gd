extends Resource

class_name RuneInv

@export var slots: Array[runeSlots]

signal update

func insert(rune: runeItem): 
	var itemSlots = slots.filter(func(slot): return slot.rune == rune)
	if !itemSlots.is_empty():
		itemSlots[0].amount +=1
	else:
		var emptyslots = slots.filter(func(slot): return slot.rune ==null)
		if !emptyslots.is_empty():
			emptyslots[0].rune = rune
			emptyslots[0].amount = 1
	update.emit()
	
func add(rune: runeItem): 
	var itemSlots = slots.filter(func(slot): return slot.rune == rune)
	if !itemSlots.is_empty():
		itemSlots[0].amount +=1
	
	update.emit()
	
func sub(rune: runeItem): 
	var itemSlots = slots.filter(func(slot): return slot.rune == rune)
	if !itemSlots.is_empty():
		itemSlots[0].amount -=1
	
	update.emit()

func get_amount(rune: runeItem):
	var itemSlots = slots.filter(func(slot): return slot.rune == rune)
	if !itemSlots.is_empty():
		return itemSlots[0].amount
