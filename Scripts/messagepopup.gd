extends CanvasLayer

onready var pickup_timer = $"../PickupTimer"
onready var upgrade_afer_wave = $UpgradeAferWave
var number_popup = preload("res://Scenes/NumberPopup.tscn")
var amount = 0
var namey = ""
var can_submit = true
var allowed_characters = "[A-Za-z-_0-9]"
var boss_thing = 100.0

func _ready():
	$Cash/Label4.text = str(Global.money)#.pad_zeros(5)
	$Ruby/Label4.text = str(Global.settings["rubys"])#.pad_zeros(5)
	Global.connect("money_picked_up",self,"money_picked_up")
	Global.connect("ruby_collected",self,"on_ruby_collected")
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
	Global.stop_timer()
	if Music.current_music == "Boss":
		Music.fade_in("Chapter1",1,-10,"Boss",3)
	if $PauseMenu.visible == true:
		$PauseMenu.visible = false
	$UpgradeAferWave.hide()
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
	get_tree().paused = true
	var tween = create_tween()
	tween.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
	tween.set_trans(Tween.TRANS_CUBIC)
	$DeathScreen/VBoxContainer/Label2.text = "You collected: "+ str(Global.pick_ups) + " pick-ups"
	$DeathScreen/VBoxContainer/Label3.text = "You killed: "+ str(Global.enemies_killed) + " enemies"
	$DeathScreen/VBoxContainer/Label4.text = "Your score: "+ str(Global.score)
	tween.tween_property($DeathScreen,"rect_scale",Vector2(1,1),0.5)
	$DeathScreen/Button.grab_focus()


func _on_Button_pressed():
	Global.stop_timer()
	Global.reset_stats()
	Global.reset_timer()
	Transition.reload_current_scene()
	if Music.current_music == "Boss":
		Music.fade_in("Chapter1",1,-10,"Boss",3)

func get_damaged():
	var tween = create_tween()
	tween.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($TextureRect,"modulate",Color(1,1,1,0.58),0.1)
	tween.tween_property($TextureRect,"modulate",Color(1,1,1,0),0.1)

func set_defaults():
	$DeathScreen.visible = false
	$DeathScreen.rect_scale = Vector2(1,0)
	$UpgradeAferWave.hide()

func after_wave_upgrade():
	get_tree().paused = true
	upgrade_afer_wave.show()
	upgrade_afer_wave.get_node("Error").hide()
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(upgrade_afer_wave,"modulate",Color(1,1,1,1),0.4)
	yield(tween,"finished")
	upgrade_afer_wave.roll_upgrades()

func _on_Button2_pressed():
	if Music.current_music == "Boss":
		Music.fade_in("Game",1,-10,"Boss",3)
	elif Music.current_music == "Chapter1":
		Music.fade_in("Game",1,-10,"Chapter1",3)
	get_tree().paused = false
	Global.stop_timer()
	Global.reset_stats()
	Global.reset_timer()
	Transition.change_scene("res://Scenes/Menu.tscn")

func _on_Button3_pressed():
	get_tree().paused = false
	$PauseMenu.visible = false

func show_pause_screen():
	var rng = RandomNumberGenerator.new()
	var tip_dic = {
		1:"you can go get yourself a snack or something",
		2:"enemies are angry",
		3:"do you know that paper beats rock?",
		4:"sometimes I... dream about cheese",
		5:"I don't really know what to write here",
		6:"Lava's pretty hot,don't step into it!",
		7:"Go wash your dishes. NOW!",
		8:"This game was made by humans (probably)",
		9:"Pineapples on pizza aren't that bad",
		10:"I wrote 20 stupid things to put here",
		11:"Potato,potato,potato",
		12:"How's your day going?",
		13:"Merry Christmas! (don't put in the game)",
		14:"Damn.",
		15:"easy peasy lemon squeezy",
		16:"Hello there!",
		17:"The demons are patiently waiting",
		18:"The devil awaits",
		19:"It sure is hot around here",
		20:"This is a very secret message if you see it then you're cool",
	}
	rng.randomize()
	var random_numb = rng.randi_range(1,tip_dic.size())
	get_tree().paused = true
	$PauseMenu/Label2.text = tip_dic[random_numb]
	$PauseMenu.visible = true
	$PauseMenu/VBoxContainer/Button3.grab_focus()

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
	$Cash/Label4.text = str(Global.money)#.pad_zeros(5)
	$Cash/Label4/CenterContainer.add_child(money_number)

