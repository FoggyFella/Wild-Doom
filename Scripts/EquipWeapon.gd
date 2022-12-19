extends Button

export var weapon_name: String

func _ready():
	if !Global.is_connected("weapon_equipped",self,"on_new_weapon_equipped"):
		Global.connect("weapon_equipped",self,"on_new_weapon_equipped")
	if !Global.is_connected("money_picked_up",self,"on_new_bought"):
		Global.connect("money_picked_up",self,"on_new_bought")
	if weapon_name in Global.bought_weapons and !weapon_name in Global.equipped_weapon:
		text = "Equip"
		disabled = false
	elif !weapon_name in Global.bought_weapons:
		text = "Not Bought"
		disabled = true
	else:
		text = "Equipped"
		disabled = true 
	connect("mouse_entered",self,"mouse_entered")
	connect("mouse_exited",self,"mouse_left")
	connect("focus_entered",self,"mouse_entered")
	connect("focus_exited",self,"mouse_left")
	self.rect_pivot_offset.x = self.rect_size.x/2
	self.rect_pivot_offset.y = self.rect_size.y/2
func _on_Equip_pressed():
	Global.equipped_weapon = weapon_name
	Global.emit_signal("weapon_equipped")
	var rand_num = int(rand_range(1,3))
	get_tree().current_scene.get_node("item" + str(rand_num)).pitch_scale = rand_range(0.98,1.1)
	get_tree().current_scene.get_node("item" + str(rand_num)).play()

func on_new_weapon_equipped():
	_ready()

func on_new_bought(a):
	_ready()

func mouse_entered():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self,"rect_scale",Vector2(1.05,1.05),0.3)

func mouse_left():
	if !has_focus():
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self,"rect_scale",Vector2(1,1),0.3)
