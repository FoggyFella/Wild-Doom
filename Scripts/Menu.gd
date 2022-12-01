extends Control

func _on_PlayButton_pressed():
	Transition.change_scene("res://Scenes/World.tscn")


func _on_Quit_pressed():
	Global._notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)


func _on_CreditsButton_pressed():
	Transition.change_scene("res://Scenes/Credits.tscn")


func _on_ShopButton_pressed():
	Transition.change_scene("res://Scenes/Shop.tscn")
