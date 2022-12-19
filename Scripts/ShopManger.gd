extends Control

var max_x = 0
var clicks = 0
var max_clicks = 0
var number_popup = preload("res://Scenes/NumberPopup.tscn")
var music_bus = AudioServer.get_bus_index("MusicBus")

func _ready():
	AudioServer.set_bus_effect_enabled(music_bus,0,true)
	Global.connect("money_picked_up",self,"on_bought")
	$AmountOmoney.text = str(Global.money).pad_zeros(5) + " $"
	var number = $Control/ItemContainer.get_child_count() * 300
	for child in $Control/ItemContainer.get_child_count():
		if child != 1:
			number += 600
	max_x = number-900
	max_clicks = $Control/ItemContainer.get_child_count()-1
	$HBoxContainer/PreviousButton.disabled = true


func _on_PreviousButton_pressed():
	$switch.pitch_scale = 0.95
	$switch.play()
	clicks -= 1
	set_focus_approp()
	$HBoxContainer/NextButton.disabled = true
	$HBoxContainer/PreviousButton.disabled = true
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Control/ItemContainer,"rect_position",Vector2($Control/ItemContainer.rect_position.x + 900,$Control/ItemContainer.rect_position.y),0.3)
	yield(tween,"finished")
	$HBoxContainer/NextButton.disabled = false
	if clicks != 0:
		$HBoxContainer/PreviousButton.disabled = false



func _on_NextButton_pressed():
	$switch.pitch_scale = 1
	$switch.play()
	clicks += 1
	$HBoxContainer/NextButton.disabled = true
	$HBoxContainer/PreviousButton.disabled = true
	set_focus_approp()
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Control/ItemContainer,"rect_position",Vector2($Control/ItemContainer.rect_position.x - 900,$Control/ItemContainer.rect_position.y),0.3)
	yield(tween,"finished")
	if clicks != max_clicks:
		$HBoxContainer/NextButton.disabled = false
	$HBoxContainer/PreviousButton.disabled = false

func on_bought(amounti):
	var money_number = number_popup.instance()
	money_number.amount = "-" + str(amounti)
	money_number.type = "Green"
	money_number.position = Vector2(56,10)
	$AmountOmoney.text = str(Global.money).pad_zeros(5) + " $"
	$AmountOmoney/CenterContainer.add_child(money_number)


func _on_MainMenu_pressed():
	AudioServer.set_bus_effect_enabled(music_bus,0,false)
	$click.play()
	Global.save_game()
	Transition.change_scene("res://Scenes/Menu.tscn")

func _input(event):
	if event is InputEventJoypadButton:
		if Input.is_action_just_released("fire") and $HBoxContainer/NextButton.disabled == false:
			_on_NextButton_pressed()
			$HBoxContainer/NextButton.grab_focus()
		if Input.is_action_just_released("dash") and $HBoxContainer/PreviousButton.disabled == false:
			_on_PreviousButton_pressed()
			$HBoxContainer/PreviousButton.grab_focus()
		if Input.is_action_just_released("ui_cancel"):
			_on_MainMenu_pressed()
		if Input.is_action_just_released("ui_left"):
			var child = $Control/ItemContainer.get_child(clicks)
			child.get_node("HBoxContainer/Buy").grab_focus()
		if Input.is_action_just_released("ui_right"):
			var child = $Control/ItemContainer.get_child(clicks)
			child.get_node("HBoxContainer/Equip").grab_focus()
func set_focus_approp():
	var child = $Control/ItemContainer.get_child(clicks)
	$HBoxContainer/NextButton.focus_neighbour_bottom = $HBoxContainer/NextButton.get_path_to(child.get_node("HBoxContainer/Equip"))
	$HBoxContainer/PreviousButton.focus_neighbour_bottom = $HBoxContainer/PreviousButton.get_path_to(child.get_node("HBoxContainer/Buy"))
	child.get_node("HBoxContainer/Buy").focus_neighbour_right = child.get_node("HBoxContainer/Buy").get_path_to(child.get_node("HBoxContainer/Equip"))
	child.get_node("HBoxContainer/Equip").focus_neighbour_left = child.get_node("HBoxContainer/Equip").get_path_to(child.get_node("HBoxContainer/Buy"))
