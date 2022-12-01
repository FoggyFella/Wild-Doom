extends Control

var max_x = 0
var clicks = 0
var max_clicks = 0
var number_popup = preload("res://Scenes/NumberPopup.tscn")

func _ready():
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
	clicks -= 1
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
	clicks += 1
	$HBoxContainer/NextButton.disabled = true
	$HBoxContainer/PreviousButton.disabled = true
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
	Global.save_game()
	Transition.change_scene("res://Scenes/Menu.tscn")
