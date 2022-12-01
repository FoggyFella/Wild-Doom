extends CanvasLayer

onready var pickup_timer = $"../PickupTimer"
var number_popup = preload("res://Scenes/NumberPopup.tscn")
var amount = 0
var namey = ""
var can_submit = true
var allowed_characters = "[A-Za-z-_0-9]"

func _ready():
	$Label4.text = str(Global.money).pad_zeros(5) + " $"
	Global.connect("money_picked_up",self,"money_picked_up")
	set_defaults()

func message_popup(text,color,shadow):
	var tween = create_tween()
	$Label.text = str(text)
	$Label.set("custom_colors/font_color", color)
	$Label.set("custom_colors/font_color_shadow", shadow)
	tween.tween_property($Label,"rect_scale",Vector2(1,1),0.1)
	tween.tween_interval(2)
	tween.tween_property($Label,"rect_scale",Vector2(1,0),0.1)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		show_pause_screen()
	$time_label.text = str(Global.time_text)
	$TextureProgress.value = lerp($TextureProgress.value,pickup_timer.time_left,0.1)
	$Label2.text = "Health: " + str(Global.stats["player_health"])

func show_death_screen():
	if $PauseMenu.visible == true:
		$PauseMenu.visible = false
	var score_here = Global.enemies_killed + Global.pick_ups
	Global.score = score_here
	if Global.score > Global.high_score:
		Global.high_score = Global.score
		$DeathScreen/VBoxContainer/Label5.text = "New High Score: " + str(Global.high_score)
		emit_confetti()
	else:
		$DeathScreen/VBoxContainer/Label5.text = "High Score: " + str(Global.high_score)
	Global.save_game()
	$DeathScreen.visible = true
	Global.stop_timer()
	get_tree().paused = true
	var tween = create_tween()
	tween.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
	tween.set_trans(Tween.TRANS_CUBIC)
	$DeathScreen/VBoxContainer/Label2.text = "You collected: "+ str(Global.pick_ups) + " pick-ups"
	$DeathScreen/VBoxContainer/Label3.text = "You killed: "+ str(Global.enemies_killed) + " enemies"
	$DeathScreen/VBoxContainer/Label4.text = "Your score: "+ str(Global.score)
	tween.tween_property($DeathScreen,"rect_scale",Vector2(1,1),0.5)


func _on_Button_pressed():
	Global.reset_stats()
	Global.reset_timer()
	Transition.reload_current_scene()

func get_damaged():
	var tween = create_tween()
	tween.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($TextureRect,"modulate",Color(1,1,1,0.58),0.1)
	tween.tween_property($TextureRect,"modulate",Color(1,1,1,0),0.1)

func set_defaults():
	$DeathScreen.visible = false
	$DeathScreen.rect_scale = Vector2(1,0)


func _on_Button2_pressed():
	get_tree().paused = false
	Global.reset_stats()
	Global.reset_timer()
	Transition.change_scene("res://Scenes/Menu.tscn")

func _on_Button3_pressed():
	get_tree().paused = false
	$PauseMenu.visible = false

func show_pause_screen():
	var tip_dic = {
		1:"you can go get yourself a snack or something",
		2:"enemies are angry",
		3:"do you know that paper beats rock?",
		4:"sometimes I... dream about cheese",
		5:"I don't really know what to write here",
		6:"Lava's pretty hot,don't step into it!",
		7:"Go wash your dishes. NOW!",
		8:"This game was made by a human",
		9:"Pineapples on pizza aren't that bad",
		10:"I wrote 10 stupid tips to put here"
	}
	var random_numb = int(rand_range(1,10))
	get_tree().paused = true
	$PauseMenu/Label2.text = tip_dic[random_numb]
	$PauseMenu.visible = true

func update_dash_charge(dash_charge_time):
	var tween = create_tween()
	tween.tween_property($DashCharge,"value",0.0,0.1)
	tween.tween_property($DashCharge,"value",1.0,dash_charge_time)

func money_picked_up(amounti):
	Global.money += amounti
	var money_number = number_popup.instance()
	money_number.amount = str(amounti)
	money_number.type = "Green"
	money_number.position = Vector2(56,10)
	$Label4.text = str(Global.money).pad_zeros(5) + " $"
	$Label4/CenterContainer.add_child(money_number)

func emit_confetti():
	$ConfettiTimer.start()
	$DeathScreen/Confetti1/Confetti.emitting = true
	$DeathScreen/Confetti2/Confetti.emitting = true

func _on_ConfettiTimer_timeout():
	$DeathScreen/Confetti1/Confetti.emitting = false
	$DeathScreen/Confetti2/Confetti.emitting = false
	


func _on_ShowLb_pressed():
	$DeathScreen/Leaderboard.visible = true


func _on_ShowSubmitScreen_pressed():
	$DeathScreen/SubmitScorePanel.show()


func _on_LineEdit_text_changed(new_text):
	var old_caret_position = $DeathScreen/SubmitScorePanel/LineEdit.caret_position
	var word = ''
	var regex = RegEx.new()
	regex.compile(allowed_characters)
	for valid_character in regex.search_all(new_text):
		word += valid_character.get_string()
	$DeathScreen/SubmitScorePanel/LineEdit.set_text(word)
	$DeathScreen/SubmitScorePanel/LineEdit.caret_position = old_caret_position
	namey = str($DeathScreen/SubmitScorePanel/LineEdit.text)
	print(namey)


func _on_ActuallySubmit_pressed():
	if namey != "" and can_submit:
		can_submit = false
		yield(SilentWolf.Scores.persist_score(str(namey),Global.score,"remix"),"sw_score_posted")
		$DeathScreen/SubmitScorePanel.hide()
	elif namey == "":
		$DeathScreen/SubmitScorePanel/ERROR.bbcode_text = "[center][wave amp=20 freq=2]NAME CAN'T BE BLANK!"
		var tween = create_tween().set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
		tween.tween_property($DeathScreen/SubmitScorePanel/ERROR,"modulate",Color(1,1,1,1),0.3)
		tween.tween_interval(2)
		tween.tween_property($DeathScreen/SubmitScorePanel/ERROR,"modulate",Color(1,1,1,0),0.3)
	else:
		$DeathScreen/SubmitScorePanel/ERROR.bbcode_text = "[center][wave amp=20 freq=2]ALREADY SUBMITTED!"
		var tween = create_tween().set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
		tween.tween_property($DeathScreen/SubmitScorePanel/ERROR,"modulate",Color(1,1,1,1),0.3)
		tween.tween_interval(2)
		tween.tween_property($DeathScreen/SubmitScorePanel/ERROR,"modulate",Color(1,1,1,0),0.3)


func _on_LineEdit_text_entered(new_text):
	namey = str(new_text)

func _on_Nvm_pressed():
	$DeathScreen/SubmitScorePanel.hide()

func frenzy_start():
	var tween = create_tween()
	tween.tween_property($FrenzyTexture,"modulate",Color(1,1,1,1),1)

func frenzy_end():
	var tween = create_tween()
	tween.tween_property($FrenzyTexture,"modulate",Color(1,1,1,0),1)
