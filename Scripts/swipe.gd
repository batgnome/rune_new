extends CharacterBody2D

var speed := 10
var pos: Vector2
var rota: float
var start
var max_dist
var sploding = false
var damage =0
var enemy
@export var owner_group: String = ""
@export var target_group: String = ""
func _ready():
	add_to_group("bullets")
	add_to_group("damagable")
	$sploder.visible = false
	global_position = pos
	start = global_position
	rotation = (rota)  # sets the actual rotation of the node
	$Sprite2D.rotation = deg_to_rad(rota)
	$Sprite2D.play()
	
	
	
func _physics_process(_delta):
	if global_position.distance_to(start) <= max_dist:
		#if not sploding:
			#velocity = Vector2(speed, 0).rotated(rotation)
		#else:
			#velocity = Vector2.ZERO
			pass
	else:
		if not sploding:
			#velocity = Vector2.ZERO
			sploding = true
			$Area2D/CollisionShape2D.disabled = true
			$sploder.visible = true
			$sploder.play()
			await $sploder.animation_finished
			queue_free()
	move_and_slide()



func _on_area_2d_area_entered(area):
	var node = area

	while node and not node.is_in_group("damagable"):
		node = node.get_parent()
	
	if node and node.is_in_group(target_group):
		sploding = true
		$Area2D/CollisionShape2D.disabled = true
		$sploder.visible = true
		$sploder.play()
		await $sploder.animation_finished
		if is_instance_valid(node):
			node.delete_segments(damage)
		queue_free()

func delete_segments(_damage):
	queue_free()
	
	



func _on_sploder_animation_finished():
	queue_free()


func _on_sprite_2d_animation_finished():
	queue_free()
