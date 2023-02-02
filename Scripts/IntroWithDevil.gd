extends Node2D

var pistol = preload("res://Scenes/Pistol.tscn")
var chest = preload("res://Scenes/pick_up.tscn")
var walker = preload("res://Scenes/Walker Enemy.tscn")
var should_wait = false
var current_thing = null
var on_mouse = true

func _ready():
	$CanvasLayer/BlackScreen.show()
	$Player/AnimationPlayer.play("guy idle")
	var tween = create_tween()
	Textbox.connect("stand",self,"on_stand")
	Textbox.connect("nope_finished",self,"on_nope_finished")
	Textbox.connect("time_to_choose",self,"on_choice")
	Textbox.connect("begin_tutorial",self,"begin_tutorial")
	tween.set_trans(Tween.TRANS_CUBIC)
	$Player.get_node("GunRoot").queue_free()
	$Player.can_move = false
	$Player.should_move_camera = false
	$Player.can_be_hurt = false
	Music.fade_in("Noise",3,-15)
	tween.tween_property($CanvasLayer/BlackScreen,"modulate",Color(1,1,1,0),2)
	yield(get_tree().create_timer(3),"timeout")
	$Devil.play("Devil_Sit")
	yield(get_tree().create_timer(1),"timeout")
	Textbox.queue_text(["...","Colt"])
	Textbox.queue_text(["Well... that was your worst duel ever, Colt","???"])
	Textbox.queue_text(["Where am I and who are you?","Colt"])
	Textbox.queue_text(["This is hell and I am the one who controls it","???"])
	Textbox.queue_text(["The Devil?","Colt"])
	Textbox.queue_text(["Exactly","The Devil"])
	Textbox.queue_text(["As you could probably tell, I've been following you for a long time","The Devil"])
	Textbox.queue_text(["And I know that you killed many while you were alive","The Devil"])
	Textbox.queue_text(["Now I should send you to other sinful souls for your eternal torment","The Devil"])
	Textbox.queue_text(["But your masterful aim and frigidity have impressed me","The Devil"])
	Textbox.queue_text(["So...","The Devil"])
	Textbox.queue_text(["I have a deal for you","The Devil"])
	Textbox.queue_text(["If you can defeat four supreme demons including me","The Devil"])
	Textbox.queue_text(["I will make you alive again and you will have the chance to get your revenge","The Devil"])
	Textbox.queue_text(["What do you say?","The Devil"])
	Textbox.queue_text(["Well I don't think I have a choice here so...","Colt"])
	Textbox.queue_text(["I accept the deal","Colt"])
	Textbox.queue_text(["Perfect!","The Devil"])
	Textbox.queue_text(["But don't expect this to be easy, these demons are known for their strength","The Devil"])
	Textbox.queue_text(["Now... would you like to know the rules?","The Devil"])

func on_stand():
	$Devil.play("Devil_Stand_UP")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _process(delta):
	if should_wait and $Enemies.get_child_count() == 0:
		should_wait = false
		yield(get_tree().create_timer(3),"timeout")
		Transition.white_transition('res://Scenes/World.tscn')
		Music.fade_in("Chapter1",1,-10,"Noise",3)
		Global.settings["saw_intro"] = true
	if current_thing != null:
		if on_mouse:
			current_thing.get_node("Keyboard").show()
			current_thing.get_node("Joy").hide()
		else:
			current_thing.get_node("Keyboard").hide()
			current_thing.get_node("Joy").show()

