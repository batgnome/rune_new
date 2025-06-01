extends CharacterBody2D

var speed := 10
var pos: Vector2
var rota: float
var start
var max_dist
var sploding = false
var damage =0
func _ready():
	$sploder.visible = false
	global_position = pos
	start = global_position
	rotation = (rota)  # sets the actual rotation of the node
	$Sprite2D.rotation = deg_to_rad(rota+270)
func _physics_process(_delta):
	if global_position.distance_to(start) <= max_dist:
		if not sploding:
			velocity = Vector2(speed, 0).rotated(rotation)
		else:
			velocity = Vector2.ZERO
	else:
		queue_free()
	move_and_slide()

func _unhandled_input(event):
	if event.is_action_pressed("c"):
		$Sprite2D.rotation +=0.5
	if event.is_action_pressed("x"):
		$Sprite2D.rotation -=0.5

func _on_area_2d_area_entered(area):
	if area.get_parent().is_in_group("pl_runes"):
		sploding = true
		$Area2D.get_child(0).disabled = true
		$sploder.visible = true
		$sploder.play()
		await $sploder.animation_finished
		area.get_parent().delete_segments(damage)
		queue_free()

#func _on_sploder_animation_finished():
	
	

