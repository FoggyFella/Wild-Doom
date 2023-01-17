extends Button

export var has_a_bar:bool = false
export var should_focus:bool = false
export var should_change_outline:bool = false

func _ready():
	if should_focus:
		grab_focus()
		mouse_entered()
	connect("mouse_entered",self,"mouse_entered")
	connect("mouse_exited",self,"mouse_left")
	connect("focus_entered",self,"mouse_entered")
	connect("focus_exited",self,"mouse_left")
	self.rect_pivot_offset.x = self.rect_size.x/2
	self.rect_pivot_offset.y = self.rect_size.y/2

func mouse_entered():
	if self.disabled == false:
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_property(self,"rect_scale",Vector2(1.05,1.05),0.3)
		if has_a_bar:
			tween.parallel().tween_property(get_node("TextureRect"),"rect_scale",Vector2(1.2,1),0.5)

func mouse_left():
	if self.disabled == false and !has_focus():
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_property(self,"rect_scale",Vector2(1,1),0.3)
		if has_a_bar:
			tween.parallel().tween_property(get_node("TextureRect"),"rect_scale",Vector2(1,1),0.5)
