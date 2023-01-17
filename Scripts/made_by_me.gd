extends Control

func _unhandled_input(event):
	if event.is_action_released("ui_accept"):
		Transition.change_scene("res://Scenes/Intro.tscn")
