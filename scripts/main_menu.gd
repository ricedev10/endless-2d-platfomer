extends CanvasLayer

@export var game_scene: PackedScene

func start_game() -> void:
	#NetworkManager.host_game()
	hide()
	var new_game = game_scene.instantiate()
	add_child(new_game)
	new_game.tree_exited.connect(func(): 
		show()
		print("exit tree")
	)
	
func join_game() -> void:
	print("join game pressed")
	
func quit_game() -> void:
	get_tree().quit(0)
	
var time_started: int
func start_timer() -> void:
	time_started = Time.get_ticks_msec()

func _process(delta: float) -> void:
	pass
