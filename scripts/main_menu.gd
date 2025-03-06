extends Control

@onready var timer_label: Label = $TimerLabel


func host_game() -> void:
	print("host game pressed")
	NetworkManager.host_game()
	hide()
	
func join_game() -> void:
	print("join game pressed")
	
func quit_game() -> void:
	get_tree().quit(0)
	
var time_started: int
func start_timer() -> void:
	time_started = Time.get_ticks_msec()

func _process(delta: float) -> void:
	if timer_label:
		var time_passed_in_seconds: float = (Time.get_ticks_msec() - time_started) / 1000.0
		time_passed_in_seconds = floor(time_passed_in_seconds * 100) / 100
		timer_label.text = "time:  " + str(time_passed_in_seconds)
