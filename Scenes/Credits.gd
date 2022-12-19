extends ColorRect

var colora = Color()
var fancy_texture = preload("res://Assets/bloody.png")

func _ready():
	pass
	#$ScrollContainer/VBoxContainer/Label.grab_focus()
	#$ViewportContainer/Viewport/ScrollContainer.grab_click_focus()

func _input(event):
	if Input.is_action_just_released("ui_cancel"):
		Transition.change_scene("res://Scenes/Menu.tscn")

func _on_Button_pressed():
	Transition.change_scene("res://Scenes/Menu.tscn")

func _process(delta):
	if $Control/AnimatedSprite.position.x >= 1500:
		$Control/AnimatedSprite.position.x = -819.5
	if $Control/AnimatedSprite2.position.x >= 1500:
		$Control/AnimatedSprite2.position.x = -1292
	$Control/AnimatedSprite.position.x += 1.2
	$Control/AnimatedSprite2.position.x += 1.3
