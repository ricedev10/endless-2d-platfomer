extends Control


func host_game() -> void:
	print("host game pressed")
	NetworkManager.host_game()
	
func join_game() -> void:
	print("join game pressed")
	
func quit_game() -> void:
	get_tree().quit(0)
