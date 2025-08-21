extends Node2D

@onready var enemies = get_children()
var current_enem
var parent
var _running := false

func _ready():
	parent = get_parent()
	current_enem =   select_playing_enemy()
	_running = true
	run_controller()
	
func _exit_tree():
	_running = false
func _process(_delta):
	pass
	#await run_controller()
	
		

func run_controller() -> void:
	while _running:
		# (1) Ensure we always yield each loop so we never lock the thread
		await wait(0.5)  # or:  for a fixed tick

		# (2) Pick/repick enemy as needed
		if current_enem == null or not is_instance_valid(current_enem) or current_enem.CURRENT_STATE == current_enem.STATE.INACTIVE:
			current_enem = await select_playing_enemy()
			continue

		# (3) Drive the current enemy one step
		if is_instance_valid(current_enem):
			match current_enem.CURRENT_STATE:
				current_enem.STATE.MOVE:
					if not current_enem.playing:
						current_enem.take_turn()
				current_enem.STATE.ATTACK:
					current_enem.active = false
				# add other states as needed

		# (4) Optional pacing between enemy “ticks”
		# await wait(0.1)
	
func select_playing_enemy():
	wait(10)
	var closest_enem = 10000
	var enem = null
	for e in enemies:
		if not is_instance_valid(e):
			continue
		if e.CURRENT_STATE == e.STATE.WAITING:
			
			var dist = e.get_nearest_rune()[0]
			if dist < closest_enem:
				closest_enem = dist
				enem = e
	if is_instance_valid(enem):
		enem.CURRENT_STATE = enem.STATE.MOVE
	
	return enem

func wait(seconds):
	await get_tree().create_timer(seconds).timeout
