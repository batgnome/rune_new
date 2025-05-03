extends Resource

class_name Inv

@export var slots: Array[inv_slot]

signal update

func insert(item: InvItem): 
	var itemSlots = slots.filter(func(slot): return slot.item == item)
	if !itemSlots.is_empty():
		itemSlots[0].amount +=1
	else:
		var emptyslots = slots.filter(func(slot): return slot.item ==null)
		if !emptyslots.is_empty():
			emptyslots[0].item = item
			emptyslots[0].amount = 1
	update.emit()
