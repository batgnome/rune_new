extends Node2D

@onready var anim = %AnimatedSprite2D
func set_texture(texture):
	$Sprite2D.texture = texture
	


func delete_segments(size):
	get_parent().delete_segments(size)

func add_index(size):
	#$index.text = str(size)
	queue_redraw()
func _ready():
	# Assuming your Sprite2D has a ShaderMaterial
	var viewport_texture = $view_container/SubViewport.get_texture()
	$Sprite2D.material.set_shader_parameter("mask_texture", viewport_texture)
	

func die():
	anim.play("default")
	await wait(0.4)
	queue_free()

func wait(seconds):
	await get_tree().create_timer(seconds).timeout		
