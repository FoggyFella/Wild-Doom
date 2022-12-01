extends ColorRect

var should_play = true

func _ready():
	Textbox.queue_text("It was a fine saturday evening. As always our hero was smoking some weed, but then...    unspeakable happened")
	Textbox.queue_text("A DEVIL appeared in his room, offering him the worst deal imaginable: 'I will make you HIGH forever, but you will have to do my dirty work in HELL'")
	Textbox.queue_text("To which the hero replied: 'Yea dude, sure. Nice costume btw.'")
	Textbox.queue_text("'It's not a costume you bonehead'")
	Textbox.queue_text("So they shook their hands, and our hero began his journey.")

func _process(delta):
	if Textbox.text_queue == [] and should_play:
		should_play = false
		var tween = create_tween()
		tween.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
		tween.tween_property($"intro music","volume_db",-60.0,3)
		yield(tween,"finished")
		Transition.change_scene('res://Scenes/Menu.tscn')
		Music.fade_in(3)
	if Input.is_action_just_pressed("click"):
		print("chicken")
		var tween = create_tween()
		tween.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
		tween.tween_property($SkipButton,"modulate",Color(1,1,1,1),1)
		$Timer.start()


func _on_SkipButton_pressed():
	if $SkipButton.modulate == Color(1,1,1,1):
		$SkipButton.hide()
		Textbox.hide_textbox()
		var tween = create_tween()
		tween.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
		tween.tween_property($"intro music","volume_db",-60.0,3)
		yield(tween,"finished")
		Transition.change_scene('res://Scenes/Menu.tscn')
		Music.fade_in(3)


func _on_Timer_timeout():
	var tween = create_tween()
	tween.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($SkipButton,"modulate",Color(1,1,1,0),0.5)
