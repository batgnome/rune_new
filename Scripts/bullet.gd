extends CharacterBody2D

var speed := 200
var pos: Vector2
var rota: float

func _ready():
	global_position = pos
	rotation = rota  # sets the actual rotation of the node
	$Sprite2D.rotation = rota
func _physics_process(_delta):
	velocity = Vector2(speed, 0).rotated(rotation)
	move_and_slide()