func on_ruby_collected(amounti):
	var ruby_number = number_popup.instance()
	ruby_number.amount = str(amounti)
	ruby_number.type = "Red"
	ruby_number.position = Vector2(56,10)
	$Ruby/Label4.text = str(Global.settings["rubys"])#.pad_zeros(5)
	$Ruby/Label4/CenterContainer.add_child(ruby_number)
	
func emit_confetti():
	$ConfettiTimer.start()
	$DeathScreen/Confetti1/Confetti.emitting = true
	$DeathScreen/Confetti2/Confetti.emitting = true

func _on_ConfettiTimer_timeout():
	$DeathScreen/Confetti1/Confetti.emitting = false
	$DeathScreen/Confetti2/Confetti.emitting = false

func _on_ShowLb_pressed():
	$DeathScreen/Leaderboard.visible = true
	$DeathScreen/Leaderboard/Button.grab_focus()


func _on_ShowSubmitScreen_pressed():
	$DeathScreen/SubmitScorePanel.show()
	$DeathScreen/SubmitScorePanel/ActuallySubmit.grab_focus()


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


func _on_ActuallySubmit_pressed():
	if namey != "" and can_submit:
		var metadata = {
			"weapon" : Global.equipped_weapon,
			"enemies" : Global.enemies_killed,
			"pickups" : Global.pick_ups}
		can_submit = false
		yield(SilentWolf.Scores.persist_score(str(namey),Global.score,"main",metadata),"sw_score_posted")
		#TEST THE THING BELOW
		yield(SilentWolf.Scores.get_high_scores(50,"main"), "sw_scores_received")
		$DeathScreen/SubmitScorePanel.hide()
		$DeathScreen/HBoxContainer/ShowSubmitScreen.grab_focus()
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
	$DeathScreen/HBoxContainer/ShowSubmitScreen.grab_focus()

func frenzy_start():
	var tween = create_tween()
	tween.tween_property($FrenzyTexture,"modulate",Color(1,1,1,1),1)

func frenzy_end():
	var tween = create_tween()
	tween.tween_property($FrenzyTexture,"modulate",Color(1,1,1,0),1)

func enable_boss_health():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($BossHealth,"rect_scale",Vector2(1,1),0.5)

func update_boss_health(damage_taken):
	boss_thing -= float(damage_taken)
	$BossHealth/Label.text = str(int(boss_thing)) + "%"#str(float($BossHealth/Label.text) - float(damage_taken)) + "%"#str(round(float($BossHealth/Label.text) - damage_taken)) + "%"
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($BossHealth,"value",float($BossHealth/Label.text),0.1)

func boss_dead():
	$BossDeath.play()
	var tween = create_tween()
	$BossHealth/Label.text = str(0) + "%"
	$BossHealth.set_value(0.0)
	Global.settings["beat_gorilla"] = true
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_interval(4)
	tween.tween_property($BossHealth,"rect_scale",Vector2(1,0),0.5)
	Music.fade_in("Chapter1",3,-10,"Boss",3)

func change_wave_text(wave):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CIRC)
	$VBoxContainer/WaveLabel.text = "WAVE " + str(wave)
	$VBoxContainer/WaveLine.visible = false
	tween.tween_property($VBoxContainer/WaveLabel,"rect_scale",Vector2(1.2,1.2),0.2)
	tween.tween_property($VBoxContainer/WaveLabel,"rect_scale",Vector2(1,1),0.2)

func change_to_waiting():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	$VBoxContainer/WaveLabel.text = "Prepare for next wave"
	$VBoxContainer/WaveLine.rect_scale = Vector2(1,1)
	$VBoxContainer/WaveLine.visible = true
	tween.tween_property($VBoxContainer/WaveLine,"rect_scale",Vector2(0,1),5)