func begin_tutorial():
	yield(Textbox,"finished")
	$Light2D2.queue_free()
	$CanvasLayer/CanvasLayer/Glitch.queue_free()
	$Player.can_move = true
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Devil,"modulate",Color(1,1,1,0),0.3)
	tween.tween_property($Player/Movement,"modulate",Color(1,1,1,1),0.5)
	current_thing = $Player/Movement
	tween.tween_interval(3)
	tween.tween_property($Player/Movement,"modulate",Color(1,1,1,0),0.5)
	tween.tween_interval(2)
	yield(tween,"finished")
	var tween2 = create_tween()
	$Camera2D.current = false
	$Player/Camera2D.current = true
	$Player.should_move_camera = true
	tween2.tween_property($Player/Aim,"modulate",Color(1,1,1,1),0.5)
	current_thing = $Player/Aim
	tween2.tween_interval(3)
	tween2.tween_property($Player/Aim,"modulate",Color(1,1,1,0),0.5)
	tween2.tween_interval(2)
	yield(tween2,"finished")
	var tween3 = create_tween()
	give_gun()
	tween3.tween_property($Player/Shoot,"modulate",Color(1,1,1,1),0.5)
	current_thing = $Player/Shoot
	tween3.tween_interval(3)
	tween3.tween_property($Player/Shoot,"modulate",Color(1,1,1,0),0.5)
	tween3.tween_interval(2)
	yield(tween3,"finished")
	var tween4 = create_tween()
	$UI.show()
	tween4.tween_property($Player/Dash,"modulate",Color(1,1,1,1),0.5)
	current_thing = $Player/Dash
	tween4.tween_interval(3)
	tween4.tween_property($Player/Dash,"modulate",Color(1,1,1,0),0.5)
	yield(get_tree().create_timer(4),"timeout")
	current_thing = null
	var tween5 = create_tween()
	tween5.set_trans(Tween.TRANS_CUBIC)
	tween5.tween_property($PickUps/ChestSpawn/Text,"modulate",Color(1,1,1,1),0.5)
	var chest_inst = chest.instance()
	chest_inst.monitorable = false
	chest_inst.monitoring = false
	$PickUps/ChestSpawn.add_child(chest_inst)
	chest_inst.get_node("diss").stop()
	
func _on_Yeah_pressed():
	$CanvasLayer/TutorialOptions.hide()
	Textbox.queue_text(["Follow along","The Devil"])


func _on_Nope_pressed():
	$CanvasLayer/TutorialOptions.hide()
	Textbox.queue_text(["Hmm... let's get right into it then","The Devil"])

func on_nope_finished():
	yield(Textbox,"finished")
	Textbox.hide_textbox()
	Transition.white_transition('res://Scenes/World.tscn')
	Music.fade_in("Chapter1",1,-10,"Noise",3)
	Global.settings["saw_intro"] = true

func on_choice():
	yield(Textbox,"finished")
	$CanvasLayer/TutorialOptions.show()
	$CanvasLayer/TutorialOptions/O/HBoxContainer2/Yeah.grab_focus()

func give_gun():
	var root = Node2D.new()
	var pistol_inst = pistol.instance()
	root.name = "GunRoot"
	$Player.add_child(root)
	root.add_child(pistol_inst)
	$item2.play()


func _on_Area2D_body_entered(body):
	if body.name == "Player":
		var tween = create_tween()
		$Player.should_show_arrow = false
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property($PickUps/ChestSpawn,"modulate",Color(1,1,1,0),0.2)
		yield(tween,"finished")
		$PickUps/ChestSpawn.queue_free()
		yield(get_tree().create_timer(1),"timeout")
		var tween3 = create_tween()
		tween3.set_trans(Tween.TRANS_CUBIC)
		tween3.tween_property($UI/ChestProgress,"modulate",Color(1,1,1,1),0.5)
		tween3.tween_interval(5)
		tween3.tween_property($UI/ChestProgress,"modulate",Color(1,1,1,0),0.5)
		tween3.tween_interval(1)
		yield(tween3,"finished")
		var tween2 = create_tween()
		tween2.set_trans(Tween.TRANS_CUBIC)
		tween2.tween_property($Player/Kill,"modulate",Color(1,1,1,1),0.5)
		tween2.tween_interval(3)
		tween2.tween_property($Player/Kill,"modulate",Color(1,1,1,0),0.5)
		yield(tween2,"finished")
		var num = 0
		for enemy in range(3):
			num += 1
			var enemy_inst = walker.instance()
			enemy_inst.global_position = get_node("Spawn" + str(num)).global_position
			$Enemies.add_child(enemy_inst)
			yield(get_tree().create_timer(1),"timeout")
		should_wait = true

func _input(event):
	if event is InputEventMouseMotion:
		if current_thing != null:
			on_mouse = true
			current_thing.get_node("Keyboard").show()
			current_thing.get_node("Joy").hide()
	if event is InputEventJoypadButton:
		if current_thing != null:
			on_mouse = false
			current_thing.get_node("Keyboard").hide()
			current_thing.get_node("Joy").show()
