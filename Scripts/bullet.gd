extends CharacterBody2D

var speed := 10
var pos: Vector2
var rota: float
var start
var max_dist
func _ready():
	global_position = pos
	start = global_position
	rotation = (rota)  # sets the actual rotation of the node
	$Sprite2D.rotation = deg_to_rad(rota+270)
func _physics_process(_delta):
	if global_position.distance_to(start) <= max_dist:
		velocity = Vector2(speed, 0).rotated(rotation)
	else:
		queue_free()
	move_and_slide()
		



func _unhandled_input(event):
	if event.is_action_pressed("c"):
		$Sprite2D.rotation +=0.5
	if event.is_action_pressed("x"):
		$Sprite2D.rotation -=0.5


func _on_area_2d_area_entered(area):
	if area.get_parent().get_parent().is_in_group("pl_runes"):
		queue_free()
