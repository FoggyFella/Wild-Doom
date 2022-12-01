extends ColorRect

var colora = Color()
var fancy_texture = preload("res://Assets/bloody.png")

func _on_Button_pressed():
	Transition.change_scene("res://Scenes/Menu.tscn")

func _process(delta):
	if $Control/AnimatedSprite.position.x >= 1500:
		$Control/AnimatedSprite.position.x = -819.5
	if $Control/AnimatedSprite2.position.x >= 1500:
		$Control/AnimatedSprite2.position.x = -1292
	$Control/AnimatedSprite.position.x += 1.2
	$Control/AnimatedSprite2.position.x += 1.3
