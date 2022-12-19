extends Control

func _on_PlayButton_pressed():
	$click.play()
	Transition.change_scene("res://Scenes/World.tscn")

func _on_Quit_pressed():
	$click.play()
	Global._notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)

func _on_CreditsButton_pressed():
	$click.play()
	Transition.change_scene("res://Scenes/Credits.tscn")


func _on_ShopButton_pressed():
	$click.play()
	Transition.change_scene("res://Scenes/Shop.tscn")


func _on_OptionsButton_pressed():
	$click.play()
	Transition.change_scene("res://Scenes/Options.tscn")

func _process(delta):
	if Input.is_action_just_pressed("ui_down"):
		$move.pitch_scale = 0.9
		$move.play()
	if Input.is_action_just_pressed("ui_up"):
		$move.pitch_scale = 1.1
		$move.play()
