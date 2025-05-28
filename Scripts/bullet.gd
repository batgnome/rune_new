extends CharacterBody2D

var speed := 3
var pos: Vector2
var rota: float
var dir: float
# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = pos
	global_rotation = rota
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity=Vector2(speed,0).rotated(dir)
	move_and_slide()

func shoot(pos):
	var angle = get_angle_to(pos)
