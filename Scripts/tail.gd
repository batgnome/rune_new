extends Node2D

@onready var anim = %AnimatedSprite2D
func set_texture(texture):
	$Sprite2D.texture = texture
	


func delete_segments(size):
	get_parent().delete_segments(size)

func add_index(_size):
	#$index.text = str(size)
	queue_redraw()
func _ready():
	# Assuming your Sprite2D has a ShaderMaterial

	var viewport_texture = $view_container/SubViewport.get_texture()
	$Sprite2D.material.set_shader_parameter("mask_texture", viewport_texture)
	$Sprite2D.material = $Sprite2D.material.duplicate()
	

func die():
	anim.play()  # Or whatever your animation is named
	await anim.animation_finished
	queue_free()
	



func _on_animated_sprite_2d_animation_finished():
	queue_free()
