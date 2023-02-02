extends Button

export var wave = 1
export var chapter = "res://Scenes/World.tscn"
export var what_to_check = 1.1
export var should_spend_pass = false
onready var parent = get_parent()

func _ready():
	disabled = true
	connect("toggled",self,"toggled")
	if !what_to_check in Global.settings["unlocked_chapter_parts"]:
		disabled = true
	else:
		disabled = false

func exited():
	pressed = false
	text = text.replace("<","")
	text = text.replace(">","")
	
func toggled(button_pressed):
	if button_pressed:
		if !">" in text:
			var tween = create_tween()
			tween.set_trans(Tween.TRANS_CUBIC)
			tween.tween_property($TextureRect,"rect_scale",Vector2(1.1,1),0.3)
			get_tree().current_scene.should_spend_pass = should_spend_pass
			get_tree().current_scene.selected_chapter = chapter
			text = ">" + text + "<"
		else:
			pressed = false
			var tween = create_tween()
			tween.set_trans(Tween.TRANS_CUBIC)
			tween.tween_property($TextureRect,"rect_scale",Vector2(1,1),0.3)
			text = text.replace("<","")
			text = text.replace(">","")
		Global.selected_wave = wave
		get_tree().current_scene.selected_chapter = chapter
		for child in parent.get_children():
			if child != self:
				child.pressed = false
				var tween = create_tween()
				tween.set_trans(Tween.TRANS_CUBIC)
				tween.tween_property(child.get_node("TextureRect"),"rect_scale",Vector2(1,1),0.3)
	else:
		text = text.replace("<","")
		text = text.replace(">","")
