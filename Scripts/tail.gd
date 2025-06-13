extends Node2D

@onready var anim = %death_anim
func set_texture(texture,scale):
	$Sprite2D.texture = texture
	$Sprite2D.apply_scale(Vector2.ONE*(20.0/scale))

func delete_segments(size):
	get_parent().delete_segments(size)

func add_index(_size):
	#$index.text = str(size)
	queue_redraw()
func _ready():
	var mat = $Sprite2D.material.duplicate()
	$Sprite2D.material = mat
	mat.set_shader_parameter("mask_texture", $view_container/SubViewport.get_texture())


func die():
	anim.play()  # Or whatever your animation is named
	await anim.animation_finished
	

func _on_animated_sprite_2d_animation_finished():
	queue_free()
