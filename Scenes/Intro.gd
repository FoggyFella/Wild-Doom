extends ColorRect

var should_play = true

func _ready():
	Music.fade_in("Intro",1,-10)
	Textbox.connect("finished",self,"on_intro_finished")
	Textbox.queue_text("There is gonna be story here but I'm too lazy to write it for now")

func _process(delta):
	if Input.is_action_just_pressed("click"):
		var tween = create_tween()
		tween.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
		tween.tween_property($SkipButton,"modulate",Color(1,1,1,1),1)
		$Timer.start()


func _on_SkipButton_pressed():
	if $SkipButton.modulate == Color(1,1,1,1):
		$SkipButton.hide()
		Textbox.hide_textbox()
		Transition.change_scene('res://Scenes/Menu.tscn')
		Music.fade_in("Game",1,-10,"Intro",3)

func on_intro_finished():
	Transition.change_scene('res://Scenes/Menu.tscn')
	Music.fade_in("Game",1,-10,"Intro",3)

func _on_Timer_timeout():
	var tween = create_tween()
	tween.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($SkipButton,"modulate",Color(1,1,1,0),0.5)
