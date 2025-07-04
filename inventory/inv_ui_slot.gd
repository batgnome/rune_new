extends Panel

@onready var item_visual: Sprite2D = $CenterContainer/Panel/item_display
@onready var amount_text: Label = $CenterContainer/Panel/Label

var rune: runeItem
signal getRune(runeItem)
func update(slot: runeSlots):
	if !slot.rune:
		item_visual.visible = false
		amount_text.visible = false
	else:
		item_visual.visible = true
		rune = slot.rune
		
		item_visual.texture = slot.rune.texture
		if item_visual.texture.get_size() > Vector2.ONE *20:
			item_visual.scale = (Vector2.ONE * 20.0/rune.tile_size)*0.7
		else:
			item_visual.scale = Vector2.ONE*0.7
		amount_text.visible = true
		if slot.amount < 0:
			amount_text.text = "∞"
		else:
			amount_text.text = str(slot.amount)
		



func _on_button_button_down():
	if rune:
		emit_signal("getRune",rune)
	else:
		emit_signal("getRune",preload("res://runes/blank.tres"))
