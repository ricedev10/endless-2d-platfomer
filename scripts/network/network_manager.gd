extends Node


var _enet_network = preload("res://scripts/network/enet_network.gd")

func host_game() -> void:
	print("Host game")
	show_loading()
	
func join_game() -> void:
	print("Join game")

func show_loading() -> void:
	print("show loading")
	#var loading_menu: Control = get_tree().current_scene.get_node("LoadingMenu")
	#loading_menu.show()
