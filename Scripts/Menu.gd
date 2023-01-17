extends Control

var potato = preload("res://Scenes/PotatoRigid.tscn")

func _ready():
	if !Global.settings["beat_gorilla"]:
		$VBoxContainer/ShopButton.disabled = true
	if Music.get_node("Game").playing == false and Music.get_node("Game").volume_db == -60 and Music.current_music != "Game":
		Music.get_node("Game").playing = true
		Music.get_node("Game").volume_db = -10

func _on_PlayButton_pressed():
	$click.play()
	Transition.change_scene("res://Scenes/ChapterChoice.tscn")

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
	
func _on_ShopButton_focus_entered():
	if !Global.settings["beat_gorilla"]:
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property($VBoxContainer/ShopButton/DefeatLabel,"rect_scale",Vector2(1,1),0.3)
	
func _on_ShopButton_focus_exited():
	if !Global.settings["beat_gorilla"]:
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property($VBoxContainer/ShopButton/DefeatLabel,"rect_scale",Vector2(1,0),0.3)


func _on_SecretButton_pressed():
	$spawn.play()
	var potato_inst = potato.instance()
	potato_inst.global_position = $Dispenser/Sprite.global_position
	potato_inst.scale.x = rand_range(0.95,1.1)
	potato_inst.scale.y = potato_inst.scale.x
	potato_inst.rotation_degrees = rand_range(-360,360)
	get_tree().current_scene.add_child(potato_inst,true)
