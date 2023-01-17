extends Control

func _unhandled_input(event):
	if event.is_action_released("ui_accept"):
		if Global.settings["saw_intro"] == false:
			Transition.change_scene("res://Scenes/Intro.tscn")
		else:
			Music.fade_in("Game",3,-10)
			Transition.change_scene("res://Scenes/Menu.tscn")

func _on_AnimationPlayer_animation_finished(anim_name):
	if Global.settings["saw_intro"] == false:
		Transition.change_scene("res://Scenes/Intro.tscn")
	else:
		Music.fade_in("Game",3,-10)
		Transition.change_scene("res://Scenes/Menu.tscn")
