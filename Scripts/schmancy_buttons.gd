extends Button

func _ready():
	connect("mouse_entered",self,"mouse_entered")
	connect("mouse_exited",self,"mouse_left")
	self.rect_pivot_offset.x = self.rect_size.x/2
	self.rect_pivot_offset.y = self.rect_size.y/2

func mouse_entered():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self,"rect_scale",Vector2(1.05,1.05),0.3)

func mouse_left():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self,"rect_scale",Vector2(1,1),0.3)
